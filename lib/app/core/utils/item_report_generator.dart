import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:medistock/app/data/local/models/item_model.dart';

import 'package:file_picker/file_picker.dart';
import '../../data/local/models/report_settings_model.dart';
import '../../data/local/providers/transaction_provider.dart'; // ✅ Added for DTO

class ItemReportGenerator {
  // --- Helper to load assets for Isolates ---
  static Future<Map<String, dynamic>> _loadAssets(
    ReportSettingsModel settings,
  ) async {
    final fontData = (await rootBundle.load(
      'assets/fonts/Amiri-Regular.ttf',
    )).buffer.asUint8List();
    final boldFontData = (await rootBundle.load(
      'assets/fonts/Amiri-Bold.ttf',
    )).buffer.asUint8List();

    Uint8List? mainImageBytes;
    if (settings.logoPath != null &&
        settings.logoPath!.isNotEmpty &&
        File(settings.logoPath!).existsSync()) {
      try {
        mainImageBytes = File(settings.logoPath!).readAsBytesSync();
      } catch (_) {}
    }
    if (mainImageBytes == null) {
      try {
        mainImageBytes = (await rootBundle.load(
          'assets/images/main.jpeg',
        )).buffer.asUint8List();
      } catch (_) {}
    }

    Uint8List? sideImageBytes;
    if (settings.headerRightType == 'image' &&
        settings.headerRightImagePath != null &&
        settings.headerRightImagePath!.isNotEmpty &&
        File(settings.headerRightImagePath!).existsSync()) {
      try {
        sideImageBytes = File(settings.headerRightImagePath!).readAsBytesSync();
      } catch (_) {}
    }

    return {
      'fontData': fontData,
      'boldFontData': boldFontData,
      'mainImageBytes': mainImageBytes,
      'sideImageBytes': sideImageBytes,
    };
  }

