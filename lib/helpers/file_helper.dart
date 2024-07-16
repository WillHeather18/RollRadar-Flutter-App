import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<File> _getFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    return File(path);
  }

  static Future<Map<String, dynamic>?> readJson(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return json.decode(jsonString);
      }
    } catch (e) {
      print('Failed to read JSON from $filename: $e');
    }
    return null;
  }

  static Future<void> writeJson(
      String filename, Map<String, dynamic> jsonContent) async {
    final file = await _getFile(filename);
    try {
      final jsonString = json.encode(jsonContent);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Failed to write JSON to $filename: $e');
    }
  }
}
