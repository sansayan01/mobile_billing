import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/printer_repository.dart';
import 'printer_event.dart';
import 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final PrinterRepository repository;

  PrinterBloc({required this.repository}) : super(const PrinterState()) {
    on<InitPrinterEvent>(_onInit);
    on<RefreshPrinterEvent>(_onRefresh);
    on<ScanPrintersEvent>(_onScan);
    on<ConnectPrinterEvent>(_onConnect);
    on<DisconnectPrinterEvent>(_onDisconnect);
    on<TestPrintEvent>(_onTestPrint);
  }

  void _onInit(InitPrinterEvent event, Emitter<PrinterState> emit) {
    final mac = repository.getSavedPrinterMac();
    final name = repository.getSavedPrinterName();
    emit(state.copyWith(
      status: PrinterStatus.initial,
      connectedMac: mac,
      connectedName: name,
    ));
  }

  Future<void> _onRefresh(
      RefreshPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.scanning, clearError: true));
    try {
      final devices = await repository.scanDevices();
      if (devices.isEmpty) {
        emit(state.copyWith(
          status: PrinterStatus.scanFailure,
          errorMessage: 'No paired devices found.',
          devices: [],
        ));
        return;
      }

      bool connected = false;
      // Auto-connect heuristic: only auto-pair devices that look like
      // printers (name contains printer/pos/thermal). Anything else waits
      // for manual selection from the device list.
      final candidates = devices.where((d) {
        final n = d.name.toLowerCase();
        return n.contains('printer') ||
            n.contains('pos') ||
            n.contains('thermal');
      }).toList();
      for (var device in candidates) {
        final success = await repository.connect(device.macAdress);
        if (success) {
          await repository.savePrinterData(device.macAdress, device.name);
          emit(state.copyWith(
            status: PrinterStatus.connected,
            connectedMac: device.macAdress,
            connectedName: device.name,
            devices: devices,
            clearError: true,
          ));
          connected = true;
          break;
        }
      }

      if (!connected) {
        if (candidates.isEmpty) {
          // No printer-looking device — show the list, wait for manual pick.
          emit(state.copyWith(
            status: PrinterStatus.scanSuccess,
            devices: devices,
            clearError: true,
          ));
        } else {
          emit(state.copyWith(
            status: PrinterStatus.scanFailure,
            errorMessage: 'Could not connect to any paired printer.',
            devices: devices,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: PrinterStatus.scanFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onScan(
      ScanPrintersEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.scanning, clearError: true));
    try {
      final devices = await repository.scanDevices();
      emit(state.copyWith(
        status: PrinterStatus.scanSuccess,
        devices: devices,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrinterStatus.scanFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onConnect(
      ConnectPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.connecting, clearError: true));
    final success = await repository.connect(event.mac);
    if (success) {
      await repository.savePrinterData(event.mac, event.name);
      emit(state.copyWith(
        status: PrinterStatus.connected,
        connectedMac: event.mac,
        connectedName: event.name,
      ));
    } else {
      emit(state.copyWith(
        status: PrinterStatus.connectionFailure,
        errorMessage: 'Failed to connect to printer',
      ));
    }
  }

  Future<void> _onDisconnect(
      DisconnectPrinterEvent event, Emitter<PrinterState> emit) async {
    await repository.disconnect();
    await repository.clearPrinterData();
    emit(PrinterState(
      status: PrinterStatus.disconnected,
      devices: state.devices,
    ));
  }

  Future<void> _onTestPrint(
      TestPrintEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.testPrinting, clearError: true));
    try {
      final ok = await repository.testPrint(event.shopName);
      if (!ok) {
        emit(state.copyWith(
          status: PrinterStatus.connectionFailure,
          errorMessage: 'Printer not connected or test print failed',
        ));
        return;
      }
      emit(state.copyWith(status: PrinterStatus.scanSuccess));
    } catch (e) {
      emit(state.copyWith(
        status: PrinterStatus.connectionFailure,
        errorMessage: e.toString(),
      ));
    }
  }
}