  static Future<Uint8List> _generatePdfIsolate(
    Map<String, dynamic> args,
  ) async {
    final items = args['items'] as List<ItemModel>;
    final settings = ReportSettingsModel.fromJson(args['settings']);
    final recipientSuffix = args['recipientSuffix'] as String;
    final assets = args['assets'] as Map<String, dynamic>;

    final pdf = pw.Document();
    final font = pw.Font.ttf(
      (assets['fontData'] as Uint8List).buffer.asByteData(),
    );
    final boldFont = pw.Font.ttf(
      (assets['boldFontData'] as Uint8List).buffer.asByteData(),
    );

    pw.MemoryImage? mainImage;
    if (assets['mainImageBytes'] != null)
      mainImage = pw.MemoryImage(assets['mainImageBytes'] as Uint8List);

    pw.MemoryImage? sideImage;
    if (assets['sideImageBytes'] != null)
      sideImage = pw.MemoryImage(assets['sideImageBytes'] as Uint8List);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: settings.marginTop * PdfPageFormat.cm,
          marginBottom: settings.marginBottom * PdfPageFormat.cm,
          marginLeft: settings.marginLeft * PdfPageFormat.cm,
          marginRight: settings.marginRight * PdfPageFormat.cm,
        ),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildAdvancedBody(settings, boldFont, font, recipientSuffix),
          pw.SizedBox(height: 10),
          settings.tableColumnMode == 'dual'
              ? _buildDualColumnTable(items)
              : _buildItemsTable(items),
        ],
        footer: (context) => _buildFooter(context, settings, boldFont),
        header: (context) =>
            _buildAdvancedHeader(mainImage, sideImage, settings, boldFont),
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generatePdf(
    List<ItemModel> items, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم', // ✅ Added
  }) async {
    final effectiveSettings = settings ?? ReportSettingsModel.defaults();
    final assets = await _loadAssets(effectiveSettings);

    return compute(_generatePdfIsolate, {
      'items': items,
      'settings': effectiveSettings.toJson(),
      'recipientSuffix': recipientSuffix,
      'assets': assets,
    });
  }

  static Future<void> exportToPdf(
    List<ItemModel> items, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم', // ✅ Added
  }) async {
    // 1. Generate PDF Bytes
    final Uint8List pdfBytes = await generatePdf(
      items,
      settings: settings,
      recipientSuffix: recipientSuffix,
    );

    // 2. Ask user for save location
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'الرجاء تحديد مسار لحفظ التقرير',
      fileName:
          'report_items_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
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

  static pw.Widget _buildAdvancedHeader(
    pw.MemoryImage? mainImage,
    pw.MemoryImage? sideImage,
    ReportSettingsModel settings,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2)), // Thick line
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Right Side - Image or Text
          // Right Side - Image or Text
          pw.Expanded(
            child: (settings.headerRightType == 'image' && sideImage != null)
                ? pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Transform.translate(
                      offset: PdfPoint(
                        settings.headerRightImageDx,
                        settings.headerRightImageDy,
                      ),
                      child: pw.SizedBox(
                        width: settings.headerRightImageWidth,
                        height: settings.headerRightImageHeight,
                        child: pw.Image(sideImage, fit: pw.BoxFit.contain),
                      ),
                    ),
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: settings.headerRightLines
                        .map((line) => _buildReportLine(line, font))
                        .toList(),
                  ),
          ),

          // Center (main.jpeg) - الصورة الرئيسية دائماً
          if (mainImage != null) ...[
            pw.SizedBox(width: 15),
            pw.SizedBox(height: 80, width: 80, child: pw.Image(mainImage)),
            pw.SizedBox(width: 15),
          ],

          // Left Side
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: settings.headerLeftLines
                  .map((line) => _buildReportLine(line, font))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportLine(ReportLine line, pw.Font font) {
    pw.TextAlign textAlign;
    switch (line.align) {
      case 'right':
        textAlign = pw.TextAlign.right;
        break;
      case 'left':
        textAlign = pw.TextAlign.left;
        break;
      case 'center':
      default:
        textAlign = pw.TextAlign.center;
        break;
    }

    return pw.Opacity(
      opacity: line.text.isEmpty ? 0 : 1,
      child: pw.Text(
        line.text.isEmpty
            ? ' '
            : line.text, // Ensure empty lines take space if needed or just handle empty
        textAlign: textAlign,
        style: pw.TextStyle(
          font: font,
          fontSize: line.fontSize,
          fontWeight: line.isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          decoration: line.isUnderlined ? pw.TextDecoration.underline : null,
        ),
      ),
    );
  }

  static pw.Widget _buildAdvancedBody(
    ReportSettingsModel settings,
    pw.Font boldFont,
    pw.Font regularFont,
    String recipientSuffix, // ✅ Added
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.stretch, // Allow lines to align themselves
      children: [
        pw.SizedBox(height: 10),
        _buildReportLine(settings.reportTitle, regularFont),
        pw.SizedBox(height: 20),

        // ✅ FIXED: Recipient Name (Right) and Suffix (Left)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: _buildReportLine(settings.recipientTitle, regularFont),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(left: settings.recipientSuffixMargin),
              child: pw.Text(
                recipientSuffix,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: settings
                      .recipientTitle
                      .fontSize, // Use same size as title
                  fontWeight: settings.recipientTitle.isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal, // Match boldness
                ),
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 10),
        _buildReportLine(settings.introText, regularFont),
        pw.SizedBox(height: 10),
        _buildReportLine(settings.listDescription, regularFont),
        pw.SizedBox(height: 15),
        _buildReportLine(settings.closingText, regularFont),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildSummary(
    int totalItems,
    int expiredCount,
    int lowStockCount,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue.shade(0.05),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'إجمالي الأصناف',
            totalItems.toDouble(),
            isCurrency: false,
          ),
          _buildSummaryItem(
            'أصناف منتهية',
            expiredCount.toDouble(),
            isCurrency: false,
          ),
          _buildSummaryItem(
            'أصناف على وشك النفاذ',
            lowStockCount.toDouble(),
            isCurrency: false,
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> _generateBeneficiaryPdfIsolate(
    Map<String, dynamic> args,
  ) async {
    final transactions = args['transactions'] as List<BeneficiaryReportItem>;
    final settings = ReportSettingsModel.fromJson(args['settings']);
    final recipientSuffix = args['recipientSuffix'] as String;
    final assets = args['assets'] as Map<String, dynamic>;

    final pdf = pw.Document();
    final font = pw.Font.ttf(
      (assets['fontData'] as Uint8List).buffer.asByteData(),
    );
    final boldFont = pw.Font.ttf(
      (assets['boldFontData'] as Uint8List).buffer.asByteData(),
    );

    pw.MemoryImage? mainImage;
    if (assets['mainImageBytes'] != null)
      mainImage = pw.MemoryImage(assets['mainImageBytes'] as Uint8List);

    pw.MemoryImage? sideImage;
    if (assets['sideImageBytes'] != null)
      sideImage = pw.MemoryImage(assets['sideImageBytes'] as Uint8List);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: settings.marginTop * PdfPageFormat.cm,
          marginBottom: settings.marginBottom * PdfPageFormat.cm,
          marginLeft: settings.marginLeft * PdfPageFormat.cm,
          marginRight: settings.marginRight * PdfPageFormat.cm,
        ),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildAdvancedBody(settings, boldFont, font, recipientSuffix),
          pw.SizedBox(height: 10),
          settings.tableColumnMode == 'dual'
              ? _buildDualColumnBeneficiaryTable(transactions)
              : _buildBeneficiaryTable(transactions),
        ],
        footer: (context) => _buildFooter(context, settings, boldFont),
        header: (context) =>
            _buildAdvancedHeader(mainImage, sideImage, settings, boldFont),
      ),
    );
    return pdf.save();
  }

  // --- ✅ جديد: توليد تقرير المستفيد ---
  static Future<Uint8List> generateBeneficiaryReportPdf(
    List<BeneficiaryReportItem> transactions,
    String beneficiaryName, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم',
  }) async {
    final effectiveSettings = settings ?? ReportSettingsModel.defaults();
    var tempSettings = ReportSettingsModel.fromJson(effectiveSettings.toJson());
    // We override the text of recipientTitle to be the Beneficiary Name
    tempSettings.recipientTitle.text = beneficiaryName;

    final assets = await _loadAssets(effectiveSettings);

    return compute(_generateBeneficiaryPdfIsolate, {
      'transactions': transactions,
      'settings': tempSettings.toJson(),
      'recipientSuffix': recipientSuffix,
      'assets': assets,
    });
  }

  // --- ✅ جديد: توليد تقرير خاص بأمر صرف معين (فاتورة/سند) ---
  static Future<Uint8List> generateOrderReportPdf(
    List<BeneficiaryReportItem> transactions,
    String beneficiaryName,
    String orderNumber, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم',
  }) async {
    final effectiveSettings = settings ?? ReportSettingsModel.defaults();
    var tempSettings = ReportSettingsModel.fromJson(effectiveSettings.toJson());
    // Override titles for Invoice style
    tempSettings.recipientTitle.text = beneficiaryName;

    final assets = await _loadAssets(effectiveSettings);

    return compute(_generateBeneficiaryPdfIsolate, {
      'transactions': transactions,
      'settings': tempSettings.toJson(),
      'recipientSuffix': recipientSuffix,
      'assets': assets,
    });
  }

  static pw.Widget _buildDualColumnBeneficiaryTable(
    List<BeneficiaryReportItem> transactions,
  ) {
    // Manually Reverse Order for RTL simulation in LTR Table
    // Visual Order on Paper (RTL): [  Left Item (Cols 0-4) ]  [ Right Item (Cols 5-9) ]
    // Desired Cols in Block (RTL): Notes | Qty | Unit | Name | M
    // Actual LTR Cols in Block:    Notes | Qty | Unit | Name | M
    // (Wait, LTR: Col 0 is Left. So [Notes...M] renders: Notes(L)..M(R).
    //  Visually: Notes | Qty | Unit | Name | M.
    //  RTL Reader sees: M (End) -> Name -> Unit -> Qty -> Notes (Start).
    //  User said M is at "End" (Left?).
    //  If I want M at Right side of Block: Block should be [Notes, Qty, Unit, Name, M].
    //  Then M is at Right.
    //  If User said M is at End (Left), it implies my previous [M, Name...Notes] put M at Left.
    //  So [Notes...M] puts M at Right. Correct.

    final baseHeaders = ['ملاحظات', 'الكمية', 'الوحدة', 'اسم الصنف', 'م'];
    final headers = [...baseHeaders, ...baseHeaders];

    // Split data
    final half = (transactions.length / 2).ceil();
    final data = <List<String>>[];

    for (int i = 0; i < half; i++) {
      // Right Side Item (First Half) -> Goes to Cols 5-9 (Visual Right)
      final itemRight = transactions[i];
      final rowRight = [
        itemRight.notes ?? '',
        itemRight.quantity.toString(),
        itemRight.unit ?? '-',
        itemRight.itemName,
        (i + 1).toString(),
      ];

      // Left Side Item (Second Half) -> Goes to Cols 0-4 (Visual Left)
      List<String> rowLeft;
      if (i + half < transactions.length) {
        final itemLeft = transactions[i + half];
        rowLeft = [
          itemLeft.notes ?? '',
          itemLeft.quantity.toString(),
          itemLeft.unit ?? '-',
          itemLeft.itemName,
          (i + half + 1).toString(),
        ];
      } else {
        rowLeft = ['', '', '', '', ''];
      }

      // Add: [Left Block, Right Block] -> [rowLeft, rowRight]
      data.add([...rowLeft, ...rowRight]);
    }

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      // rowDecoration removed to avoid conflict
      headers: headers,
      data: data,
      columnWidths: {
        // Left Side (Cols 0-4)
        0: const pw.FlexColumnWidth(3), // ملاحظات
        1: const pw.FlexColumnWidth(1.5), // الكمية
        2: const pw.FlexColumnWidth(1.5), // الوحدة
        3: const pw.FlexColumnWidth(4), // اسم الصنف
        4: const pw.FlexColumnWidth(0.8), // م
        // Right Side (Cols 5-9)
        5: const pw.FlexColumnWidth(3), // ملاحظات
        6: const pw.FlexColumnWidth(1.5), // الكمية
        7: const pw.FlexColumnWidth(1.5), // الوحدة
        8: const pw.FlexColumnWidth(4), // اسم الصنف
        9: const pw.FlexColumnWidth(0.8), // م
      },
      cellAlignments: {
        // All Right Aligned or Center?
        // Notes: Right
        0: pw.Alignment.centerRight,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,

        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.centerRight,
        9: pw.Alignment.center,
      },
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 1.0),
    );
  }

  static pw.Widget _buildBeneficiaryTable(
    List<BeneficiaryReportItem> transactions, {
    int startIndex = 1,
  }) {
    // Single Table - also simulate RTL manually for consistency
    // Visual RTL: Notes | Qty | Unit | Name | M
    // LTR Table: Col 0..4

    final headers = ['ملاحظات', 'الكمية', 'الوحدة', 'اسم الصنف', 'م'];

    final data = transactions.asMap().entries.map((entry) {
      final index = entry.key;
      final t = entry.value;
      return [
        t.notes ?? '',
        t.quantity.toString(),
        t.unit ?? '-',
        t.itemName,
        (startIndex + index).toString(),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      // rowDecoration removed
      headers: headers,
      data: data,
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // ملاحظات
        1: const pw.FlexColumnWidth(1.5), // الكمية
        2: const pw.FlexColumnWidth(1.5), // الوحدة
        3: const pw.FlexColumnWidth(4), // اسم الصنف
        4: const pw.FlexColumnWidth(0.8), // م
      },
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 1.0),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    double value, {

    bool isCurrency = true,
  }) {
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
            color: PdfColors.blue700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDualColumnTable(List<ItemModel> items) {
    // Manually Reverse Order for RTL simulation
    // Desired Cols (RTL): Notes | Qty | Unit | Name | M
    // Actual LTR Cols:    Notes | Qty | Unit | Name | M

    final baseHeaders = ['ملاحظات', 'الكمية', 'الوحدة', 'اسم الصنف', 'م'];
    final headers = [...baseHeaders, ...baseHeaders];

    // Split data
    final half = (items.length / 2).ceil();
    final data = <List<String>>[];

    for (int i = 0; i < half; i++) {
      // Right Side Item (First Half) -> Cols 5-9
      final itemRight = items[i];
      final rowRight = [
        itemRight.notes ?? '',
        itemRight.quantity.toString(),
        itemRight.unit ?? '-',
        itemRight.name,
        (i + 1).toString(),
      ];

      // Left Side Item (Second Half) -> Cols 0-4
      List<String> rowLeft;
      if (i + half < items.length) {
        final itemLeft = items[i + half];
        rowLeft = [
          itemLeft.notes ?? '',
          itemLeft.quantity.toString(),
          itemLeft.unit ?? '-',
          itemLeft.name,
          (i + half + 1).toString(),
        ];
      } else {
        rowLeft = ['', '', '', '', ''];
      }

      data.add([...rowLeft, ...rowRight]);
    }

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      headers: headers,
      data: data,
      columnWidths: {
        // Left Side
        0: const pw.FlexColumnWidth(3), // ملاحظات
        1: const pw.FlexColumnWidth(1.5), // الكمية
        2: const pw.FlexColumnWidth(1.5), // الوحدة
        3: const pw.FlexColumnWidth(4), // اسم الصنف
        4: const pw.FlexColumnWidth(0.8), // م
        // Right Side
        5: const pw.FlexColumnWidth(3),
        6: const pw.FlexColumnWidth(1.5),
        7: const pw.FlexColumnWidth(1.5),
        8: const pw.FlexColumnWidth(4),
        9: const pw.FlexColumnWidth(0.8),
      },
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.centerRight,
        9: pw.Alignment.center,
      },
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 1.0),
    );
  }

  static pw.Widget _buildItemsTable(List<ItemModel> items) {
    // Single Table - Unified 5 Cols Reversed
    // Cols: Notes | Qty | Unit | Name | M

    final headers = ['ملاحظات', 'الكمية', 'الوحدة', 'اسم الصنف', 'م'];

    final data = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return [
        item.notes ?? '',
        item.quantity.toString(),
        item.unit ?? '-',
        item.name,
        (index + 1).toString(),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      headers: headers,
      data: data,
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // ملاحظات
        1: const pw.FlexColumnWidth(1.5), // الكمية
        2: const pw.FlexColumnWidth(1.5), // الوحدة
        3: const pw.FlexColumnWidth(4), // اسم الصنف
        4: const pw.FlexColumnWidth(0.8), // م
      },
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 1.0),
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    ReportSettingsModel settings,
    pw.Font font,
  ) {
    // Check whether to show summary on the first or last page
    final bool showSignatures = settings.signaturesOnFirstPage == true
        ? context.pageNumber == 1
        : context.pageNumber == context.pagesCount;

    return pw.Column(
      children: [
        // Draw Signatories based on the settings
        if (showSignatures) ...[
          pw.SizedBox(height: 20),
          _buildSignatures(settings.signatures, font),
          pw.SizedBox(height: 20),
        ],
        // Page Number
        pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  // --- ✅ جديد: بناء التوقيعات بالنظام الجديد (3 أسطر) ---
  static pw.Widget _buildSignatures(
    List<SignatureModel> signatures,
    pw.Font font,
  ) {
    if (signatures.isEmpty) return pw.Container();

    // Create a list of columns, one for each signature
    final sigWidgets = signatures.map((sig) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (sig.rank.isNotEmpty)
            pw.Text(
              sig.rank,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          if (sig.name.isNotEmpty)
            pw.Text(sig.name, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
            sig.title,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      );
    }).toList();

    // Wrap in Row with SpaceEvenly to distribute them across the page
    // RTL note: Row renders LTR by default. For Arabic Right-to-Left,
    // usually the first signature in the list is the most important (Rightmost).
    // So we might need to reverse the list OR rely on row direction if we can set it.
    // In standard PDF rendering, Row with alignment handles distribution.
    // Let's assume the user enters them in Order (Right to Left).
    // If not, we can reverse: sigWidgets = sigWidgets.reversed.toList();
    // Conventionally, High ranking is Right.

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: sigWidgets, // ✅ Removed reversed to match View logic
    );
  }
}
