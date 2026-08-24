import 'package:bloc/bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/audit/domain/repositories/audit_repository.dart';
import 'audit_event.dart';
import 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository auditRepository;
  final AuthBloc authBloc;
  static const int _pageSize = 30;

  AuditBloc({required this.auditRepository, required this.authBloc})
      : super(const AuditState()) {
    on<LoadAuditLogs>(_onLoadAuditLogs);
    on<LoadMoreAuditLogs>(_onLoadMoreAuditLogs);
    on<LoadEntityAuditLogs>(_onLoadEntityAuditLogs);
    on<LogAuditAction>(_onLogAuditAction);
    on<ResetAuditLogs>(_onReset);
  }

  String? get _shopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  String? get _staffName {
    final s = authBloc.state;
    return s is Authenticated ? s.user.name : null;
  }


  Future<void> _onLoadAuditLogs(LoadAuditLogs event, Emitter<AuditState> emit) async {
    emit(state.copyWith(status: AuditStatus.loading, currentPage: 0, hasMore: true));

    final result = await auditRepository.getAuditLogs(
      entityType: event.entityType,
      action: event.action,
      performedBy: event.performedBy,
      from: event.from,
      to: event.to,
      searchQuery: event.searchQuery,
      shopId: _shopId,
      limit: _pageSize,
      offset: 0,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: AuditStatus.error, error: failure.message)),
      (logs) => emit(state.copyWith(
        status: AuditStatus.loaded,
        logs: logs,
        currentPage: 0,
        hasMore: logs.length >= _pageSize,
        lastFilterAction: event.action,
        lastFilterEntity: event.entityType,
        lastFilterStaff: event.performedBy,
        lastFilterFrom: event.from,
        lastFilterTo: event.to,
        lastFilterSearch: event.searchQuery,
      )),
    );
  }

  Future<void> _onLoadMoreAuditLogs(LoadMoreAuditLogs event, Emitter<AuditState> emit) async {
    if (!state.hasMore || state.status == AuditStatus.loading) return;

    final nextPage = state.currentPage + 1;

    final result = await auditRepository.getAuditLogs(
      entityType: state.lastFilterEntity,
      action: state.lastFilterAction,
      performedBy: state.lastFilterStaff,
      from: state.lastFilterFrom,
      to: state.lastFilterTo,
      searchQuery: state.lastFilterSearch,
      shopId: _shopId,
      limit: _pageSize,
      offset: nextPage * _pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: AuditStatus.error, error: failure.message)),
      (logs) => emit(state.copyWith(
        logs: [...state.logs, ...logs],
        currentPage: nextPage,
        hasMore: logs.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadEntityAuditLogs(LoadEntityAuditLogs event, Emitter<AuditState> emit) async {
    emit(state.copyWith(status: AuditStatus.loading));

    final result = await auditRepository.getEntityAuditLogs(
      entityType: event.entityType,
      entityId: event.entityId,
      shopId: _shopId,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: AuditStatus.error, error: failure.message)),
      (logs) => emit(state.copyWith(status: AuditStatus.loaded, entityLogs: logs)),
    );
  }

  Future<void> _onLogAuditAction(LogAuditAction event, Emitter<AuditState> emit) async {
    await auditRepository.logAction(
      action: event.action,
      entityType: event.entityType,
      entityId: event.entityId,
      entityName: event.entityName,
      description: event.description,
      oldValue: event.oldValue,
      newValue: event.newValue,
      staffName: _staffName,
      shopId: event.shopId ?? _shopId,
    );
  }

  void _onReset(ResetAuditLogs event, Emitter<AuditState> emit) {
    emit(const AuditState());
  }
}
