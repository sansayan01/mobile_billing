import 'package:equatable/equatable.dart';

class WarrantyClaim extends Equatable {
  final String id;
  final String billId;
  final String productId;
  final String productName;
  final String? customerName;
  final String? customerPhone;
  final String claimReason;
  final String claimStatus; // 'pending', 'approved', 'rejected', 'resolved'
  final String claimType; // 'warranty' or 'guarantee'
  final int? warrantyDuration;
  final String? warrantyUnit;
  final String? claimedByStaffId;
  final String? staffName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WarrantyClaim({
    required this.id,
    required this.billId,
    required this.productId,
    required this.productName,
    this.customerName,
    this.customerPhone,
    required this.claimReason,
    this.claimStatus = 'pending',
    this.claimType = 'warranty',
    this.warrantyDuration,
    this.warrantyUnit,
    this.claimedByStaffId,
    this.staffName,
    required this.createdAt,
    this.updatedAt,
  });

  String get warrantyLabel {
    final type = claimType == 'guarantee' ? 'Guarantee' : 'Warranty';
    if (warrantyDuration != null && warrantyUnit != null) {
      return '$type: $warrantyDuration $warrantyUnit';
    }
    return type;
  }

  WarrantyClaim copyWith({
    String? id,
    String? billId,
    String? productId,
    String? productName,
    String? customerName,
    String? customerPhone,
    String? claimReason,
    String? claimStatus,
    String? claimType,
    int? warrantyDuration,
    String? warrantyUnit,
    String? claimedByStaffId,
    String? staffName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarrantyClaim(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      claimReason: claimReason ?? this.claimReason,
      claimStatus: claimStatus ?? this.claimStatus,
      claimType: claimType ?? this.claimType,
      warrantyDuration: warrantyDuration ?? this.warrantyDuration,
      warrantyUnit: warrantyUnit ?? this.warrantyUnit,
      claimedByStaffId: claimedByStaffId ?? this.claimedByStaffId,
      staffName: staffName ?? this.staffName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        billId,
        productId,
        productName,
        customerName,
        customerPhone,
        claimReason,
        claimStatus,
        claimType,
        warrantyDuration,
        warrantyUnit,
        claimedByStaffId,
        staffName,
        createdAt,
        updatedAt,
      ];
}
