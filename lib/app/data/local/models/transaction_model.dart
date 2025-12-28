class TransactionModel {
  final int? id;
  final DateTime transactionDate;
  final int itemId;
  final int quantityDisbursed;
  final int orderId;
  final int? userId;
  final String? notes;

  TransactionModel({
    this.id,
    required this.transactionDate,
    required this.itemId,
    required this.quantityDisbursed,
    required this.orderId,
    this.userId,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_date': transactionDate.toIso8601String(),
      'item_id': itemId,
      'quantity_disbursed': quantityDisbursed,
      'order_id': orderId,
      'user_id': userId,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      transactionDate: DateTime.parse(map['transaction_date']),
      itemId: map['item_id'],
      quantityDisbursed: map['quantity_disbursed'],
      orderId: map['order_id'],
      userId: map['user_id'],
      notes: map['notes'],
    );
  }
}