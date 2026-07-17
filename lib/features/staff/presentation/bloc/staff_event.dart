part of 'staff_bloc.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object> get props => [];
}

class LoadStaff extends StaffEvent {}

class DeleteStaffMember extends StaffEvent {
  final String id;

  const DeleteStaffMember(this.id);

  @override
  List<Object> get props => [id];
}
