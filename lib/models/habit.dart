import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly, monthly }

enum HabitCategory { health, productivity, learning, mindfulness, fitness, other }

class Habit {
  final String id;
  final String title;
  final String? description;
  final HabitCategory category;
  final List<String> frequency; // ['monday', 'tuesday', etc.]
  final bool isActive;
  final Map<String, DateTime> completions; // date key -> completion time
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? aiMotivation;
  final int targetCount; // for habits like "drink 8 glasses of water"
  final int currentCount; // current count for today

  const Habit({
    required this.id,
    required this.title,
    this.description,
    this.category = HabitCategory.other,
    this.frequency = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    this.isActive = true,
    this.completions = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.aiMotivation,
    this.targetCount = 1,
    this.currentCount = 0,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitCategory? category,
    List<String>? frequency,
    bool? isActive,
    Map<String, DateTime>? completions,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? aiMotivation,
    int? targetCount,
    int? currentCount,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      completions: completions ?? this.completions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      aiMotivation: aiMotivation ?? this.aiMotivation,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'frequency': frequency,
      'isActive': isActive,
      'completions': completions.map((key, value) => MapEntry(key, value.toIso8601String())),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'aiMotivation': aiMotivation,
      'targetCount': targetCount,
      'currentCount': currentCount,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final completionsMap = <String, DateTime>{};
    final completionsJson = json['completions'] as Map<String, dynamic>;
    for (final entry in completionsJson.entries) {
      completionsMap[entry.key] = DateTime.parse(entry.value as String);
    }

    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: HabitCategory.values[json['category'] as int],
      frequency: List<String>.from(json['frequency'] as List),
      isActive: json['isActive'] as bool,
      completions: completionsMap,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: List<String>.from(json['tags'] as List),
      aiMotivation: json['aiMotivation'] as String?,
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int,
    );
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    return completions.containsKey(todayKey);
  }

  bool get isDueToday {
    final today = DateTime.now();
    final dayOfWeek = _getDayOfWeek(today);
    return frequency.contains(dayOfWeek);
  }

  bool get isCompleted {
    if (targetCount <= 1) {
      return isCompletedToday;
    }
    return currentCount >= targetCount;
  }

  double get completionProgress {
    if (targetCount <= 1) {
      return isCompletedToday ? 1.0 : 0.0;
    }
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[date.weekday - 1];
  }

  String get categoryLabel {
    switch (category) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.other:
        return 'Other';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case HabitCategory.health:
        return Icons.favorite;
      case HabitCategory.productivity:
        return Icons.work;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.mindfulness:
        return Icons.self_improvement;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.other:
        return Icons.repeat;
    }
  }

  Color get categoryColor {
    switch (category) {
      case HabitCategory.health:
        return Colors.red;
      case HabitCategory.productivity:
        return Colors.blue;
      case HabitCategory.learning:
        return Colors.green;
      case HabitCategory.mindfulness:
        return Colors.purple;
      case HabitCategory.fitness:
        return Colors.orange;
      case HabitCategory.other:
        return Colors.grey;
    }
  }

  static String getCategoryLabel(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.other:
        return 'Other';
    }
  }

  static IconData getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.favorite;
      case HabitCategory.productivity:
        return Icons.work;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.mindfulness:
        return Icons.self_improvement;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.other:
        return Icons.repeat;
    }
  }

  static Color getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Colors.red;
      case HabitCategory.productivity:
        return Colors.blue;
      case HabitCategory.learning:
        return Colors.green;
      case HabitCategory.mindfulness:
        return Colors.purple;
      case HabitCategory.fitness:
        return Colors.orange;
      case HabitCategory.other:
        return Colors.grey;
    }
  }

  String get frequencyLabel {
    if (frequency.length == 7) {
      return 'Daily';
    } else if (frequency.length == 5 && 
               frequency.contains('monday') && 
               frequency.contains('tuesday') && 
               frequency.contains('wednesday') && 
               frequency.contains('thursday') && 
               frequency.contains('friday')) {
      return 'Weekdays';
    } else if (frequency.length == 2 && 
               frequency.contains('saturday') && 
               frequency.contains('sunday')) {
      return 'Weekends';
    } else {
      return 'Custom';
    }
  }

  String get streakText {
    if (currentStreak == 0) {
      return 'No streak yet';
    } else if (currentStreak == 1) {
      return '1 day streak';
    } else {
      return '$currentStreak day streak';
    }
  }

  String get motivationText {
    if (aiMotivation != null && aiMotivation!.isNotEmpty) {
      return aiMotivation!;
    }
    
    if (currentStreak == 0) {
      return 'Start your journey today!';
    } else if (currentStreak < 7) {
      return 'Great start! Keep it up!';
    } else if (currentStreak < 30) {
      return 'You\'re building a solid foundation!';
    } else {
      return 'Incredible dedication! You\'re unstoppable!';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, currentStreak: $currentStreak)';
  }
} 