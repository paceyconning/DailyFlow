import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../services/ai_memory_service.dart';

class TaskProvider extends ChangeNotifier {
  static const String _tasksKey = 'tasks';
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _currentFilter = 'all';
  final AIMemoryService _memoryService = AIMemoryService();
  
  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  String get currentFilter => _currentFilter;
  
  TaskProvider() {
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    _tasks = tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .toList();
    
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
  
  void _applyFilter() {
    switch (_currentFilter) {
      case 'today':
        _filteredTasks = _tasks.where((task) => 
          task.dueDate != null && 
          _isToday(task.dueDate!)
        ).toList();
        break;
      case 'completed':
        _filteredTasks = _tasks.where((task) => task.isCompleted).toList();
        break;
      case 'pending':
        _filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case 'high_priority':
        _filteredTasks = _tasks.where((task) => 
          task.priority == TaskPriority.high && !task.isCompleted
        ).toList();
        break;
      default:
        _filteredTasks = _tasks;
    }
    
    // Sort by priority and due date
    _filteredTasks.sort((a, b) {
      if (a.priority.index != b.priority.index) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    await _memoryService.storeTaskData(_tasks);
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasks();
      await _memoryService.storeTaskData(_tasks);
      _applyFilter();
      notifyListeners();
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    await _memoryService.storeTaskData(_tasks);
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
        completedAt: !_tasks[index].isCompleted ? DateTime.now() : null,
      );
      await _saveTasks();
      await _memoryService.storeTaskData(_tasks);
      _applyFilter();
      notifyListeners();
    }
  }
  
  // AI-powered task prioritization
  void prioritizeTasks() {
    // Simple AI prioritization based on due date, priority, and completion status
    _tasks.sort((a, b) {
      // First, prioritize incomplete tasks
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      // Then by priority
      if (a.priority.index != b.priority.index) {
        return b.priority.index.compareTo(a.priority.index);
      }
      
      // Then by due date (sooner first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      
      // Tasks with due dates come before those without
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      
      return 0;
    });
    
    _applyFilter();
    notifyListeners();
  }
  
  List<Task> getTodayTasks() {
    return _tasks.where((task) => 
      task.dueDate != null && _isToday(task.dueDate!)
    ).toList();
  }
  
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) && 
      !task.isCompleted
    ).toList();
  }
  
  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => _tasks.length;
  double get completionRate => totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;
} 