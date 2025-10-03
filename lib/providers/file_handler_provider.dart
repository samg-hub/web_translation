import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/json_structure.dart';
import '../services/file_export_service.dart';

class FileHandlerNotifier extends StateNotifier<FileHandlerState> {
  FileHandlerNotifier() : super(const FileHandlerState());

  /// Import JSON file
  Future<void> importJsonFile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final jsonContent = await FileExportService.importJsonFile();
      
      if (jsonContent != null) {
        state = state.copyWith(
          isLoading: false,
          importedContent: jsonContent,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'فایل انتخاب نشد',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Export JSON file
  Future<void> exportJsonFile(JsonStructure jsonStructure, String fileName) async {
    try {
      state = state.copyWith(isExporting: true, error: null);
      
      final filePath = await FileExportService.exportJsonFile(
        jsonStructure,
        fileName,
      );
      
      state = state.copyWith(
        isExporting: false,
        lastExportedPath: filePath,
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: e.toString(),
      );
    }
  }

  /// Save project
  Future<void> saveProject(JsonStructure jsonStructure) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      
      await FileExportService.saveProject(jsonStructure);
      
      state = state.copyWith(
        isSaving: false,
        lastSavedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
    }
  }

  /// Load saved projects
  Future<void> loadSavedProjects() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final projects = await FileExportService.getSavedProjects();
      
      state = state.copyWith(
        isLoading: false,
        savedProjects: projects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load specific project
  Future<void> loadProject(String filePath) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final jsonStructure = await FileExportService.loadProject(filePath);
      
      if (jsonStructure != null) {
        state = state.copyWith(
          isLoading: false,
          loadedProject: jsonStructure,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'پروژه یافت نشد',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete project
  Future<void> deleteProject(String filePath) async {
    try {
      await FileExportService.deleteProject(filePath);
      
      // Reload projects list
      await loadSavedProjects();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Export to multiple formats
  Future<void> exportToMultipleFormats(
    JsonStructure jsonStructure,
    String baseFileName,
  ) async {
    try {
      state = state.copyWith(isExporting: true, error: null);
      
      final results = await FileExportService.exportToMultipleFormats(
        jsonStructure,
        baseFileName,
      );
      
      state = state.copyWith(
        isExporting: false,
        lastExportResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const FileHandlerState();
  }
}

class FileHandlerState {
  final bool isLoading;
  final bool isExporting;
  final bool isSaving;
  final String? error;
  final String? importedContent;
  final String? lastExportedPath;
  final DateTime? lastSavedAt;
  final List<Map<String, dynamic>> savedProjects;
  final JsonStructure? loadedProject;
  final Map<String, String?>? lastExportResults;

  const FileHandlerState({
    this.isLoading = false,
    this.isExporting = false,
    this.isSaving = false,
    this.error,
    this.importedContent,
    this.lastExportedPath,
    this.lastSavedAt,
    this.savedProjects = const [],
    this.loadedProject,
    this.lastExportResults,
  });

  FileHandlerState copyWith({
    bool? isLoading,
    bool? isExporting,
    bool? isSaving,
    String? error,
    String? importedContent,
    String? lastExportedPath,
    DateTime? lastSavedAt,
    List<Map<String, dynamic>>? savedProjects,
    JsonStructure? loadedProject,
    Map<String, String?>? lastExportResults,
  }) {
    return FileHandlerState(
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      importedContent: importedContent ?? this.importedContent,
      lastExportedPath: lastExportedPath ?? this.lastExportedPath,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      savedProjects: savedProjects ?? this.savedProjects,
      loadedProject: loadedProject ?? this.loadedProject,
      lastExportResults: lastExportResults ?? this.lastExportResults,
    );
  }

  bool get hasError => error != null;
  bool get hasImportedContent => importedContent != null;
  bool get hasSavedProjects => savedProjects.isNotEmpty;
  bool get hasLoadedProject => loadedProject != null;
  bool get hasExportResults => lastExportResults != null;
}

final fileHandlerProvider = StateNotifierProvider<FileHandlerNotifier, FileHandlerState>(
  (ref) => FileHandlerNotifier(),
);

