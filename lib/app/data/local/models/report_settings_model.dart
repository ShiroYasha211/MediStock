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

class SignatureModel {
  String rank;
  String name;
  String title;

  SignatureModel({this.rank = '', this.name = '', required this.title});

  Map<String, dynamic> toJson() => {'rank': rank, 'name': name, 'title': title};

  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      rank: json['rank']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class ReportSettingsModel {
  // Header
  List<ReportLine> headerRightLines;
  String headerRightType; // 'text' or 'image'
  String? headerRightImagePath;
  double headerRightImageWidth;
  double headerRightImageHeight;
  double headerRightImageDx;
  double headerRightImageDy;

  List<ReportLine> headerLeftLines;
  String? logoPath;

  // Body - Now using ReportLine for individual styling
  ReportLine reportTitle;
  ReportLine recipientTitle;
  ReportLine introText;
  ReportLine listDescription;
  ReportLine closingText;
  String tableColumnMode; // 'single' or 'dual'

  // Footer
  List<SignatureModel> signatures; // ✅ New structured signatures
  bool
  signaturesOnFirstPage; // ✅ New: Toggle signatures on first page or last page

  // Global Defaults
  double bodyFontSize;
  bool bodyIsBold;

  // Margins (in cm)
  double marginTop;
  double marginBottom;
  double marginLeft;
  double marginRight;
  double recipientSuffixMargin; // ✅ Margin for the footer suffix (المحترم)

  ReportSettingsModel({
    required this.headerRightLines,
    this.headerRightType = 'text',
    this.headerRightImagePath,
    this.headerRightImageWidth = 80.0,
    this.headerRightImageHeight = 80.0,
    this.headerRightImageDx = 0.0,
    this.headerRightImageDy = 0.0,
    required this.headerLeftLines,
    this.logoPath,
    required this.reportTitle,
    required this.recipientTitle,
    required this.introText,
    required this.listDescription,
    required this.closingText,
    this.tableColumnMode = 'single',
    required this.signatures,
    this.bodyFontSize = 12.0,
    this.bodyIsBold = false,
    this.marginTop = 1.0,
    this.marginBottom = 1.0,
    this.marginLeft = 1.0,
    this.marginRight = 1.0,
    this.recipientSuffixMargin = 50.0, // Default to 50 logical pixels
    this.signaturesOnFirstPage = false, // Default to Last Page
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
      headerRightType: 'text',
      headerRightImageWidth: 80.0,
      headerRightImageHeight: 80.0,
      headerRightImageDx: 0.0,
      headerRightImageDy: 0.0,
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
      tableColumnMode: 'single',
      signatures: [
        SignatureModel(title: 'الركن الطبي'),
        SignatureModel(title: 'المخازن'),
        SignatureModel(title: 'التموين الطبي'),
        SignatureModel(title: 'رئيس الشعبة'),
      ],
      bodyFontSize: 12.0,
      bodyIsBold: true,
      marginTop: 1.0,
      marginBottom: 1.0,
      marginLeft: 1.0,
      marginRight: 1.0,
      recipientSuffixMargin: 50.0,
      signaturesOnFirstPage: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerRightLines': headerRightLines.map((e) => e.toJson()).toList(),
      'headerRightType': headerRightType,
      'headerRightImagePath': headerRightImagePath,
      'headerRightImageWidth': headerRightImageWidth,
      'headerRightImageHeight': headerRightImageHeight,
      'headerRightImageDx': headerRightImageDx,
      'headerRightImageDy': headerRightImageDy,
      'headerLeftLines': headerLeftLines.map((e) => e.toJson()).toList(),
      'logoPath': logoPath,
      'reportTitle': reportTitle.toJson(),
      'recipientTitle': recipientTitle.toJson(),
      'introText': introText.toJson(),
      'listDescription': listDescription.toJson(),
      'closingText': closingText.toJson(),
      'tableColumnMode': tableColumnMode,
      'signatures': signatures.map((e) => e.toJson()).toList(),
      'bodyFontSize': bodyFontSize,
      'bodyIsBold': bodyIsBold,
      'marginTop': marginTop,
      'marginBottom': marginBottom,
      'marginLeft': marginLeft,
      'marginRight': marginRight,
      'recipientSuffixMargin': recipientSuffixMargin,
      'signaturesOnFirstPage': signaturesOnFirstPage,
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

    // MIGRATION LOGIC for Signatures
    List<SignatureModel> parseSignatures(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list.map((e) {
          if (e is String) {
            // Old simple string format -> Title
            return SignatureModel(title: e);
          }
          if (e is Map) {
            // Could be old ReportLine map OR new SignatureModel map
            final map = Map<String, dynamic>.from(e);
            if (map.containsKey('text')) {
              // It's likely an old ReportLine
              return SignatureModel(title: map['text'].toString());
            }
            // Assume it's the new model
            return SignatureModel.fromJson(map);
          }
          return SignatureModel(title: '');
        }).toList();
      }
      return [];
    }

    // Check key compatibility
    final sigs =
        json['signatures'] ?? json['signatories']; // Fallback to old key

    return ReportSettingsModel(
      headerRightLines: parseLines(json['headerRightLines']),
      headerRightType: json['headerRightType'] ?? 'text',
      headerRightImagePath: json['headerRightImagePath'],
      headerRightImageWidth: (json['headerRightImageWidth'] ?? 80.0).toDouble(),
      headerRightImageHeight: (json['headerRightImageHeight'] ?? 80.0)
          .toDouble(),
      headerRightImageDx: (json['headerRightImageDx'] ?? 0.0).toDouble(),
      headerRightImageDy: (json['headerRightImageDy'] ?? 0.0).toDouble(),
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
      tableColumnMode: json['tableColumnMode'] ?? 'single',
      signatures: parseSignatures(sigs),
      bodyFontSize: (json['bodyFontSize'] ?? 12.0).toDouble(),
      bodyIsBold: json['bodyIsBold'] ?? false,
      marginTop: (json['marginTop'] ?? 1.0).toDouble(),
      marginBottom: (json['marginBottom'] ?? 1.0).toDouble(),
      marginLeft: (json['marginLeft'] ?? 1.0).toDouble(),
      marginRight: (json['marginRight'] ?? 1.0).toDouble(),
      recipientSuffixMargin: (json['recipientSuffixMargin'] ?? 50.0).toDouble(),
      signaturesOnFirstPage: json['signaturesOnFirstPage'] ?? false,
    );
  }
}
