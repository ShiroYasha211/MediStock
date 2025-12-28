class BeneficiaryModel {
  final int? id;
  final String name;
  final String? type;
  final String? identifier;
  final String? notes;
  final DateTime createdAt;

  BeneficiaryModel({
  this.id,
  required this.name,
  this.type,
  this.identifier,
  this.notes,
  required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'identifier': identifier,
      'notes': notes, 'created_at': createdAt.toIso8601String(),
    };
  }

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map) {
    return BeneficiaryModel(
        id: map['id'],
        name: map['name'],
        type: map['type'],
        identifier: map['identifier'],
        notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

