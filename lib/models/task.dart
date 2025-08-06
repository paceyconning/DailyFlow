import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskCategory { work, personal, health, learning, other }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.learning:
        return Icons.school;
      case TaskCategory.other:
        return Icons.task;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.learning:
        return Colors.green;
      case TaskCategory.other:
        return Colors.grey;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskCategory category;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int estimatedMinutes;
  final String? aiSuggestion;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.estimatedMinutes = 0,
    this.aiSuggestion,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? estimatedMinutes,
    String? aiSuggestion,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'estimatedMinutes': estimatedMinutes,
      'aiSuggestion': aiSuggestion,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: TaskPriority.values[json['priority'] as int],
      category: TaskCategory.values[json['category'] as int],
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: List<String>.from(json['tags'] as List),
      estimatedMinutes: json['estimatedMinutes'] as int,
      aiSuggestion: json['aiSuggestion'] as String?,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year && 
           dueDate!.month == now.month && 
           dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year && 
           dueDate!.month == tomorrow.month && 
           dueDate!.day == tomorrow.day;
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  String get categoryLabel {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.other:
        return 'Other';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.learning:
        return Icons.school;
      case TaskCategory.other:
        return Icons.task;
    }
  }

  static String getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.other:
        return 'Other';
    }
  }

  static IconData getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.learning:
        return Icons.school;
      case TaskCategory.other:
        return Icons.task;
    }
  }

  static Color getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.learning:
        return Colors.green;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  String get timeUntilDue {
    if (dueDate == null) return 'No due date';
    
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    
    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return '$days day${days == 1 ? '' : 's'} overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} left';
    } else {
      return 'Due now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
  }
} 