import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:medistock/app/data/local/models/item_model.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';


class ItemReportGenerator {
  static Future<void> exportToPdf(List<ItemModel> items) async {
    final pdf = pw.Document();

    // --- ✅ الحل لمشكلة الحروف المتداخلة: استخدام PdfGoogleFonts ---
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    // لنفترض وجود شعار في هذا المسار
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_icon.png')).buffer
          .asUint8List(),
    );

    // --- حساب الملخصات ---
    final totalItems = items.length;
    final expiredCount = items.where((i) => i.expiryDate.isBefore(DateTime.now())).length;
    final lowStockCount = items.where((i) => i.quantity > 0 && i.quantity <= i.alertLimit).length;

    // --- بناء صفحات التقرير ---
    pdf.addPage(
      pw.MultiPage(
        // --- ✅ الحل لمشكلة الصفحة الصغيرة: استخدام الوضع الأفقي ---
        pageFormat: PdfPageFormat.a4.portrait,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        header: (context) => _buildHeader(logoImage),
        build: (context) => [
          _buildReportTitle(),
          pw.SizedBox(height: 20),
          _buildSummary(totalItems, expiredCount, lowStockCount),
          pw.SizedBox(height: 20),
          _buildItemsTable(items),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // --- حفظ وفتح الملف ---
    final Uint8List pdfBytes = await pdf.save();
    String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'الرجاء تحديد مسار لحفظ التقرير',
        fileName: 'report_items_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // 3. التحقق مما إذا كان المستخدم قد اختار مسارًا
    if (outputFile != null) {
      // إذا لم يكن الامتداد موجودًا، قم بإضافته
      if (!outputFile.endsWith('.pdf')) {
        outputFile += '.pdf';
      }

// 4. كتابة البايتات في الملف الذي اختاره المستخدم
      final file = File(outputFile);
      await file.writeAsBytes(pdfBytes);

      // 5. (اختياري) فتح الملف بعد حفظه
      await OpenFile.open(file.path);
    }
  }
  // --- دوال بناء أجزاء التقرير (متوافقة مع الهوية البصرية) ---

  static pw.Widget _buildHeader(pw.MemoryImage logo) {
    return pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 15),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey, width: 1.5))),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
            pw.Text('نظام إدارة المخزون MediStock',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
        pw.SizedBox(height: 5),
              pw.Text('تقرير حالة المخزون',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
            ),
              pw.SizedBox(height: 60, width: 60, child: pw.Image(logo)),
            ],
        ),
    );
  }

  static pw.Widget _buildReportTitle() {
    return pw.Column(
        children: [
        pw.SizedBox(height: 15),
    pw.Text(
    'تقرير مخزون الأصناف',
    style: pw.TextStyle(
    fontSize: 22,
    fontWeight: pw
    .
    FontWeight
    .bold,
    color: PdfColors.blueGrey800),
    ),
    pw.SizedBox(height: 5),
    pw.Text(
    'تاريخ التقرير: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
    ),
        ],
    );
  }

  static pw.Widget _buildSummary(int totalItems, int expiredCount,
      int lowStockCount) {
    return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
            color: PdfColors.blue.shade(0.05),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue200)),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
            _buildSummaryItem('إجمالي الأصناف', totalItems.toDouble(),
            isCurrency: false),
        _buildSummaryItem('أصناف منتهية', expiredCount.toDouble(), isCurrency: false),
              _buildSummaryItem(
                  'أصناف على وشك النفاذ', lowStockCount.toDouble(),
                  isCurrency: false),
            ],
        ),
    );
  }

  static pw.Widget _buildSummaryItem

  (

  String label, double value, {

  bool

  isCurrency

  = true}) {
    final formattedValue = isCurrency
        ? '${NumberFormat.decimalPattern('ar').format(value)}'
        : value.toInt().toString();

    return pw.Column(
        children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 4),
          pw.Text(
            formattedValue,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
                color: PdfColors.blue700),
          ),
        ],
    );
  }

  static pw.Widget _buildItemsTable(List<ItemModel> items) {
    // تم تكييف العناوين لتناسب بيانات الأصناف
    final headers = [
      'الوحدة',       // <-- جديد
      'الكمية',
      'تاريخ الانتهاء',
      'رقم التشغيلة',
      'كود الصنف',   // <-- جديد
      'الاسم العلمي',
      'الاسم التجارى'
    ];

    final data = items.map((item) {
      return [
        item.unit ?? '-',                   // <-- جديد
        item.quantity.toString(),
        DateFormat('yyyy-MM-dd').format(item.expiryDate),
        item.batchNumber ?? '-',
        item.itemCode ?? '-',               // <-- جديد
        item.scientificName ?? '-',
        item.name,
      ];
    }).toList();

    return pw.Table.fromTextArray(
        cellAlignment: pw.Alignment.centerRight,
        headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
        rowDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
        headers: headers,
        data: data,
        // --- ✅ الحل لمشكلة عرض الأعمدة ---
        columnWidths: {
          0: const pw.FlexColumnWidth(2.5), // الوحدة
          1: const pw.FlexColumnWidth(2.2), // الكمية
          2: const pw.FlexColumnWidth(5),   // تاريخ الانتهاء
          3: const pw.FlexColumnWidth(4),   // رقم التشغيلة
          4: const pw.FlexColumnWidth(4),   // كود الصنف
          5: const pw.FlexColumnWidth(4),   // الاسم العلمي
          6: const pw.FlexColumnWidth(4.5), // الاسم التجاري
        },
        cellAlignments: {
          0: pw.Alignment.center, // الوحدة
          1: pw.Alignment.center, // الكمية
          2: pw.Alignment.center, // تاريخ الانتهاء
          3: pw.Alignment.center, // رقم التشغيلة
          4: pw.Alignment.center, // كود الصنف
          // الأسماء تبقى محاذاة لليمين (الافتراضي)
        });
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
            'صفحة ${context.pageNumber} من ${context
                .pagesCount} - © نظام MediStock',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
    );
  }
}