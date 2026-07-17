part of 'staff_bloc.dart';

enum StaffStatus { initial, loading, loaded, error, success }

class StaffState extends Equatable {
  final StaffStatus status;
  final List<User> staff;
  final String? message;

  const StaffState({
    this.status = StaffStatus.initial,
    this.staff = const [],
    this.message,
  });

  StaffState copyWith({
    StaffStatus? status,
    List<User>? staff,
    String? message,
  }) {
    return StaffState(
      status: status ?? this.status,
      staff: staff ?? this.staff,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, staff, message];
}
