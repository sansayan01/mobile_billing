part of 'warranty_bloc.dart';

abstract class WarrantyEvent extends Equatable {
  const WarrantyEvent();
  @override
  List<Object> get props => [];
}

class LoadWarrantyClaims extends WarrantyEvent {
  final String? status;
  const LoadWarrantyClaims({this.status});
  @override
  List<Object> get props => [status ?? ''];
}

class CreateWarrantyClaim extends WarrantyEvent {
  final String billId;
  final String productId;
  final String productName;
  final String? customerName;
  final String? customerPhone;
  final String claimReason;
  final String claimType;
  final int? warrantyDuration;
  final String? warrantyUnit;

  const CreateWarrantyClaim({
    required this.billId,
    required this.productId,
    required this.productName,
    this.customerName,
    this.customerPhone,
    required this.claimReason,
    this.claimType = 'warranty',
    this.warrantyDuration,
    this.warrantyUnit,
  });

  @override
  List<Object> get props => [billId, productId, productName, claimReason, claimType];
}

class UpdateWarrantyClaimStatus extends WarrantyEvent {
  final String claimId;
  final String status;

  const UpdateWarrantyClaimStatus({
    required this.claimId,
    required this.status,
  });

  @override
  List<Object> get props => [claimId, status];
}
