import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/modules/05_settings_management/controllers/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medistock/app/data/local/models/report_settings_model.dart';

class ReportSettingsView extends GetView<SettingsController> {
  const ReportSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصميم التقرير المتقدم')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.saveReportSettings();
          Get.snackbar(
            'تم',
            'تم حفظ الإعدادات بنجاح',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        label: const Text('حفظ وتطبيق'),
        icon: const Icon(Icons.save),
      ),
      body: SizedBox.expand(
        // Ensure full size
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch children vertically
          children: [
            // --- القائمة الجانبية (Tabs) ---
            Expanded(
              flex: 2,
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'الترويسة'),
                        Tab(text: 'المحتوى'),
                        Tab(text: 'التذييل'),
                        Tab(text: 'إعدادات عامة'),
                      ],
                    ),
                    Expanded(
                      child: Obx(() {
                        // print('DEBUG: Rebuilding Tabs Obx');
                        final settings = controller.reportSettings.value;
                        return TabBarView(
                          children: [
                            // 1. تبويب الترويسة
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSectionTitle(
                                  'يمين الترويسة (الجمهورية، الوزارة...)',
                                ),
                                ..._buildLineList(settings.headerRightLines),
                                const Divider(),
                                _buildSectionTitle('وسط الترويسة (الشعار)'),
                                ListTile(
                                  leading: _buildSafeImagePreview(
                                    settings.logoPath,
                                  ),
                                  title: const Text('ملف الشعار'),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                              type: FileType.image,
                                            );
                                        if (result != null) {
                                          controller.updateLogo(
                                            result.files.single.path!,
                                          );
                                        }
                                      } catch (e) {
                                        print('Error picking file: $e');
                                      }
                                    },
                                    child: const Text('اختيار'),
                                  ),
                                ),
                                const Divider(),
                                _buildSectionTitle(
                                  'يسار الترويسة (يعتمد / التوقيع)',
                                ),
                                ..._buildLineList(settings.headerLeftLines),
                              ],
                            ),
                            // 2. تبويب المحتوى
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSectionTitle('عنوان التقرير'),
                                _buildSingleLineEditor(settings.reportTitle),
                                _buildSectionTitle('المخاطبة (الأخ/...)'),
                                _buildSingleLineEditor(settings.recipientTitle),
                                _buildSectionTitle('التحية (تحية طيبة وبعد)'),
                                _buildSingleLineEditor(settings.introText),
                                _buildSectionTitle('مقدمة الجدول'),
                                _buildSingleLineEditor(
                                  settings.listDescription,
                                ),
                                const Divider(),
                                _buildSectionTitle('الختام (قبل التوقيعات)'),
                                _buildSingleLineEditor(settings.closingText),
                              ],
                            ),
                            // 3. تبويب التذييل
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSectionTitle('أسماء الموقعين'),
                                ..._buildLineList(settings.signatories),
                              ],
                            ),
                            // 4. إعدادات عامة
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSectionTitle('خطوط الجدول العامة'),
                                ListTile(
                                  title: const Text(
                                    'حجم خط الجدول (الافتراضي)',
                                  ),
                                  trailing: Text(
                                    settings.bodyFontSize.toStringAsFixed(1),
                                  ),
                                  subtitle: Slider(
                                    min: 8,
                                    max: 20,
                                    divisions: 12,
                                    value: settings.bodyFontSize,
                                    onChanged: (val) {
                                      settings.bodyFontSize = val;
                                      controller.reportSettings.refresh();
                                      controller.saveReportSettings();
                                    },
                                  ),
                                ),
                                SwitchListTile(
                                  title: const Text('خط الجدول عريض (Bold)'),
                                  value: settings.bodyIsBold,
                                  onChanged: (val) {
                                    settings.bodyIsBold = val;
                                    controller.reportSettings.refresh();
                                    controller.saveReportSettings();
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            // --- المعاينة الحية ---
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'معاينة تقريبية',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Obx(() {
                          // print('DEBUG: Rebuilding Preview Obx');
                          final settings = controller.reportSettings.value;
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: settings.headerRightLines
                                            .map((l) => _buildPreviewText(l))
                                            .toList(),
                                      ),
                                    ),
                                    _buildSafeImagePreview(
                                      settings.logoPath,
                                      size: 80,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end, // Can be overridden by alignment
                                        children: settings.headerLeftLines
                                            .map((l) => _buildPreviewText(l))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 2, height: 30),

                                // Body
                                _buildPreviewText(settings.reportTitle),
                                const SizedBox(height: 20),
                                _buildPreviewText(settings.recipientTitle),
                                const SizedBox(height: 10),
                                _buildPreviewText(settings.introText),
                                const SizedBox(height: 10),
                                _buildPreviewText(settings.listDescription),
                                const SizedBox(height: 20),

                                // Placeholder Table
                                Container(
                                  height: 100,
                                  color: Colors.blue.shade50,
                                  child: Center(
                                    child: Text(
                                      '[جدول الأصناف] الخط: ${settings.bodyFontSize}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildPreviewText(settings.closingText),
                                const SizedBox(height: 30),

                                // Footer
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: settings.signatories
                                      .map((sig) => _buildPreviewText(sig))
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getPreviewStyle(ReportLine line) {
    return TextStyle(
      fontSize: line.fontSize,
      fontWeight: line.isBold ? FontWeight.bold : FontWeight.normal,
      // fontFamily: 'Arial', // Removed for now
      decoration: line.isUnderlined
          ? TextDecoration.underline
          : TextDecoration.none,
    );
  }

  Widget _buildPreviewText(ReportLine line) {
    TextAlign textAlign;
    switch (line.align) {
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'left':
        textAlign = TextAlign.left;
        break;
      case 'center':
      default:
        textAlign = TextAlign.center;
        break;
    }

    // Simplified: No SizedBox(double.infinity), allow natural width or layout parent control
    return Text(
      line.text.isEmpty ? ' ' : line.text, // Handle empty
      style: _getPreviewStyle(line),
      textAlign: textAlign,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildSingleLineEditor(ReportLine line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: line.text,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                line.text = val;
                controller.reportSettings.refresh();
                controller.saveReportSettings();
              },
            ),
            const SizedBox(height: 8),
            _buildStyleControls(line),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLineList(List<ReportLine> list) {
    return [
      ...list.asMap().entries.map((entry) {
        final index = entry.key;
        final line = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: line.text,
                        decoration: InputDecoration(
                          labelText: 'السطر ${index + 1}',
                          isDense: true,
                        ),
                        onChanged: (val) {
                          line.text = val;
                          controller.saveReportSettings();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        list.removeAt(index);
                        controller.reportSettings.refresh();
                        controller.saveReportSettings();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStyleControls(line),
              ],
            ),
          ),
        );
      }).toList(),
      TextButton.icon(
        onPressed: () {
          list.add(ReportLine(text: 'نص جديد', fontSize: 12));
          controller.reportSettings.refresh();
          controller.saveReportSettings();
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة سطر'),
      ),
    ];
  }

  // Safe Image Builder
  Widget _buildSafeImagePreview(String? path, {double size = 50}) {
    if (path == null || path.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: size,
              height: size,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      }
    } catch (e) {
      // print('Error loading image preview: $e');
    }
    return SizedBox(
      width: size,
      height: size,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildStyleControls(ReportLine line) {
    return Column(
      children: [
        Row(
          children: [
            const Text('حجم: '),
            Expanded(
              child: Slider(
                min: 8,
                max: 24,
                divisions: 8,
                value: line.fontSize,
                onChanged: (val) {
                  line.fontSize = val;
                  controller.reportSettings.refresh();
                  controller.saveReportSettings();
                },
              ),
            ),
            Text(line.fontSize.toStringAsFixed(0)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Bold Toggle
            FilterChip(
              label: const Text(
                'B',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              selected: line.isBold,
              onSelected: (val) {
                line.isBold = val;
                controller.reportSettings.refresh();
                controller.saveReportSettings();
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
            // Underline Toggle
            FilterChip(
              label: const Text(
                'U',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              selected: line.isUnderlined,
              onSelected: (val) {
                line.isUnderlined = val;
                controller.reportSettings.refresh();
                controller.saveReportSettings();
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
            // Alignment Toggles
            ToggleButtons(
              constraints: const BoxConstraints(minHeight: 30, minWidth: 40),
              isSelected: [
                line.align == 'right',
                line.align == 'center',
                line.align == 'left',
              ],
              onPressed: (index) {
                if (index == 0) line.align = 'right';
                if (index == 1) line.align = 'center';
                if (index == 2) line.align = 'left';
                controller.reportSettings.refresh();
                controller.saveReportSettings();
              },
              children: const [
                Icon(Icons.format_align_right, size: 18), // index 0
                Icon(Icons.format_align_center, size: 18), // index 1
                Icon(Icons.format_align_left, size: 18), // index 2
              ],
            ),
          ],
        ),
      ],
    );
  }
}
