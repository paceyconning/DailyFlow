import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  static const String _habitsKey = 'habits';
  
  List<Habit> _habits = [];
  List<Habit> _filteredHabits = [];
  String _currentFilter = 'all';
  
  List<Habit> get habits => _habits;
  List<Habit> get filteredHabits => _filteredHabits;
  String get currentFilter => _currentFilter;
  
  HabitProvider() {
    _loadHabits();
  }
  
  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    
    _habits = habitsJson
        .map((json) => Habit.fromJson(jsonDecode(json)))
        .toList();
    
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = _habits
        .map((habit) => jsonEncode(habit.toJson()))
        .toList();
    await prefs.setStringList(_habitsKey, habitsJson);
  }
  
  void _applyFilter() {
    switch (_currentFilter) {
      case 'active':
        _filteredHabits = _habits.where((habit) => habit.isActive).toList();
        break;
      case 'completed_today':
        _filteredHabits = _habits.where((habit) => 
          habit.isActive && habit.isCompletedToday
        ).toList();
        break;
      case 'pending_today':
        _filteredHabits = _habits.where((habit) => 
          habit.isActive && !habit.isCompletedToday
        ).toList();
        break;
      default:
        _filteredHabits = _habits;
    }
    
    // Sort by streak and completion status
    _filteredHabits.sort((a, b) {
      if (a.isCompletedToday != b.isCompletedToday) {
        return a.isCompletedToday ? 1 : -1;
      }
      return b.currentStreak.compareTo(a.currentStreak);
    });
  }
  
  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      await _saveHabits();
      _applyFilter();
      notifyListeners();
    }
  }
  
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    await _saveHabits();
    _applyFilter();
    notifyListeners();
  }
  
  Future<void> toggleHabitCompletion(String habitId) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final todayKey = _getDateKey(today);
      
      if (habit.isCompletedToday) {
        // Remove today's completion
        final updatedCompletions = Map<String, DateTime>.from(habit.completions);
        updatedCompletions.remove(todayKey);
        
        _habits[index] = habit.copyWith(
          completions: updatedCompletions,
          currentStreak: _calculateStreak(updatedCompletions),
        );
      } else {
        // Add today's completion
        final updatedCompletions = Map<String, DateTime>.from(habit.completions);
        updatedCompletions[todayKey] = today;
        
        _habits[index] = habit.copyWith(
          completions: updatedCompletions,
          currentStreak: _calculateStreak(updatedCompletions),
          longestStreak: _calculateLongestStreak(updatedCompletions),
        );
      }
      
      await _saveHabits();
      _applyFilter();
      notifyListeners();
    }
  }
  
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  int _calculateStreak(Map<String, DateTime> completions) {
    if (completions.isEmpty) return 0;
    
    final sortedDates = completions.keys
        .map((key) => DateTime.parse(key))
        .toList()
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final expectedDate = i == 0 ? today : today.subtract(Duration(days: i));
      
      if (_isSameDay(date, expectedDate) || _isSameDay(date, expectedDate.subtract(const Duration(days: 1)))) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  int _calculateLongestStreak(Map<String, DateTime> completions) {
    if (completions.isEmpty) return 0;
    
    final sortedDates = completions.keys
        .map((key) => DateTime.parse(key))
        .toList()
      ..sort();
    
    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final date in sortedDates) {
      if (lastDate == null || _isConsecutiveDay(lastDate, date)) {
        currentStreak++;
      } else {
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
        currentStreak = 1;
      }
      lastDate = date;
    }
    
    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
    return longestStreak;
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  bool _isConsecutiveDay(DateTime a, DateTime b) {
    final difference = b.difference(a).inDays;
    return difference == 1;
  }
  
  List<Habit> getTodayHabits() {
    return _habits.where((habit) => 
      habit.isActive && habit.frequency.contains(_getDayOfWeek())
    ).toList();
  }
  
  String _getDayOfWeek() {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[DateTime.now().weekday - 1];
  }
  
  List<Habit> getCompletedTodayHabits() {
    return _habits.where((habit) => 
      habit.isActive && habit.isCompletedToday
    ).toList();
  }
  
  List<Habit> getPendingTodayHabits() {
    return _habits.where((habit) => 
      habit.isActive && !habit.isCompletedToday && habit.frequency.contains(_getDayOfWeek())
    ).toList();
  }
  
  int get totalHabitsCount => _habits.length;
  int get activeHabitsCount => _habits.where((habit) => habit.isActive).length;
  int get completedTodayCount => getCompletedTodayHabits().length;
  int get pendingTodayCount => getPendingTodayHabits().length;
  double get todayCompletionRate => 
    (completedTodayCount + pendingTodayCount) > 0 
      ? completedTodayCount / (completedTodayCount + pendingTodayCount) 
      : 0.0;
} 