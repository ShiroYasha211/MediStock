import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medistock/app/modules/05_settings_management/controllers/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medistock/app/data/local/models/report_settings_model.dart';

class ReportSettingsView extends GetView<SettingsController> {
  const ReportSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                length: 5, // Increased to 5 for Margins
                child: Column(
                  children: [
                    TabBar(
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: theme.colorScheme.primary,
                      indicatorWeight: 3,
                      isScrollable: true,
                      physics: const BouncingScrollPhysics(),
                      tabs: const [
                        Tab(
                          text: 'الترويسة',
                          icon: Icon(Icons.vertical_align_top),
                        ),
                        Tab(text: 'المحتوى', icon: Icon(Icons.list_alt)),
                        Tab(
                          text: 'التذييل',
                          icon: Icon(Icons.vertical_align_bottom),
                        ),
                        Tab(text: 'الهوامش', icon: Icon(Icons.margin_outlined)),
                        Tab(
                          text: 'إعدادات عامة',
                          icon: Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Obx(() {
                        final settings = controller.reportSettings.value;
                        return TabBarView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // 1. تبويب الترويسة
                            ListView(
                              padding: const EdgeInsets.all(24),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildGlassySection(
                                  theme: theme,
                                  title: 'يمين الترويسة',
                                  icon: Icons.align_horizontal_right_rounded,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Toggle between Text and Image
                                      Row(
                                        children: [
                                          const Text(
                                            'المحتوى: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: theme
                                                    .colorScheme
                                                    .outlineVariant,
                                              ),
                                            ),
                                            child: ToggleButtons(
                                              isSelected: [
                                                settings.headerRightType ==
                                                    'text',
                                                settings.headerRightType ==
                                                    'image',
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              selectedColor: Colors.white,
                                              fillColor:
                                                  theme.colorScheme.primary,
                                              onPressed: (index) {
                                                settings.headerRightType =
                                                    index == 0
                                                    ? 'text'
                                                    : 'image';
                                                controller.reportSettings
                                                    .refresh();
                                                controller.saveReportSettings();
                                              },
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  child: Text('نص'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  child: Text('صورة'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      if (settings.headerRightType ==
                                          'text') ...[
                                        ..._buildLineList(
                                          settings.headerRightLines,
                                          theme,
                                        ),
                                      ] else ...[
                                        _buildImageSelector(
                                          theme: theme,
                                          title: 'ملف الصورة (اليمين)',
                                          path: settings.headerRightImagePath,
                                          onSelected: (path) {
                                            settings.headerRightImagePath =
                                                path;
                                            controller.saveReportSettings();
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildSliderControl(
                                          theme,
                                          'العرض',
                                          settings.headerRightImageWidth,
                                          (val) {
                                            settings.headerRightImageWidth =
                                                val;
                                            controller.reportSettings.refresh();
                                            controller.saveReportSettings();
                                          },
                                          min: 20,
                                          max: 200,
                                        ),
                                        _buildSliderControl(
                                          theme,
                                          'الارتفاع',
                                          settings.headerRightImageHeight,
                                          (val) {
                                            settings.headerRightImageHeight =
                                                val;
                                            controller.reportSettings.refresh();
                                            controller.saveReportSettings();
                                          },
                                          min: 20,
                                          max: 200,
                                        ),
                                        _buildSliderControl(
                                          theme,
                                          'إزاحة أفقية',
                                          settings.headerRightImageDx,
                                          (val) {
                                            settings.headerRightImageDx = val;
                                            controller.reportSettings.refresh();
                                            controller.saveReportSettings();
                                          },
                                          min: -50,
                                          max: 50,
                                        ),
                                        _buildSliderControl(
                                          theme,
                                          'إزاحة عمودية',
                                          settings.headerRightImageDy,
                                          (val) {
                                            settings.headerRightImageDy = val;
                                            controller.reportSettings.refresh();
                                            controller.saveReportSettings();
                                          },
                                          min: -50,
                                          max: 50,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildGlassySection(
                                  theme: theme,
                                  title: 'وسط الترويسة (الشعار الرئيسي)',
                                  icon: Icons.center_focus_strong_outlined,
                                  child: _buildImageSelector(
                                    theme: theme,
                                    title: 'ملف الشعار',
                                    path: settings.logoPath,
                                    onSelected: (path) =>
                                        controller.updateLogo(path),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildGlassySection(
                                  theme: theme,
                                  title: 'يسار الترويسة (الاعتماد / التوقيع)',
                                  icon: Icons.align_horizontal_left_rounded,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildLineList(
                                      settings.headerLeftLines,
                                      theme,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // 2. تبويب المحتوى
                            ListView(
                              padding: const EdgeInsets.all(24),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildGlassySection(
                                  theme: theme,
                                  title: 'تخطيط الجدول',
                                  icon: Icons.view_column_rounded,
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'جدول بعمودين متوازيين',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'تقسيم الأصناف إلى قائمتين متجاورتين لتوفير المساحة',
                                    ),
                                    activeColor: theme.colorScheme.primary,
                                    value: settings.tableColumnMode == 'dual',
                                    onChanged: (val) {
                                      settings.tableColumnMode = val
                                          ? 'dual'
                                          : 'single';
                                      controller.reportSettings.refresh();
                                      controller.saveReportSettings();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildGlassySection(
                                  theme: theme,
                                  title: 'نصوص المحتوى الثابتة',
                                  icon: Icons.text_snippet_outlined,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle(
                                        'عنوان التقرير (يظهر أعلى الجدول)',
                                      ),
                                      _buildSingleLineEditor(
                                        settings.reportTitle,
                                        theme,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSectionTitle('المخاطبة (الأخ/...)'),
                                      _buildSingleLineEditor(
                                        settings.recipientTitle,
                                        theme,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSectionTitle('التحية الافتتاحية'),
                                      _buildSingleLineEditor(
                                        settings.introText,
                                        theme,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSectionTitle(
                                        'نص ما قبل الجدول (الوصف)',
                                      ),
                                      _buildSingleLineEditor(
                                        settings.listDescription,
                                        theme,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSectionTitle(
                                        'نص الختام (بعد الجدول وقبل التوقيعات)',
                                      ),
                                      _buildSingleLineEditor(
                                        settings.closingText,
                                        theme,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // 3. تبويب التذييل
                            ListView(
                              padding: const EdgeInsets.all(24),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildGlassySection(
                                  theme: theme,
                                  title: 'تخطيط التوقيعات',
                                  icon: Icons.post_add_rounded,
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'التوقيعات في الصفحة الأولى فقط',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'بدلاً من طباعتها في نهاية آخر صفحة من التقرير',
                                    ),
                                    activeColor: theme.colorScheme.primary,
                                    value: settings.signaturesOnFirstPage,
                                    onChanged: (val) {
                                      settings.signaturesOnFirstPage = val;
                                      controller.reportSettings.refresh();
                                      controller.saveReportSettings();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildGlassySection(
                                  theme: theme,
                                  title: 'أسماء وصفات الموقعين',
                                  icon: Icons.people_alt_outlined,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildSignatureList(
                                      settings.signatures,
                                      theme,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // 4. تبويب الهوامش
                            ListView(
                              padding: const EdgeInsets.all(24),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildGlassySection(
                                  theme: theme,
                                  title: 'هوامش الصفحة (بالسنتيمتر)',
                                  icon: Icons.margin_outlined,
                                  child: Column(
                                    children: [
                                      _buildSliderControl(
                                        theme,
                                        'الهامش العلوي',
                                        settings.marginTop,
                                        (val) {
                                          settings.marginTop = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                        max: 5.0,
                                      ),
                                      const Divider(height: 24),
                                      _buildSliderControl(
                                        theme,
                                        'الهامش السفلي',
                                        settings.marginBottom,
                                        (val) {
                                          settings.marginBottom = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                        max: 5.0,
                                      ),
                                      const Divider(height: 24),
                                      _buildSliderControl(
                                        theme,
                                        'الهامش الأيمن',
                                        settings.marginRight,
                                        (val) {
                                          settings.marginRight = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                        max: 5.0,
                                      ),
                                      const Divider(height: 24),
                                      _buildSliderControl(
                                        theme,
                                        'الهامش الأيسر',
                                        settings.marginLeft,
                                        (val) {
                                          settings.marginLeft = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                        max: 5.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // 5. إعدادات عامة
                            ListView(
                              padding: const EdgeInsets.all(24),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildGlassySection(
                                  theme: theme,
                                  title: 'تنسيقات الجدول الافتراضية',
                                  icon: Icons.format_paint_outlined,
                                  child: Column(
                                    children: [
                                      _buildSliderControl(
                                        theme,
                                        'حجم خط الجدول',
                                        settings.bodyFontSize,
                                        (val) {
                                          settings.bodyFontSize = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                        min: 8,
                                        max: 20,
                                        divisions: 12,
                                      ),
                                      const Divider(height: 24),
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                          'خط الجدول عريض (Bold)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        activeColor: theme.colorScheme.primary,
                                        value: settings.bodyIsBold,
                                        onChanged: (val) {
                                          settings.bodyIsBold = val;
                                          controller.reportSettings.refresh();
                                          controller.saveReportSettings();
                                        },
                                      ),
                                    ],
                                  ),
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
                color: Colors.grey.shade300,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'معاينة تقريبية (A4 Sheet)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      // A4 Aspect Ratio Container
                      AspectRatio(
                        aspectRatio: 1 / 1.414, // A4 aspect ratio
                        child: Container(
                          color: Colors.white,
                          child: Obx(() {
                            final settings = controller.reportSettings.value;
                            // Convert CM to Logic Pixels (approx) for preview
                            // Assuming ~30-40 pixels per cm for screen preview
                            const double cmToPx = 35.0;

                            return Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: settings.marginTop * cmToPx,
                                  bottom: settings.marginBottom * cmToPx,
                                  left: settings.marginLeft * cmToPx,
                                  right: settings.marginRight * cmToPx,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Right Side (Text or Image)
                                        Expanded(
                                          child:
                                              settings.headerRightType ==
                                                  'image'
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Transform.translate(
                                                    offset: Offset(
                                                      settings
                                                          .headerRightImageDx,
                                                      settings
                                                          .headerRightImageDy,
                                                    ),
                                                    child: _buildSafeImagePreview(
                                                      settings
                                                          .headerRightImagePath,
                                                      width: settings
                                                          .headerRightImageWidth, // Use raw value for preview scale? No, maybe scale down
                                                      height: settings
                                                          .headerRightImageHeight,
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: settings
                                                      .headerRightLines
                                                      .map(
                                                        (l) =>
                                                            _buildPreviewText(
                                                              l,
                                                            ),
                                                      )
                                                      .toList(),
                                                ),
                                        ),
                                        // Center (Logo)
                                        _buildSafeImagePreview(
                                          settings.logoPath,
                                          size: 80,
                                        ),
                                        // Left Side
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .end, // Can be overridden by alignment
                                            children: settings.headerLeftLines
                                                .map(
                                                  (l) => _buildPreviewText(l),
                                                )
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

                                    // Placeholder Table (Single or Dual)
                                    // Placeholder Table (Single or Dual)
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                border: Border.all(
                                                  color: Colors.blue.shade200,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  settings.tableColumnMode ==
                                                          'dual'
                                                      ? '[جدول 1 - يمين]'
                                                      : '[جدول الأصناف الرئيسي]',
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (settings.tableColumnMode ==
                                              'dual') ...[
                                            // Joined Table - No Gap
                                            Expanded(
                                              child: Container(
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  border: Border(
                                                    top: BorderSide(
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                    bottom: BorderSide(
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                    left: BorderSide(
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                    // No right border to merge
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '[جدول 2 - يسار]',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _buildPreviewText(settings.closingText),
                                    const SizedBox(height: 30),

                                    // Footer
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      // Render signatures in preview similar to PDF
                                      children: settings.signatures.map(
                                        (sig) {
                                          return Column(
                                            children: [
                                              if (sig.rank.isNotEmpty)
                                                Text(
                                                  sig.rank,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              if (sig.name.isNotEmpty)
                                                Text(
                                                  sig.name,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              Text(
                                                sig.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ).toList(), // ✅ Removed reversed to correct RTL order (Index 0 at Right)
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildSingleLineEditor(ReportLine line, [ThemeData? theme]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (theme?.colorScheme.outlineVariant ?? Colors.grey).withOpacity(
            0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          TextFormField(
            initialValue: line.text,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme?.colorScheme.primary ?? Colors.blue,
                  width: 2,
                ),
              ),
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
    );
  }

  List<Widget> _buildLineList(List<ReportLine> list, [ThemeData? theme]) {
    return [
      ...list.asMap().entries.map((entry) {
        final index = entry.key;
        final line = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (theme?.colorScheme.outlineVariant ?? Colors.grey)
                  .withOpacity(0.3),
            ),
          ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme?.colorScheme.primary ?? Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        line.text = val;
                        controller.saveReportSettings();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
  Widget _buildSafeImagePreview(
    String? path, {
    double size = 50,
    double? width,
    double? height,
  }) {
    final w = width ?? size;
    final h = height ?? size;

    if (path == null || path.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: w,
          height: h,
          fit: BoxFit.contain, // Changed to contain to respect aspect ratio
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: w,
              height: h,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      }
    } catch (e) {
      // print('Error loading image preview: $e');
    }
    return SizedBox(
      width: w,
      height: h,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildSliderControl(
    ThemeData theme,
    String label,
    double value,
    Function(double) onChanged, {
    double min = 0.0,
    double max = 10.0,
    int? divisions,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Slider(
                min: min,
                max: max,
                divisions: divisions ?? 20,
                activeColor: theme.colorScheme.primary,
                value: value.clamp(min, max),
                onChanged: onChanged,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
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

  // --- ✅ جديد: بناء قائمة التوقيعات المتقدمة ---
  List<Widget> _buildSignatureList(
    List<SignatureModel> signatures, [
    ThemeData? theme,
  ]) {
    return [
      for (int i = 0; i < signatures.length; i++)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (theme?.colorScheme.outlineVariant ?? Colors.grey)
                  .withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: signatures[i].rank,
                      decoration: InputDecoration(
                        labelText: 'الرتبة/اللقب',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme?.colorScheme.primary ?? Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        signatures[i].rank = val;
                        controller.saveReportSettings();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: signatures[i].name,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme?.colorScheme.primary ?? Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        signatures[i].name = val;
                        controller.saveReportSettings();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: signatures[i].title,
                decoration: InputDecoration(
                  labelText: 'الصفة (مثل: مدير المخازن)',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme?.colorScheme.primary ?? Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  signatures[i].title = val;
                  controller.saveReportSettings();
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    signatures.removeAt(i);
                    controller.reportSettings.refresh();
                    controller.saveReportSettings();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'حذف التوقيع',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: () {
          signatures.add(SignatureModel(title: 'توقيع جديد'));
          controller.reportSettings.refresh();
          controller.saveReportSettings();
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة توقيع جديد'),
      ),
      const SizedBox(height: 20),
    ];
  }

  // --- ✅ Glassmorphism Section Card ---
  Widget _buildGlassySection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ✅ Image Selector Widget ---
  Widget _buildImageSelector({
    required ThemeData theme,
    required String title,
    required String? path,
    required Function(String) onSelected,
  }) {
    return Row(
      children: [
        _buildSafeImagePreview(path),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null) {
                onSelected(result.files.single.path!);
              }
            } catch (_) {}
          },
          icon: const Icon(Icons.folder_open, size: 18),
          label: const Text('اختيار'),
        ),
      ],
    );
  }
}
