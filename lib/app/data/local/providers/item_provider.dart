import '../db/database_handler.dart'; // استيراد مسؤول قاعدة البيانات
import '../models/item_model.dart';   // استيراد نموذج البيانات

class ItemProvider {
  final dbHandler = DatabaseHandler.instance;  // دالة لإضافة صنف جديد إلى قاعدة البيانات
  // تستقبل كائن `ItemModel` وترجع الـ ID الخاص به بعد الإضافة
  Future<int> addItem(ItemModel item) async {
    final db = await dbHandler.database;
    // نستخدم toMap() لتحويل الكائن إلى صيغة مناسبة لقاعدة البيانات
    return await db.insert('items', item.toMap());
  }

  // دالة لجلب كل الأصناف من قاعدة البيانات
  // ترجع قائمة من نوع `ItemModel`
  Future<List<ItemModel>> getAllItems() async {
    final db = await dbHandler.database;
    // جلب كل البيانات من جدول 'items' وترتيبها حسب تاريخ الإضافة (الأحدث أولاً)
    final List<Map<String, dynamic>> maps = await db.query('items', orderBy: 'created_at DESC');

    // تحويل القائمة من Maps إلى قائمة من كائنات ItemModel
    return List.generate(maps.length, (i) {
      return ItemModel.fromMap(maps[i]);
    });
  }

  // دالة لتحديث بيانات صنف معين
  // تستقبل كائن `ItemModel` محدّث
  Future<int> updateItem(ItemModel item) async {
    final db = await dbHandler.database;
    // تحديث الصنف الذي يتطابق الـ id الخاص به
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // دالة لحذف صنف معين من قاعدة البيانات
  // تستقبل الـ id الخاص بالصنف المُراد حذفه
  Future<int> deleteItem(int id) async {
    final db = await dbHandler.database;
    // حذف الصنف الذي يتطابق الـ id الخاص به
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- جديد: دالة لجلب كل الوحدات ---
  Future<List<String>> getAllUnits() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps = await db.query('units', orderBy: 'name ASC');

    // تحويل القائمة من Maps إلى قائمة من النصوص (أسماء الوحدات)
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }

  // --- جديد: دالة للبحث عن الأصناف ---
  Future<List<ItemModel>> searchItems(String keyword) async {
    final db = await dbHandler.database;
    // جلب البيانات التي يتطابق فيها الاسم التجاري أو العلمي أو الكود مع الكلمة المفتاحية
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'name LIKE ? OR scientific_name LIKE ? OR item_code LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'], // استخدام % للبحث الجزئي
      orderBy: 'created_at DESC',
    );

    // تحويل القائمة من Maps إلى قائمة من كائنات ItemModel
    return List.generate(maps.length, (i) {
      return ItemModel.fromMap(maps[i]);
    });
  }
  // --- ✅ جديد: دالة لجلب كل الأشكال الدوائية ---
  Future<List<String>> getAllItemForms() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps =
    await db.query('item_forms', orderBy: 'name ASC');

    // تحويل القائمة من Maps إلى قائمة من النصوص (أسماء الأشكال)
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }

// --- ✅ جديد: دوال إضافة وحذف الوحدات والأشكال ---

  Future<int> addUnit(String name) async {
    final db = await dbHandler.database;
    return await db.insert('units', {'name': name});
  }

  Future<int> deleteUnit(String name) async {
    final db = await dbHandler.database;
    return await db.delete('units', where: 'name = ?', whereArgs: [name]);
  }

  Future<int> addItemForm(String name) async {
    final db = await dbHandler.database;
    return await db.insert('item_forms', {'name': name});
  }

  Future<int> deleteItemForm(String name) async {
    final db = await dbHandler.database;
    return await db.delete('item_forms', where: 'name = ?', whereArgs: [name]);
  }
}
