class ReportLine {
  String text;
  double fontSize;
  bool isBold;
  String align; // 'right', 'center', 'left'
  bool isUnderlined;

  ReportLine({
    required this.text,
    this.fontSize = 12.0,
    this.isBold = false,
    this.align = 'right',
    this.isUnderlined = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'fontSize': fontSize,
    'isBold': isBold,
    'align': align,
    'isUnderlined': isUnderlined,
  };

  factory ReportLine.fromJson(Map<String, dynamic> json) {
    return ReportLine(
      text: json['text']?.toString() ?? '',
      fontSize: double.tryParse(json['fontSize']?.toString() ?? '12.0') ?? 12.0,
      isBold: json['isBold'] == true, // Handles null and other types safely
      align: json['align']?.toString() ?? 'right',
      isUnderlined: json['isUnderlined'] == true, // Handles null safely
    );
  }
}

class ReportSettingsModel {
  // Header
  List<ReportLine> headerRightLines;
  List<ReportLine> headerLeftLines;
  String? logoPath;

  // Body - Now using ReportLine for individual styling
  ReportLine reportTitle;
  ReportLine recipientTitle;
  ReportLine introText;
  ReportLine listDescription;
  ReportLine closingText;

  // Footer
  List<ReportLine> signatories;

  // Global Defaults
  double bodyFontSize;
  bool bodyIsBold;

  ReportSettingsModel({
    required this.headerRightLines,
    required this.headerLeftLines,
    this.logoPath,
    required this.reportTitle,
    required this.recipientTitle,
    required this.introText,
    required this.listDescription,
    required this.closingText,
    required this.signatories,
    this.bodyFontSize = 12.0,
    this.bodyIsBold = false,
  });

  factory ReportSettingsModel.defaults() {
    return ReportSettingsModel(
      headerRightLines: [
        ReportLine(
          text: 'الجمهورية اليمنية',
          fontSize: 16,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'وزارة الدفاع',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'رئاسة هيئة الأركان العامة',
          fontSize: 14,
          isBold: false,
          align: 'center',
        ),
        ReportLine(
          text: 'قيادة المنطقة العسكرية السابعة',
          fontSize: 14,
          isBold: false,
          align: 'center',
        ),
        ReportLine(
          text: 'شعبة التأمين الطبي',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
      ],
      headerLeftLines: [
        ReportLine(
          text: 'يعتمــد /',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'قائد القطاع /',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'التوقيـع /',
          fontSize: 14,
          isBold: false,
          align: 'center',
        ),
        ReportLine(
          text: 'الختــم /',
          fontSize: 14,
          isBold: false,
          align: 'center',
        ),
      ],
      logoPath: null,
      reportTitle: ReportLine(
        text: 'استمارة صرف أدوية',
        fontSize: 18,
        isBold: true,
        align: 'center',
        isUnderlined: true,
      ),
      recipientTitle: ReportLine(
        text: 'الأخ/ قائد قطاع الكسارة                المحترم',
        fontSize: 14,
        isBold: true,
        align: 'left',
      ),
      introText: ReportLine(
        text: 'تحية طيبة وبعد',
        fontSize: 14,
        isBold: false,
        align: 'center',
      ),
      listDescription: ReportLine(
        text:
            'إليكم قائمة بأصناف الأدوية والمستلزمات المصروفة لشهر (ديسمبر 2024م) لوحدتكم',
        fontSize: 14,
        isBold: false,
        align: 'center',
      ),
      closingText: ReportLine(
        text: 'تكرموا بالاطلاع والمصادقة',
        fontSize: 14,
        isBold: true,
        align: 'center',
      ),
      signatories: [
        ReportLine(
          text: 'الركن الطبي',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'المخازن',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'التموين الطبي',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
        ReportLine(
          text: 'رئيس الشعبة',
          fontSize: 14,
          isBold: true,
          align: 'center',
        ),
      ],
      bodyFontSize: 12.0,
      bodyIsBold: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerRightLines': headerRightLines.map((e) => e.toJson()).toList(),
      'headerLeftLines': headerLeftLines.map((e) => e.toJson()).toList(),
      'logoPath': logoPath,
      'reportTitle': reportTitle.toJson(),
      'recipientTitle': recipientTitle.toJson(),
      'introText': introText.toJson(),
      'listDescription': listDescription.toJson(),
      'closingText': closingText.toJson(),
      'signatories': signatories.map((e) => e.toJson()).toList(),
      'bodyFontSize': bodyFontSize,
      'bodyIsBold': bodyIsBold,
    };
  }

  factory ReportSettingsModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse list of lines
    List<ReportLine> parseLines(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list.map((e) {
          if (e is String) {
            return ReportLine(
              text: e,
              fontSize: 12,
              isBold: false,
              align: 'right',
              isUnderlined: false,
            );
          }
          // Safely cast legacy/dynamic maps
          if (e is Map) {
            return ReportLine.fromJson(Map<String, dynamic>.from(e));
          }
          return ReportLine(text: '', fontSize: 12);
        }).toList();
      }
      return [];
    }

    // Helper to parse single line (migration from String)
    ReportLine parseLine(
      dynamic val,
      String defaultText, {
      double size = 14,
      bool bold = false,
      String align = 'right',
      bool isUnderlined = false,
    }) {
      if (val is String) {
        return ReportLine(
          text: val,
          fontSize: size,
          isBold: bold,
          align: align,
          isUnderlined: isUnderlined,
        );
      }
      if (val is Map) {
        return ReportLine.fromJson(Map<String, dynamic>.from(val));
      }
      return ReportLine(
        text: defaultText,
        fontSize: size,
        isBold: bold,
        align: align,
        isUnderlined: isUnderlined,
      );
    }

    return ReportSettingsModel(
      headerRightLines: parseLines(json['headerRightLines']),
      headerLeftLines: parseLines(json['headerLeftLines']),
      logoPath: json['logoPath'],
      reportTitle: parseLine(
        json['reportTitle'],
        'استمارة صرف أدوية',
        size: 18,
        bold: true,
        align: 'center',
        isUnderlined: true,
      ),
      recipientTitle: parseLine(
        json['recipientTitle'],
        '',
        size: 14,
        bold: true,
        align: 'left',
      ),
      introText: parseLine(
        json['introText'],
        'تحية طيبة وبعد',
        size: 14,
        align: 'center',
      ),
      listDescription: parseLine(
        json['listDescription'],
        '',
        size: 14,
        align: 'center',
      ),
      closingText: parseLine(
        json['closingText'],
        '',
        size: 14,
        bold: true,
        align: 'center',
      ),
      signatories: parseLines(json['signatories']),
      bodyFontSize: (json['bodyFontSize'] ?? 12.0).toDouble(),
      bodyIsBold: json['bodyIsBold'] ?? false,
    );
  }
}
