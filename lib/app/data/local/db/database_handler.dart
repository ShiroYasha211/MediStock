import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHandler {
  DatabaseHandler._privateConstructor();
  static final DatabaseHandler instance = DatabaseHandler._privateConstructor();

  static Database? _database;
  static const _dbVersion = 7; // <--- تعريف رقم الإصدار هنا لسهولة الوصول إليه

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medistock.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <--- تمت إضافة هذه الدالة
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- ✅ الحل: إنشاء الجدول بأحدث بنية مباشرة ---
    await db.execute('''
    CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_code TEXT UNIQUE,
      name TEXT NOT NULL,
      type_id INTEGER,
      form_id INTEGER,
      unit TEXT,
      batch_number TEXT,
      production_date TEXT,
      expiry_date TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      alert_limit INTEGER DEFAULT 0,
      notes TEXT,
      created_at TEXT NOT NULL,
      -- إضافة الأعمدة الجديدة هنا
      commercial_name TEXT,
      scientific_name TEXT,
      image_path TEXT
    )
  ''');

    // إنشاء جدول الوحدات وإضافة البيانات الأولية
    await _createUnitsTableAndSeed(db);
    await _createItemFormsTableAndSeed(db);
    await _createDisbursementOrdersTable(db);
    await _createBeneficiariesTable(db);
    await _createDisbursementTransactionsTable(db);
    await _createReturnTransactionsTable(db);
  }

  // --- 2. تعديل دالة الترقية onUpgrade ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // --- 3. تنفيذ أوامر الترقية من الإصدار 1 إلى 2 ---
      print("Database upgrading from version 1 to 2...");

      // أ. إضافة الأعمدة الجديدة لجدول الأصناف
      await db.execute("ALTER TABLE items ADD COLUMN commercial_name TEXT");
      await db.execute("ALTER TABLE items ADD COLUMN scientific_name TEXT");
      await db.execute("ALTER TABLE items ADD COLUMN image_path TEXT");

      // ب. إنشاء جدول الوحدات وإضافة البيانات الأولية له
      await _createUnitsTableAndSeed(db);

      print("Database upgrade to version 2 completed.");
    }
    if (oldVersion < 3) {
      print("Database upgrading from version 2 to 3...");

      // أ. إضافة حقل form_id إلى جدول items (إذا لم يكن موجوداً)
      // هذا الحقل كان موجوداً في البنية الأصلية لكن قد يكون حُذف، لذا نتأكد
      // يمكنك تخطي هذا إذا كنت متأكداً أنه موجود.
      // await db.execute("ALTER TABLE items ADD COLUMN form_id INTEGER");

      // ب. إنشاء جدول الأشكال الدوائية
      await _createItemFormsTableAndSeed(db);

      print("Database upgrade to version 3 completed.");
    }

    if (oldVersion < 4)
     {
    print("Database upgrading from version 3 to 4...");
    await _createDisbursementOrdersTable(db);
    print("Database upgrade to version 4 completed.");
    }
    if (oldVersion < 5) {
      print("Database upgrading from version 4 to 5...");
      await _createBeneficiariesTable(db);
      print("Database upgrade to version 5 completed.");
    }
    if (oldVersion < 6) {
      print("Database upgrading from version 5 to 6...");
      await _createDisbursementTransactionsTable(db);
      print("Database upgrade to version 6 completed.");
    }
    if (oldVersion < 7) {
      print("Database upgrading from version 6 to 7...");
      await _createReturnTransactionsTable(db);
      print("Database upgrade to version 7 completed.");
    }
  }



  Future<void> _createUnitsTableAndSeed(Database db) async {
    // أ. إنشاء جدول الوحدات
    await db.execute('''
      CREATE TABLE units (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // ب. إضافة البيانات الأولية
    await db.insert('units', {'name': 'علبة'});
    await db.insert('units', {'name': 'شريط'});
    await db.insert('units', {'name': 'حبة'});
    await db.insert('units', {'name': 'كرتون'});
  }
  // --- ✅ جديد: دالة لإنشاء جدول الأشكال الدوائية ---
  Future<void> _createItemFormsTableAndSeed(Database db) async {
    // أ. إنشاء جدول الأشكال الدوائية
    await db.execute('''
          CREATE TABLE item_forms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');

    // ب. إضافة البيانات الأولية
    await db.insert('item_forms', {'name': 'حبوب'});
    await db.insert('item_forms', {'name': 'شراب'});
    await db.insert('item_forms', {'name': 'دهان'});
    await db.insert('item_forms', {'name': 'حقن'});
    await db.insert('item_forms', {'name': 'تحاميل'});
  }

  // --- ✅ جديد: دالة لإنشاء جدول أوامر الصرف ---
  Future<void> _createDisbursementOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE disbursement_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL UNIQUE,
        order_date TEXT NOT NULL,
        issuing_entity TEXT,
        beneficiary_id INTEGER,
        status TEXT NOT NULL,
        notes TEXT,
        image_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
  // --- ✅ جديد: دالة لإنشاء جدول المستفيدين ---
  Future<void> _createBeneficiariesTable(Database db) async {
    await db.execute('''
      CREATE TABLE beneficiaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT,
        identifier TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
  // --- ✅ جديد: دالة لإنشاء جدول عمليات الصرف ---
  Future<void> _createDisbursementTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE disbursement_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_date TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity_disbursed INTEGER NOT NULL,
        order_id INTEGER NOT NULL,
        user_id INTEGER, -- للمستقبل
        notes TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id),
        FOREIGN KEY (order_id) REFERENCES disbursement_orders (id)
      )
    ''');
  }
  // --- ✅ جديد: دالة لإنشاء جدول عمليات الإرجاع ---
  Future<void> _createReturnTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE return_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_date TEXT NOT NULL,
        original_transaction_id INTEGER NOT NULL,
        quantity_returned INTEGER NOT NULL,
        reason TEXT,
        user_id INTEGER,
        FOREIGN KEY (original_transaction_id) REFERENCES disbursement_transactions (id)
      )
    ''');
  }



}
