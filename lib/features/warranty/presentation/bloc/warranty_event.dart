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
  final String? customerId;
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
    this.customerId,
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

/// Resets one-shot flags (submitSuccess / updateSuccess / error) after the UI
/// has consumed them, so stale state never re-triggers dialogs or snackbars.
class ClearWarrantyFeedback extends WarrantyEvent {
  const ClearWarrantyFeedback();
}
