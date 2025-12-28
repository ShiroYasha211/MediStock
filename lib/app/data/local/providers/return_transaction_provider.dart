import 'package:medistock/app/data/local/db/database_handler.dart';
import 'package:medistock/app/data/local/models/return_transaction_model.dart';

class ReturnTransactionProvider {
  final dbHandler = DatabaseHandler.instance;

  // دالة لإضافة عملية إرجاع جديدة
  Future<int> addReturnTransaction(ReturnTransactionModel transaction) async {
    final db = await dbHandler.database;
    return await db.insert('return_transactions', transaction.toMap());
  }

  // دالة لجلب كل عمليات الإرجاع (للسجل)
  Future<List<ReturnTransactionModel>> getAllReturnTransactions() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps =
    await db.query('return_transactions', orderBy: 'return_date DESC');

    return List.generate(maps.length, (i) {
      return ReturnTransactionModel.fromMap(maps[i]);
    });
  }

  // دالة لمعرفة إجمالي الكمية المرتجعة من عملية صرف معينة
  Future<int> getReturnedQuantityForTransaction(
      int originalTransactionId) async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'return_transactions',
      columns: ['SUM(quantity_returned) as total'],
      where: 'original_transaction_id = ?',
      whereArgs: [originalTransactionId],
    );

    if (maps.isNotEmpty && maps.first['total'] != null) {
      return maps.first['total'] as int;
    }
    return 0;
  }
}