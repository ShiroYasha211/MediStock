class ItemModel {
  final int? id;
  final String? itemCode;

  // --- تم التعديل: سنعتبر name هو الاسم التجاري ---
  final String name; // Commercial Name

  // --- جديد: إضافة الحقول الجديدة ---
  final String? scientificName;
  final String? imagePath;

  final int? typeId;
  final int? formId;
  final String? unit;
  final String? batchNumber;
  final DateTime? productionDate;
  final DateTime expiryDate;
  final int quantity;
  final int alertLimit;
  final String? notes;
  final DateTime createdAt;

  ItemModel({
    this.id,
    this.itemCode,
    required this.name, // يمثل الاسم التجاري
    this.scientificName, // جديد
    this.imagePath, // جديد
    this.typeId,
    this.formId,
    this.unit,
    this.batchNumber,
    this.productionDate,
    required this.expiryDate,
    required this.quantity,
    this.alertLimit = 0,
    this.notes,
    required this.createdAt,
  });

  // دالة لتحويل بيانات الصنف إلى Map لإدراجها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_code': itemCode,
      // تم التغيير هنا ليتوافق مع قاعدة البيانات
      'name': name, // اسم الصنف الأساسي/التجاري
      'commercial_name': name, // يمكن تكراره أو استخدام name فقط
      'scientific_name': scientificName, // جديد
      'image_path': imagePath, // جديد
      'type_id': typeId,
      'form_id': formId,
      'unit': unit,
      'batch_number': batchNumber,
      'production_date': productionDate?.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'quantity': quantity,
      'alert_limit': alertLimit,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // دالة لتحويل Map من قاعدة البيانات إلى ItemModel
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      itemCode: map['item_code'],
      // تم التغيير هنا ليتوافق مع قاعدة البيانات
      name: map['name'], // جلب الاسم التجاري من حقل name
      scientificName: map['scientific_name'], // جديد
      imagePath: map['image_path'], // جديد
      typeId: map['type_id'],
      formId: map['form_id'],
      unit: map['unit'],
      batchNumber: map['batch_number'],
      productionDate: map['production_date'] != null
          ? DateTime.parse(map['production_date'])
          : null,
      expiryDate: DateTime.parse(map['expiry_date']),
      quantity: map['quantity'],
      alertLimit: map['alert_limit'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
