import 'dart:io';
import 'package:docx_template/docx_template.dart';

import 'package:intl/intl.dart';
import 'package:medistock/app/data/local/models/item_model.dart';
import 'package:open_file/open_file.dart';

class WordReportGenerator {
  /// Generates a report based on a DOCX template and a list of items.
  static Future<void> generate(
    List<ItemModel> items,
    String templatePath,
    String outputPath,
  ) async {
    // 1. Load the template file
    final File templateFile = File(templatePath);
    if (!await templateFile.exists()) {
      throw Exception('ملف القالب غير موجود: $templatePath');
    }

    final bytes = await templateFile.readAsBytes();
    // Create a mutable copy of the bytes to avoid "Cannot modify an unmodifiable list" error
    // which might happen if the library tries to modify the buffer directly.
    final mutableBytes = bytes.toList();
    final docx = await DocxTemplate.fromBytes(mutableBytes);

    // 2. Prepare the data
    // We create a Content generic object to hold our data
    final Content content = Content();

    // Add simple fields
    content.add(
      TextContent('date', DateFormat('yyyy-MM-dd').format(DateTime.now())),
    );
    content.add(
      TextContent('time', DateFormat('HH:mm').format(DateTime.now())),
    );
    content.add(TextContent('total_items', items.length.toString()));

    // Prepare the list of items for the table
    // Assuming the template has a list placeholder named 'items'
    // with sub-keys: index, name, unit, quantity, expiry, batch
    final List<Content> itemsList = [];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      itemsList.add(
        Content()
          ..add(TextContent('index', (i + 1).toString()))
          ..add(TextContent('name', item.name))
          ..add(TextContent('scientific_name', item.scientificName ?? '-'))
          ..add(TextContent('code', item.itemCode ?? '-'))
          ..add(TextContent('unit', item.unit ?? '-'))
          ..add(TextContent('quantity', item.quantity.toString()))
          ..add(TextContent('batch', item.batchNumber ?? '-'))
          ..add(
            TextContent(
              'expiry',
              DateFormat('yyyy-MM-dd').format(item.expiryDate),
            ),
          ),
      );
    }

    // Add the list to the content
    content.add(ListContent('items', itemsList));

    // 3. Generate the document
    final d = await docx.generate(content);

    if (d != null) {
      final outputFile = File(outputPath);
      if (outputFile.existsSync()) {
        await outputFile.delete();
      }
      await outputFile.writeAsBytes(d);

      // 4. Open the file
      await OpenFile.open(outputFile.path);
    } else {
      throw Exception('فشل في توليد ملف الوورد.');
    }
  }
}
