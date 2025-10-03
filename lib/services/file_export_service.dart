import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/json_structure.dart';
import 'json_parser_service.dart';

// Web-specific imports
import 'dart:html' as html show Blob, Url, AnchorElement;

class FileExportService {
  /// Import JSON file from device storage
  static Future<String?> importJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          // For web platform
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            return utf8.decode(bytes);
          }
        } else {
          // For mobile/desktop platforms
          final file = File(result.files.first.path!);
          return await file.readAsString();
        }
      }
    } catch (e) {
      throw FileExportException('خطا در وارد کردن فایل: $e');
    }
    return null;
  }

  /// Export translated JSON to device storage
  static Future<String?> exportJsonFile(
    JsonStructure jsonStructure,
    String fileName,
  ) async {
    try {
      final translatedJson = jsonStructure.getTranslatedJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(translatedJson);
      
      if (kIsWeb) {
        // For web platform - trigger download
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'Downloaded: $fileName';
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (e) {
      throw FileExportException('خطا در صادر کردن فایل: $e');
    }
  }

  /// Save project to local storage
  static Future<void> saveProject(
    JsonStructure jsonStructure,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/translation_projects');
      
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }
      
      final fileName = '${jsonStructure.fileName}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${projectsDir.path}/$fileName');
      
      final projectData = {
        'jsonStructure': jsonStructure.toJson(),
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(projectData));
    } catch (e) {
      throw FileExportException('خطا در ذخیره پروژه: $e');
    }
  }

  /// Load project from local storage
  static Future<JsonStructure?> loadProject(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final projectData = json.decode(content);
        
        return JsonStructure.fromJson(projectData['jsonStructure']);
      }
    } catch (e) {
      throw FileExportException('خطا در بارگذاری پروژه: $e');
    }
    return null;
  }

  /// Get list of saved projects
  static Future<List<Map<String, dynamic>>> getSavedProjects() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/translation_projects');
      
      if (!await projectsDir.exists()) {
        return [];
      }
      
      final files = await projectsDir.list().toList();
      final projects = <Map<String, dynamic>>[];
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final projectData = json.decode(content);
            
            projects.add({
              'filePath': file.path,
              'fileName': file.path.split('/').last,
              'savedAt': projectData['savedAt'],
              'jsonStructure': projectData['jsonStructure'],
            });
          } catch (e) {
            // Skip corrupted files
            continue;
          }
        }
      }
      
      // Sort by saved date (newest first)
      projects.sort((a, b) => 
        DateTime.parse(b['savedAt']).compareTo(DateTime.parse(a['savedAt']))
      );
      
      return projects;
    } catch (e) {
      throw FileExportException('خطا در دریافت لیست پروژه‌ها: $e');
    }
  }

  /// Delete project
  static Future<void> deleteProject(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileExportException('خطا در حذف پروژه: $e');
    }
  }

  /// Export to multiple formats
  static Future<Map<String, String?>> exportToMultipleFormats(
    JsonStructure jsonStructure,
    String baseFileName,
  ) async {
    final results = <String, String?>{};
    
    try {
      // Export as JSON
      results['json'] = await exportJsonFile(
        jsonStructure,
        '$baseFileName.json',
      );
      
      // Export as CSV
      results['csv'] = await _exportToCsv(jsonStructure, baseFileName);
      
      // Export as TXT (key-value pairs)
      results['txt'] = await _exportToTxt(jsonStructure, baseFileName);
      
    } catch (e) {
      throw FileExportException('خطا در صادر کردن فایل‌ها: $e');
    }
    
    return results;
  }

  /// Export to CSV format
  static Future<String?> _exportToCsv(
    JsonStructure jsonStructure,
    String baseFileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final csvContent = StringBuffer();
      
      // CSV header
      csvContent.writeln('Key,Original,Translated,Has Placeholders,Completed');
      
      // CSV data
      for (final item in jsonStructure.translationItems) {
        csvContent.writeln(
          '"${item.key}","${item.originalValue}","${item.translatedValue}",'
          '${item.hasPlaceholders},${item.isCompleted}'
        );
      }
      
      final file = File('${directory.path}/$baseFileName.csv');
      await file.writeAsString(csvContent.toString());
      
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Export to TXT format
  static Future<String?> _exportToTxt(
    JsonStructure jsonStructure,
    String baseFileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final txtContent = StringBuffer();
      
      txtContent.writeln('Translation Export');
      txtContent.writeln('================');
      txtContent.writeln('Source Language: ${jsonStructure.sourceLanguage}');
      txtContent.writeln('Target Language: ${jsonStructure.targetLanguage}');
      txtContent.writeln('Created: ${jsonStructure.createdAt}');
      txtContent.writeln('');
      
      for (final item in jsonStructure.translationItems) {
        txtContent.writeln('Key: ${item.key}');
        txtContent.writeln('Original: ${item.originalValue}');
        txtContent.writeln('Translated: ${item.translatedValue}');
        if (item.hasPlaceholders) {
          txtContent.writeln('Placeholders: ${JsonParserService.extractPlaceholders(item.originalValue).join(', ')}');
        }
        txtContent.writeln('Completed: ${item.isCompleted ? 'Yes' : 'No'}');
        txtContent.writeln('---');
      }
      
      final file = File('${directory.path}/$baseFileName.txt');
      await file.writeAsString(txtContent.toString());
      
      return file.path;
    } catch (e) {
      return null;
    }
  }
}

class FileExportException implements Exception {
  final String message;
  FileExportException(this.message);
  
  @override
  String toString() => 'FileExportException: $message';
}

