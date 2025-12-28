class DisbursementOrderModel {
  final int? id;
  final String orderNumber;
  final DateTime orderDate;
  final String? issuingEntity;
  final int? beneficiaryId;
  final String status;
  final String? notes;
  final String? imagePath;
  final DateTime createdAt;

  DisbursementOrderModel({
    this.id,
    required this.orderNumber,
    required this.orderDate,
    this.issuingEntity,
    this.beneficiaryId,
    required this.status,
    this.notes,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'issuing_entity': issuingEntity,
      'beneficiary_id': beneficiaryId,
      'status': status,
      'notes': notes,
      'image_path': imagePath, 'created_at': createdAt.toIso8601String(),
    };
  }

  factory DisbursementOrderModel.fromMap(Map<String, dynamic> map) {
    return DisbursementOrderModel(
      id: map['id'],
      orderNumber: map['order_number'],
      orderDate: DateTime.parse(map['order_date']),
      issuingEntity: map['issuing_entity'],
      beneficiaryId: map['beneficiary_id'],
      status: map['status'],
      notes: map['notes'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}