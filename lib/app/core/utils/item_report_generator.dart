import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:medistock/app/data/local/models/item_model.dart';

import 'package:file_picker/file_picker.dart';
import '../../data/local/models/report_settings_model.dart';
import '../../data/local/providers/transaction_provider.dart'; // ✅ Added for DTO

class ItemReportGenerator {
  static Future<Uint8List> generatePdf(
    List<ItemModel> items, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم', // ✅ Added
  }) async {
    // If no settings provided, use defaults (or you could load them here via service)
    final effectiveSettings = settings ?? ReportSettingsModel.defaults();

    final pdf = pw.Document();

    // --- ✅ الحل لمشكلة الحروف المتداخلة: استخدام الخط المحلي (Amiri) ---
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final boldFont = pw.Font.ttf(boldFontData);

    // --- تحميل الشعار من الإعدادات أو الافتراضي ---
    pw.MemoryImage? logoImage;
    if (effectiveSettings.logoPath != null &&
        File(effectiveSettings.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(
        File(effectiveSettings.logoPath!).readAsBytesSync(),
      );
    } else {
      // fallback if needed, or null
      try {
        logoImage = pw.MemoryImage(
          (await rootBundle.load(
            'assets/images/logo_icon.png',
          )).buffer.asUint8List(),
        );
      } catch (_) {}
    }

    // --- بناء صفحات التقرير ---
    pdf.addPage(
      pw.MultiPage(
        // --- ✅ الحل لمشكلة الصفحة الصغيرة: استخدام الوضع الأفقي ---
        pageFormat: PdfPageFormat.a4.portrait,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildAdvancedBody(
            effectiveSettings,
            boldFont,
            font,
            recipientSuffix,
          ), // ✅ Pass suffix
          pw.SizedBox(height: 10),
          _buildItemsTable(items),
        ],
        footer: (context) => _buildFooter(context, effectiveSettings, boldFont),
        header: (context) =>
            _buildAdvancedHeader(logoImage, effectiveSettings, boldFont),
      ),
    );

    return pdf.save();
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
    pw.MemoryImage? logo,
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
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Right Side
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: settings.headerRightLines
                  .map((line) => _buildReportLine(line, font))
                  .toList(),
            ),
          ),

          // Center (Logo) - Perfectly Centered with Spacing
          if (logo != null) ...[
            pw.SizedBox(width: 15),
            pw.SizedBox(height: 80, width: 80, child: pw.Image(logo)),
            pw.SizedBox(width: 15),
          ],

          // Left Side
          pw.Expanded(
            child: pw.Column(
              // ✅ FIXED: Align to START (Right) so items hug the center/logo side
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
            pw.Text(
              recipientSuffix,
              style: pw.TextStyle(
                font: regularFont,
                fontSize:
                    settings.recipientTitle.fontSize, // Use same size as title
                fontWeight: settings.recipientTitle.isBold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal, // Match boldness
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

  // دالة جديدة للتوقيعات
  static pw.Widget _buildSignatories(
    List<ReportLine> signatories,
    pw.Font font,
  ) {
    if (signatories.isEmpty) return pw.Container();
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: signatories.map((sig) {
        return pw.Column(
          children: [
            pw.Text(
              sig.text,
              style: pw.TextStyle(
                font: font,
                fontSize: sig.fontSize,
                fontWeight: sig.isBold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
            pw.SizedBox(height: 40), // مسافة للتوقيع
            pw.Text(
              '....................',
              style: const pw.TextStyle(color: PdfColors.grey),
            ),
          ],
        );
      }).toList(),
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

  // --- ✅ جديد: توليد تقرير المستفيد ---
  static Future<Uint8List> generateBeneficiaryReportPdf(
    List<BeneficiaryReportItem> transactions,
    String beneficiaryName, {
    ReportSettingsModel? settings,
    String recipientSuffix = 'المحترم',
  }) async {
    final effectiveSettings = settings ?? ReportSettingsModel.defaults();
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final boldFont = pw.Font.ttf(boldFontData);

    // Load Logo
    pw.MemoryImage? logoImage;
    if (effectiveSettings.logoPath != null &&
        File(effectiveSettings.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(
        File(effectiveSettings.logoPath!).readAsBytesSync(),
      );
    } else {
      try {
        logoImage = pw.MemoryImage(
          (await rootBundle.load(
            'assets/images/logo_icon.png',
          )).buffer.asUint8List(),
        );
      } catch (_) {}
    }

    // Override Recipient Title temporarily for this report if needed,
    // Or we assume the user sets the Beneficiary Name in the "Recipient" field dynamically?
    // BETTER APPROACH: We use the passed `beneficiaryName` as the recipient title in the body.
    // Creating a copy of settings to inject the specific beneficiary name into the "Recipient" slot for this print.
    var tempSettings = ReportSettingsModel.fromJson(effectiveSettings.toJson());
    // We override the text of recipientTitle to be the Beneficiary Name
    // BUT we preserve the styling.
    tempSettings.recipientTitle.text = beneficiaryName;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildAdvancedBody(tempSettings, boldFont, font, recipientSuffix),
          pw.SizedBox(height: 10),
          _buildBeneficiaryTable(transactions),
        ],
        footer: (context) => _buildFooter(context, effectiveSettings, boldFont),
        header: (context) =>
            _buildAdvancedHeader(logoImage, effectiveSettings, boldFont),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildBeneficiaryTable(
    List<BeneficiaryReportItem> transactions,
  ) {
    final headers = ['ملاحظات', 'الوحدة', 'الكمية', 'الصنف', 'التاريخ'];

    final data = transactions.map((t) {
      return [
        t.notes ?? '-',
        t.unit ?? '-',
        t.quantity.toString(),
        t.itemName,
        DateFormat('yyyy-MM-dd').format(t.date),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      headers: headers,
      data: data,
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // ملاحظات
        1: const pw.FlexColumnWidth(2), // الوحدة
        2: const pw.FlexColumnWidth(2), // الكمية
        3: const pw.FlexColumnWidth(4), // الصنف
        4: const pw.FlexColumnWidth(3), // التاريخ
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
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

  static pw.Widget _buildItemsTable(List<ItemModel> items) {
    // تم تكييف العناوين لتناسب بيانات الأصناف
    final headers = [
      'الوحدة', // <-- جديد
      'الكمية',
      'تاريخ الانتهاء',
      'رقم التشغيلة',
      'كود الصنف', // <-- جديد
      'الاسم العلمي',
      'الاسم التجارى',
    ];

    final data = items.map((item) {
      return [
        item.unit ?? '-', // <-- جديد
        item.quantity.toString(),
        DateFormat('yyyy-MM-dd').format(item.expiryDate),
        item.batchNumber ?? '-',
        item.itemCode ?? '-', // <-- جديد
        item.scientificName ?? '-',
        item.name,
      ];
    }).toList();

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      headers: headers,
      data: data,
      // --- ✅ الحل لمشكلة عرض الأعمدة ---
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // الوحدة
        1: const pw.FlexColumnWidth(2.2), // الكمية
        2: const pw.FlexColumnWidth(5), // تاريخ الانتهاء
        3: const pw.FlexColumnWidth(4), // رقم التشغيلة
        4: const pw.FlexColumnWidth(4), // كود الصنف
        5: const pw.FlexColumnWidth(4), // الاسم العلمي
        6: const pw.FlexColumnWidth(4.5), // الاسم التجاري
      },
      cellAlignments: {
        0: pw.Alignment.center, // الوحدة
        1: pw.Alignment.center, // الكمية
        2: pw.Alignment.center, // تاريخ الانتهاء
        3: pw.Alignment.center, // رقم التشغيلة
        4: pw.Alignment.center, // كود الصنف
        // الأسماء تبقى محاذاة لليمين (الافتراضي)
      },
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    ReportSettingsModel settings,
    pw.Font font,
  ) {
    return pw.Column(
      children: [
        // Draw Signatories ONLY on the last page
        if (context.pageNumber == context.pagesCount) ...[
          pw.SizedBox(height: 20),
          _buildSignatories(settings.signatories, font),
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
}
