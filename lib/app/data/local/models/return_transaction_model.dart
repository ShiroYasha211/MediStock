class ReturnTransactionModel {
  final int? id;
  final DateTime returnDate;
  final int originalTransactionId;
  final int quantityReturned;
  final String? reason;
  final int? userId;

  ReturnTransactionModel({
    this.id,
    required this.returnDate,
    required this.originalTransactionId,
    required this.quantityReturned,
    this.reason,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'return_date': returnDate.toIso8601String(),
      'original_transaction_id': originalTransactionId,
      'quantity_returned': quantityReturned,
      'reason': reason,
      'user_id': userId,
    };
  }

  factory ReturnTransactionModel.fromMap(Map<String, dynamic> map) {
    return ReturnTransactionModel(
      id: map['id'],
      returnDate: DateTime.parse(map['return_date']),
      originalTransactionId: map['original_transaction_id'],
      quantityReturned: map['quantity_returned'],
      reason: map['reason'],
      userId: map['user_id'],
    );
  }
}