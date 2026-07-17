import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/staff/domain/usecases/staff_usecases.dart';

part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetStaffMembersUseCase getStaffMembersUseCase;
  final DeleteStaffMemberUseCase deleteStaffMemberUseCase;
  final AuthBloc authBloc;

  StaffBloc({
    required this.getStaffMembersUseCase,
    required this.deleteStaffMemberUseCase,
    required this.authBloc,
  }) : super(const StaffState()) {
    on<LoadStaff>(_onLoadStaff);
    on<DeleteStaffMember>(_onDeleteStaffMember);
  }

  String? get _currentShopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  Future<void> _onLoadStaff(
      LoadStaff event, Emitter<StaffState> emit) async {
    emit(state.copyWith(status: StaffStatus.loading));
    final result = await getStaffMembersUseCase(NoParams(),
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: StaffStatus.error, message: failure.message)),
      (staff) => emit(
          state.copyWith(status: StaffStatus.loaded, staff: staff)),
    );
  }

  Future<void> _onDeleteStaffMember(
      DeleteStaffMember event, Emitter<StaffState> emit) async {
    emit(state.copyWith(status: StaffStatus.loading));
    final result = await deleteStaffMemberUseCase(event.id,
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: StaffStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: StaffStatus.success,
            message: 'Staff deleted successfully'));
        add(LoadStaff());
      },
    );
  }
}
