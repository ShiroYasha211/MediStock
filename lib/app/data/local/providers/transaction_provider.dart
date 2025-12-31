import 'package:medistock/app/data/local/db/database_handler.dart';
import 'package:medistock/app/data/local/models/transaction_model.dart';

// DTO for the report
class BeneficiaryReportItem {
  final DateTime date;
  final String itemName;
  final String? unit;
  final int quantity;
  final String? notes;

  BeneficiaryReportItem({
    required this.date,
    required this.itemName,
    this.unit,
    required this.quantity,
    this.notes,
  });
}

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

  // --- ✅ جديد: جلب العمليات الخاصة بمستفيد معين للتقرير ---
  Future<List<BeneficiaryReportItem>> getTransactionsForBeneficiary(
    int beneficiaryId,
  ) async {
    final db = await dbHandler.database;

    // نحتاج لربط 3 جداول: المعاملات، الأصناف، والأوامر (لأن المستفيد مربوط بالأمر)
    // أو إذا كان المستفيد مربوط بالأمر، فإن المعاملة مربوطة بالامر، والامر بالمستفيد.
    // Query:
    // SELECT T.transaction_date, T.quantity_disbursed, I.name, I.unit, O.notes
    // FROM disbursement_transactions T
    // JOIN items I ON T.item_id = I.id
    // JOIN disbursement_orders O ON T.order_id = O.id
    // WHERE O.beneficiary_id = ?

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT T.transaction_date, T.quantity_disbursed, I.name, I.unit, O.notes
      FROM disbursement_transactions T
      JOIN items I ON T.item_id = I.id
      JOIN disbursement_orders O ON T.order_id = O.id
      WHERE O.beneficiary_id = ?
      ORDER BY T.transaction_date DESC
    ''',
      [beneficiaryId],
    );

    return List.generate(maps.length, (i) {
      return BeneficiaryReportItem(
        date: DateTime.parse(maps[i]['transaction_date']),
        itemName: maps[i]['name'],
        unit: maps[i]['unit'],
        quantity: maps[i]['quantity_disbursed'],
        notes: maps[i]['notes'],
      );
    });
  }
}
