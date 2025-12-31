import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/local/models/report_settings_model.dart';

class ReportSettingsService {
  final _box = GetStorage();
  final _key = 'report_settings';

  /// Saves the report settings to local storage
  Future<void> saveSettings(ReportSettingsModel settings) async {
    await _box.write(_key, settings.toJson());
  }

  /// Loads the report settings from local storage.
  /// Returns default settings if none found.
  ReportSettingsModel loadSettings() {
    try {
      final data = _box.read(_key);
      if (data != null && data is Map<String, dynamic>) {
        return ReportSettingsModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading report settings: $e');
      // If data is corrupt, return defaults (safe fallback)
    }
    return ReportSettingsModel.defaults();
  }
}
