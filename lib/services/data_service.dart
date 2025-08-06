import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/habit.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  Future<String> exportData(List<Task> tasks, List<Habit> habits) async {
    final exportData = {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'habits': habits.map((habit) => habit.toJson()).toList(),
      'metadata': {
        'totalTasks': tasks.length,
        'totalHabits': habits.length,
        'completedTasks': tasks.where((t) => t.isCompleted).length,
        'activeHabits': habits.where((h) => h.isActive).length,
      },
    };

    return jsonEncode(exportData);
  }

  Future<Map<String, dynamic>> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as String?;
      if (version == null || !version.startsWith('1.')) {
        throw Exception('Unsupported data format version');
      }

      // Parse tasks
      final tasksJson = data['tasks'] as List<dynamic>;
      final tasks = tasksJson.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();

      // Parse habits
      final habitsJson = data['habits'] as List<dynamic>;
      final habits = habitsJson.map((json) => Habit.fromJson(json as Map<String, dynamic>)).toList();

      return {
        'tasks': tasks,
        'habits': habits,
        'metadata': data['metadata'] as Map<String, dynamic>? ?? {},
      };
    } catch (e) {
      throw Exception('Invalid data format: $e');
    }
  }

  Future<void> saveToFile(String data, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(data);
  }

  Future<String> readFromFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    
    if (!await file.exists()) {
      throw Exception('File not found: $filename');
    }
    
    return await file.readAsString();
  }

  Future<List<String>> getExportFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    
    return files
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) => file.path.split('/').last)
        .toList();
  }

  Future<void> deleteExportFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Map<String, dynamic>> getBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tasksJson = prefs.getStringList('tasks') ?? [];
    final habitsJson = prefs.getStringList('habits') ?? [];
    
    final tasks = tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .toList();
    
    final habits = habitsJson
        .map((json) => Habit.fromJson(jsonDecode(json)))
        .toList();

    return {
      'tasks': tasks,
      'habits': habits,
      'settings': {
        'themeMode': prefs.getInt('theme_mode') ?? 0,
      },
    };
  }

  Future<void> restoreFromBackup(Map<String, dynamic> backupData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Restore tasks
    final tasks = backupData['tasks'] as List<Task>;
    final tasksJson = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList('tasks', tasksJson);
    
    // Restore habits
    final habits = backupData['habits'] as List<Habit>;
    final habitsJson = habits
        .map((habit) => jsonEncode(habit.toJson()))
        .toList();
    await prefs.setStringList('habits', habitsJson);
    
    // Restore settings
    final settings = backupData['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      await prefs.setInt('theme_mode', settings['themeMode'] ?? 0);
    }
  }

  Future<Map<String, dynamic>> getDataStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tasksJson = prefs.getStringList('tasks') ?? [];
    final habitsJson = prefs.getStringList('habits') ?? [];
    
    final tasks = tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .toList();
    
    final habits = habitsJson
        .map((json) => Habit.fromJson(jsonDecode(json)))
        .toList();

    return {
      'totalTasks': tasks.length,
      'completedTasks': tasks.where((t) => t.isCompleted).length,
      'pendingTasks': tasks.where((t) => !t.isCompleted).length,
      'overdueTasks': tasks.where((t) => t.isOverdue).length,
      'totalHabits': habits.length,
      'activeHabits': habits.where((h) => h.isActive).length,
      'completedHabits': habits.where((h) => h.isCompletedToday).length,
      'averageStreak': habits.isNotEmpty 
          ? habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length 
          : 0,
      'longestStreak': habits.isNotEmpty 
          ? habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b) 
          : 0,
    };
  }
} 