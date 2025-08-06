import 'dart:math';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Task Analytics
  Map<String, int> _taskCompletionByCategory = {};
  Map<String, int> _taskCompletionByPriority = {};
  List<DateTime> _taskCompletionTimes = [];
  List<int> _dailyTaskCompletions = [];

  // Habit Analytics
  Map<String, int> _habitStreaks = {};
  Map<String, double> _habitCompletionRates = {};
  List<DateTime> _habitCompletionTimes = [];
  List<int> _dailyHabitCompletions = [];

  // Productivity Analytics
  DateTime? _lastActiveTime;
  int _totalSessions = 0;
  int _totalActiveMinutes = 0;

  // Task Analytics Methods
  void recordTaskCompletion(String category, String priority) {
    _taskCompletionByCategory[category] = (_taskCompletionByCategory[category] ?? 0) + 1;
    _taskCompletionByPriority[priority] = (_taskCompletionByPriority[priority] ?? 0) + 1;
    _taskCompletionTimes.add(DateTime.now());
    
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    _dailyTaskCompletions.add(today.day);
  }

  void recordHabitCompletion(String habitId, int streak) {
    _habitStreaks[habitId] = streak;
    _habitCompletionTimes.add(DateTime.now());
    
    final today = DateTime.now();
    _dailyHabitCompletions.add(today.day);
  }

  void updateHabitCompletionRate(String habitId, double rate) {
    _habitCompletionRates[habitId] = rate;
  }

  // Productivity Analytics Methods
  void recordSessionStart() {
    _lastActiveTime = DateTime.now();
    _totalSessions++;
  }

  void recordSessionEnd() {
    if (_lastActiveTime != null) {
      final duration = DateTime.now().difference(_lastActiveTime!);
      _totalActiveMinutes += duration.inMinutes;
    }
  }

  // Analytics Getters
  Map<String, int> get taskCompletionByCategory => Map.from(_taskCompletionByCategory);
  Map<String, int> get taskCompletionByPriority => Map.from(_taskCompletionByPriority);
  Map<String, int> get habitStreaks => Map.from(_habitStreaks);
  Map<String, double> get habitCompletionRates => Map.from(_habitCompletionRates);

  int get totalTasksCompleted => _taskCompletionTimes.length;
  int get totalHabitsCompleted => _habitCompletionTimes.length;
  int get totalSessions => _totalSessions;
  int get totalActiveMinutes => _totalActiveMinutes;

  // Productivity Insights
  String get productivityInsight {
    if (_dailyTaskCompletions.isEmpty && _dailyHabitCompletions.isEmpty) {
      return "Start your productivity journey today!";
    }

    final avgTasksPerDay = _dailyTaskCompletions.isNotEmpty 
        ? _dailyTaskCompletions.reduce((a, b) => a + b) / _dailyTaskCompletions.length 
        : 0.0;
    
    final avgHabitsPerDay = _dailyHabitCompletions.isNotEmpty 
        ? _dailyHabitCompletions.reduce((a, b) => a + b) / _dailyHabitCompletions.length 
        : 0.0;

    if (avgTasksPerDay > 5 && avgHabitsPerDay > 3) {
      return "You're incredibly productive! Keep up the amazing work!";
    } else if (avgTasksPerDay > 3 && avgHabitsPerDay > 2) {
      return "Great progress! You're building solid habits.";
    } else if (avgTasksPerDay > 1 && avgHabitsPerDay > 1) {
      return "Good start! Try to complete a few more tasks each day.";
    } else {
      return "Every journey starts with a single step. Keep going!";
    }
  }

  // Time-based Analytics
  String get mostProductiveTime {
    if (_taskCompletionTimes.isEmpty) return "No data yet";

    final hourCounts = <int, int>{};
    for (final time in _taskCompletionTimes) {
      final hour = time.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final mostProductiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    if (mostProductiveHour < 12) {
      return "Morning (${mostProductiveHour}:00)";
    } else if (mostProductiveHour < 17) {
      return "Afternoon (${mostProductiveHour}:00)";
    } else {
      return "Evening (${mostProductiveHour}:00)";
    }
  }

  // Category Insights
  String get mostProductiveCategory {
    if (_taskCompletionByCategory.isEmpty) return "No data yet";

    final mostProductive = _taskCompletionByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return "${mostProductive.key} (${mostProductive.value} tasks)";
  }

  // Streak Analytics
  int get longestHabitStreak {
    if (_habitStreaks.isEmpty) return 0;
    return _habitStreaks.values.reduce(max);
  }

  double get averageHabitCompletionRate {
    if (_habitCompletionRates.isEmpty) return 0.0;
    return _habitCompletionRates.values.reduce((a, b) => a + b) / _habitCompletionRates.length;
  }

  // Weekly Progress
  List<int> get weeklyTaskProgress {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weeklyTasks = <int>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayTasks = _taskCompletionTimes.where((time) => 
        time.year == day.year && 
        time.month == day.month && 
        time.day == day.day
      ).length;
      weeklyTasks.add(dayTasks);
    }
    
    return weeklyTasks;
  }

  // Reset Analytics (for testing)
  void resetAnalytics() {
    _taskCompletionByCategory.clear();
    _taskCompletionByPriority.clear();
    _taskCompletionTimes.clear();
    _dailyTaskCompletions.clear();
    _habitStreaks.clear();
    _habitCompletionRates.clear();
    _habitCompletionTimes.clear();
    _dailyHabitCompletions.clear();
    _lastActiveTime = null;
    _totalSessions = 0;
    _totalActiveMinutes = 0;
  }
} 