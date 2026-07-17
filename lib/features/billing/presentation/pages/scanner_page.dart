import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isScanned = false;
  PermissionStatus _cameraStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() {
        _cameraStatus = status;
      });
    }
  }

  Future<void> _requestPermission() async {
    final result = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _cameraStatus = result;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        SystemSound.play(SystemSoundType.click);
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate(duration: 300, amplitude: 255);
        }

        if (mounted) {
          // Return the scanned barcode value to the caller
          context.pop(barcode.rawValue!);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Barcode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: Stack(
          children: [
            // Camera permission not granted — show explanation screen
            if (_cameraStatus != PermissionStatus.granted)
              _buildPermissionPrompt()
            else
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
              ),

            // Scan frame overlay
            if (_cameraStatus == PermissionStatus.granted)
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_corner(0), _corner(1)],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_corner(3), _corner(2)],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Hint text
            if (_cameraStatus == PermissionStatus.granted)
              const Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  'Align barcode within frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPrompt() {
    final isPermanentlyDenied =
        _cameraStatus == PermissionStatus.permanentlyDenied;

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 24),
              Text(
                isPermanentlyDenied
                    ? 'Camera Permission Required'
                    : 'Camera Access Needed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanentlyDenied
                    ? 'Camera permission was permanently denied. Please enable it from app settings to scan barcodes.'
                    : 'This app needs camera access to scan barcodes. Please grant the permission.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(isPermanentlyDenied
                    ? Icons.settings
                    : Icons.camera_alt),
                label: Text(isPermanentlyDenied ? 'Open Settings' : 'Grant Permission'),
                onPressed: () async {
                  if (isPermanentlyDenied) {
                    await openAppSettings();
                    await _checkPermission();
                  } else {
                    await _requestPermission();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner(int index) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
