import 'package:equatable/equatable.dart';

class DuePayment extends Equatable {
  final String billId;
  final String? customerName;
  final String? customerPhone;
  final double grandTotal;
  final double amountPaid;
  final double dueAmount;
  final String paymentMethod;
  final String staffName;
  final DateTime billDate;

  const DuePayment({
    required this.billId,
    this.customerName,
    this.customerPhone,
    required this.grandTotal,
    required this.amountPaid,
    required this.dueAmount,
    required this.paymentMethod,
    required this.staffName,
    required this.billDate,
  });

  DuePayment copyWith({
    String? billId,
    String? customerName,
    String? customerPhone,
    double? grandTotal,
    double? amountPaid,
    double? dueAmount,
    String? paymentMethod,
    String? staffName,
    DateTime? billDate,
  }) {
    return DuePayment(
      billId: billId ?? this.billId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      grandTotal: grandTotal ?? this.grandTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      staffName: staffName ?? this.staffName,
      billDate: billDate ?? this.billDate,
    );
  }

  @override
  List<Object?> get props => [
        billId,
        customerName,
        customerPhone,
        grandTotal,
        amountPaid,
        dueAmount,
        paymentMethod,
        staffName,
        billDate,
      ];
}
