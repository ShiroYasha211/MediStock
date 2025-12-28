import '../db/database_handler.dart';
import '../models/disbursement_order_model.dart';

class OrderProvider {
  final dbHandler = DatabaseHandler.instance;

  // دالة لإضافة أمر صرف جديد
  Future<int> addOrder(DisbursementOrderModel order) async {
    final db = await dbHandler.database;
    return await db.insert('disbursement_orders', order.toMap());
  }

  // دالة لجلب كل أوامر الصرف
  Future<List<DisbursementOrderModel>> getAllOrders() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps =
    await db.query('disbursement_orders', orderBy: 'order_date DESC');

    return List.generate(maps.length, (i) {
      return DisbursementOrderModel.fromMap(maps[i]);
    });
  }

  // دالة لتحديث أمر صرف
  Future<int> updateOrder(DisbursementOrderModel order) async {
    final db = await dbHandler.database;
    return await db.update(
      'disbursement_orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // دالة لحذف أمر صرف
  Future<int> deleteOrder(int id) async {
    final db = await dbHandler.database;
    return await db.delete(
      'disbursement_orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
