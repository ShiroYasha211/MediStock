import '../db/database_handler.dart';
import '../models/beneficiary_model.dart';

class BeneficiaryProvider {
  final dbHandler = DatabaseHandler.instance;

  // دالة لإضافة مستفيد جديد
  Future<int> addBeneficiary(BeneficiaryModel beneficiary) async {
    final db = await dbHandler.database;
    return await db.insert('beneficiaries', beneficiary.toMap());
  }

  // دالة لجلب كل المستفيدين
  Future<List<BeneficiaryModel>> getAllBeneficiaries() async {
    final db = await dbHandler.database;
    final List<Map<String, dynamic>> maps =
    await db.query('beneficiaries', orderBy: 'name ASC');

    return List.generate(maps.length, (i) {
      return BeneficiaryModel.fromMap(maps[i]);
    });
  }

// دالة لتحديثمستفيد
  Future<int> updateBeneficiary(BeneficiaryModel beneficiary) async {
    final db = await dbHandler.database;
    return await db.update(
        'beneficiaries',
        beneficiary.toMap(),
        where: 'id = ?',
        whereArgs: [beneficiary.id],
    );
  }

  // دالة لحذف مستفيد
  Future<int> deleteBeneficiary(int id) async {
    final db = await dbHandler.database;
    return await db.delete(
        'beneficiaries',
        where: 'id = ?',
      whereArgs: [id],
    );
  }
}