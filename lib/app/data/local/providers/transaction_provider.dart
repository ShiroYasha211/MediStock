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

  // --- ✅ جديد: جلب العمليات الخاصة بأمر صرف معين (لطباعة الفاتورة/السند) ---
  Future<List<BeneficiaryReportItem>> getTransactionsForOrder(
    int orderId,
  ) async {
    final db = await dbHandler.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT T.transaction_date, T.quantity_disbursed, I.name, I.unit, O.notes
      FROM disbursement_transactions T
      JOIN items I ON T.item_id = I.id
      JOIN disbursement_orders O ON T.order_id = O.id
      WHERE O.id = ?
      ORDER BY I.name ASC
    ''',
      [orderId],
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

  // --- ✅ جديد: دالة لجلب إجمالي المنصرف من صنف معين (الصافي بعد المرتجعات) ---
  Future<int> getTotalDisbursedForItem(int itemId) async {
    final db = await dbHandler.database;

    // يمكننا جلب الإجمالي من جدول المنصرفات وطرح المرتجعات منه
    // Query 1: إجمالي المنصرف
    final List<Map<String, dynamic>> disbursedMaps = await db.rawQuery(
      'SELECT SUM(quantity_disbursed) as total FROM disbursement_transactions WHERE item_id = ?',
      [itemId],
    );
    int totalDisbursed = 0;
    if (disbursedMaps.isNotEmpty && disbursedMaps.first['total'] != null) {
      totalDisbursed = disbursedMaps.first['total'] as int;
    }

    // Query 2: إجمالي المرتجع لنفس الصنف
    // يجب الربط مع جدول المنصرفات لمعرفة الـ item_id
    final List<Map<String, dynamic>> returnedMaps = await db.rawQuery(
      '''
      SELECT SUM(R.quantity_returned) as total 
      FROM return_transactions R
      JOIN disbursement_transactions T ON R.original_transaction_id = T.id
      WHERE T.item_id = ?
      ''',
      [itemId],
    );
    int totalReturned = 0;
    if (returnedMaps.isNotEmpty && returnedMaps.first['total'] != null) {
      totalReturned = returnedMaps.first['total'] as int;
    }

    return totalDisbursed - totalReturned;
  }

  // --- ✅ جديد (Phase 4): جلب إجمالي المنصرف لجميع الأصناف في استعلام واحد (حل مشكلة N+1) ---
  Future<Map<int, int>> getBulkTotalDisbursedForItems() async {
    final db = await dbHandler.database;

    // 1. جلب إجمالي المنصرف لكل صنف
    final disbursedMaps = await db.rawQuery('''
      SELECT item_id, SUM(quantity_disbursed) as total 
      FROM disbursement_transactions 
      GROUP BY item_id
    ''');

    // 2. جلب إجمالي المرتجع لكل صنف
    final returnedMaps = await db.rawQuery('''
      SELECT T.item_id, SUM(R.quantity_returned) as total 
      FROM return_transactions R
      JOIN disbursement_transactions T ON R.original_transaction_id = T.id
      GROUP BY T.item_id
    ''');

    // 3. تجميع وحساب الصافي في Map<itemId, netQuantity>
    final Map<int, int> netDispersedMap = {};

    for (var map in disbursedMaps) {
      final itemId = map['item_id'] as int?;
      final total = map['total'] as int?;
      if (itemId != null && total != null) {
        netDispersedMap[itemId] = total;
      }
    }

    for (var map in returnedMaps) {
      final itemId = map['item_id'] as int?;
      final returned = map['total'] as int?;
      if (itemId != null &&
          returned != null &&
          netDispersedMap.containsKey(itemId)) {
        netDispersedMap[itemId] = netDispersedMap[itemId]! - returned;
      }
    }

    return netDispersedMap;
  }

  // --- ✅ جديد: دالة لجلب سجل حركات صنف معين (لنافذة السجل) ---
  Future<List<Map<String, dynamic>>> getTransactionsHistoryForItem(
    int itemId,
  ) async {
    final db = await dbHandler.database;

    // استعلام معقد قليلاً لجلب بيانات الصرف وتفاصيل الأمر والكميات المرتجعة، مرتبة من الأحدث للأقدم
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        T.id as transaction_id,
        T.transaction_date, 
        T.quantity_disbursed, 
        O.order_number,
        O.beneficiary_id,
        B.name as beneficiary_name,
        COALESCE(SUM(R.quantity_returned), 0) as quantity_returned
      FROM disbursement_transactions T
      JOIN disbursement_orders O ON T.order_id = O.id
      LEFT JOIN beneficiaries B ON O.beneficiary_id = B.id
      LEFT JOIN return_transactions R ON T.id = R.original_transaction_id
      WHERE T.item_id = ?
      GROUP BY T.id
      ORDER BY T.transaction_date DESC
      ''',
      [itemId],
    );

    return maps;
  }
}
