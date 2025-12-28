import 'package:medistock/app/data/local/db/database_handler.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';

class TransactionProvider {
  final dbHandler = DatabaseHandler.instance;

  // دالة لإضافة عملية صرف جديدة
  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await dbHandler.database;
    return await db.insert('disbursement_transactions', transaction.toMap());
  }

  // دالة لجلب كل عمليات الصرف (للسجل)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'disbursement_transactions',
      orderBy: 'transaction_date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

// في المستقبل، يمكن إضافة دوال أخرى هنا، مثل جلب العمليات الخاصة بصنف معين
}