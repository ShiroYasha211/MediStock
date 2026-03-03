import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../../../data/local/models/report_settings_model.dart';

// تعريف نوع الدالة التي ستقوم بتوليد التقرير بناءً على الإعدادات المعدلة
typedef PdfBuilder =
    Future<Uint8List> Function(
      ReportSettingsModel settings,
      String recipientSuffix,
    );

class PrintPreviewDialog extends StatefulWidget {
  final ReportSettingsModel initialSettings;
  final PdfBuilder pdfBuilder;
  final String initialRecipientName; // To set default Recipient Name

  const PrintPreviewDialog({
    super.key,
    required this.initialSettings,
    required this.pdfBuilder,
    this.initialRecipientName = '',
  });

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  late ReportSettingsModel currentSettings;

  // Controllers for Text Fields
  late TextEditingController titleController;
  late TextEditingController recipientController;
  late TextEditingController suffixController;
  late TextEditingController introController;
  late TextEditingController descController;
  late TextEditingController closingController;

  @override
  void initState() {
    super.initState();
    // 1. Clone settings
    currentSettings = ReportSettingsModel.fromJson(
      widget.initialSettings.toJson(),
    );

    // 2. If a specific recipient name was passed (e.g. Beneficiary Name), set it.
    // Otherwise keep what's in settings.
    if (widget.initialRecipientName.isNotEmpty) {
      currentSettings.recipientTitle.text = widget.initialRecipientName;
    }

    // 3. Initialize Controllers
    titleController = TextEditingController(
      text: currentSettings.reportTitle.text,
    );
    recipientController = TextEditingController(
      text: currentSettings.recipientTitle.text,
    );
    suffixController = TextEditingController(text: 'المحترم');
    introController = TextEditingController(
      text: currentSettings.introText.text,
    );
    descController = TextEditingController(
      text: currentSettings.listDescription.text,
    );
    closingController = TextEditingController(
      text: currentSettings.closingText.text,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    recipientController.dispose();
    suffixController.dispose();
    introController.dispose();
    descController.dispose();
    closingController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    setState(() {
      currentSettings.reportTitle.text = titleController.text;
      currentSettings.recipientTitle.text = recipientController.text;
      currentSettings.introText.text = introController.text;
      currentSettings.listDescription.text = descController.text;
      currentSettings.closingText.text = closingController.text;
      // Signatories updates are handled directly on the list via the edit dialog
    });
    Get.back(); // Close edit dialog
  }

  // --- إدارة الموقعين (Signatories) ---
  void _addSignatory() {
    setState(() {
      currentSettings.signatures.add(SignatureModel(title: 'توقيع جديد'));
    });
    Get.back();
    _showEditDialog();
  }

  void _removeSignatory(int index) {
    setState(() {
      currentSettings.signatures.removeAt(index);
    });
    Get.back();
    _showEditDialog();
  }

  // Helper to update signature fields
  void _updateSignatory(int index, String field, String val) {
    final sig = currentSettings.signatures[index];
    if (field == 'rank') sig.rank = val;
    if (field == 'name') sig.name = val;
    if (field == 'title') sig.title = val;
  }

  void _showEditDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500, // Wider for signatories
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            children: [
              Text(
                'تعديل نصوص وتنسيق التقرير',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSectionHeader('بيانات الترويسة'),
                      _buildField('عنوان التقرير', titleController),
                      _buildField(
                        'المخاطب (الاسم واللقب)',
                        recipientController,
                      ),
                      _buildField(
                        'اللقب الختامي (مثل: المحترم)',
                        suffixController,
                      ),
                      // ✅ Slider for recipientSuffixMargin
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StatefulBuilder(
                          builder: (context, setStateBuilder) {
                            return Row(
                              children: [
                                const Text('إزاحة اللقب الختامي:'),
                                Expanded(
                                  child: Slider(
                                    min: 0,
                                    max: 300,
                                    divisions: 30,
                                    value: currentSettings.recipientSuffixMargin
                                        .clamp(0.0, 300.0),
                                    onChanged: (val) {
                                      setStateBuilder(() {
                                        currentSettings.recipientSuffixMargin =
                                            val;
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  currentSettings.recipientSuffixMargin
                                      .toStringAsFixed(0),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      _buildField('المقدمة (التحية)', introController),
                      _buildField('وصف القائمة', descController),
                      _buildField('الخاتمة', closingController),
                      const SizedBox(height: 20),
                      _buildSectionHeader('الموقعون (سلسلة التوقيعات)'),
                      StatefulBuilder(
                        builder: (context, setStateBuilder) {
                          return SwitchListTile(
                            title: const Text(
                              'إظهار التوقيعات في الصفحة الأولى بدلاً من الأخيرة',
                              style: TextStyle(fontSize: 14),
                            ),
                            value:
                                currentSettings.signaturesOnFirstPage == true,
                            onChanged: (val) {
                              setStateBuilder(() {
                                currentSettings.signaturesOnFirstPage = val;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      ...currentSettings.signatures.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final sig = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: sig.rank,
                                        decoration: const InputDecoration(
                                          labelText: 'الرتبة',
                                          isDense: true,
                                        ),
                                        onChanged: (val) => _updateSignatory(
                                          index,
                                          'rank',
                                          val,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        initialValue: sig.name,
                                        decoration: const InputDecoration(
                                          labelText: 'الاسم',
                                          isDense: true,
                                        ),
                                        onChanged: (val) => _updateSignatory(
                                          index,
                                          'name',
                                          val,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: sig.title,
                                  decoration: const InputDecoration(
                                    labelText: 'الصفة',
                                    isDense: true,
                                  ),
                                  onChanged: (val) =>
                                      _updateSignatory(index, 'title', val),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeSignatory(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        onPressed: _addSignatory,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة توقيع'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: _updateSettings,
                    child: const Text('تحديث المعاينة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.format_quote, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const Expanded(child: Divider(indent: 10)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _saveAndOpenPdf(BuildContext context) async {
    // 1. Generate PDF
    final pdfBytes = await widget.pdfBuilder(
      currentSettings,
      suffixController.text,
    );

    // 2. Pick File
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'حفظ التقرير بصيغة PDF',
      fileName:
          'Report_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // 3. Save & Open
    if (outputFile != null) {
      if (!outputFile.endsWith('.pdf')) {
        outputFile += '.pdf';
      }
      final file = File(outputFile);
      await file.writeAsBytes(pdfBytes);

      // Close dialog? User might want to keep it open.
      // Let's just open the file.
      await OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'معاينة الطباعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showEditDialog,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل البيانات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PDF Preview
          Expanded(
            child: PdfPreview(
              build: (format) =>
                  widget.pdfBuilder(currentSettings, suffixController.text),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting:
                  false, // Disable default Print to avoid system dialog
              allowSharing: false,
              actions: [
                // Custom Print/Save Action
                Builder(
                  builder: (ctx) {
                    return IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: 'طباعة / حفظ PDF',
                      onPressed: () => _saveAndOpenPdf(ctx),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
