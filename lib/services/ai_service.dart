import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/habit.dart';
import 'ai_memory_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Ollama server configuration
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'llama3'; // Can be changed to mistral, codellama, etc.

  // AI Memory Service
  final AIMemoryService _memoryService = AIMemoryService();

  // Cache for AI responses to avoid repeated API calls
  final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Generate AI insights for tasks and habits
  Future<Map<String, dynamic>> generateInsights({
    required List<Task> tasks,
    required List<Habit> habits,
    required Map<String, dynamic> userStats,
  }) async {
    try {
      // Store current data in AI memory
      await _memoryService.storeTaskData(tasks);
      await _memoryService.storeHabitData(habits);
      
      // Get comprehensive user data for AI analysis
      final userData = await _memoryService.getComprehensiveUserData();
      
      final prompt = _buildInsightsPrompt(tasks, habits, userStats, userData);
      final response = await _callOllama(prompt);
      
      if (response != null) {
        final insights = _parseInsightsResponse(response);
        
        // Store AI insight in memory
        await _memoryService.storeAIInsight(insights);
        
        return insights;
      }
      
      return _getDefaultInsights();
    } catch (e) {
      print('AI Service Error: $e');
      return _getDefaultInsights();
    }
  }

  /// Generate task prioritization recommendations
  Future<List<Task>> prioritizeTasks(List<Task> tasks) async {
    try {
      // Store current tasks in AI memory
      await _memoryService.storeTaskData(tasks);
      
      // Get task history for context
      final taskHistory = await _memoryService.getTaskHistory();
      final userPatterns = await _memoryService.getUserPatterns();
      
      final prompt = _buildTaskPrioritizationPrompt(tasks, taskHistory, userPatterns);
      final response = await _callOllama(prompt);
      
      if (response != null) {
        return _parseTaskPrioritizationResponse(response, tasks);
      }
      
      return tasks; // Return original order if AI fails
    } catch (e) {
      print('Task Prioritization Error: $e');
      return tasks;
    }
  }

  /// Generate habit suggestions based on user behavior
  Future<List<Map<String, dynamic>>> generateHabitSuggestions({
    required List<Habit> currentHabits,
    required Map<String, dynamic> userStats,
  }) async {
    try {
      // Store current habits in AI memory
      await _memoryService.storeHabitData(currentHabits);
      
      // Get habit history and patterns for context
      final habitHistory = await _memoryService.getHabitHistory();
      final userPatterns = await _memoryService.getUserPatterns();
      
      final prompt = _buildHabitSuggestionsPrompt(currentHabits, userStats, habitHistory, userPatterns);
      final response = await _callOllama(prompt);
      
      if (response != null) {
        return _parseHabitSuggestionsResponse(response);
      }
      
      return _getDefaultHabitSuggestions();
    } catch (e) {
      print('Habit Suggestions Error: $e');
      return _getDefaultHabitSuggestions();
    }
  }

  /// Generate motivational messages
  Future<String> generateMotivationalMessage({
    required Map<String, dynamic> userStats,
    required List<Task> recentTasks,
    required List<Habit> recentHabits,
  }) async {
    try {
      // Store current data in AI memory
      await _memoryService.storeTaskData(recentTasks);
      await _memoryService.storeHabitData(recentHabits);
      
      // Get comprehensive user data for personalized messages
      final userData = await _memoryService.getComprehensiveUserData();
      
      final prompt = _buildMotivationalPrompt(userStats, recentTasks, recentHabits, userData);
      final response = await _callOllama(prompt);
      
      if (response != null) {
        return _parseMotivationalResponse(response);
      }
      
      return _getDefaultMotivationalMessage();
    } catch (e) {
      print('Motivational Message Error: $e');
      return _getDefaultMotivationalMessage();
    }
  }

  /// Call Ollama API
  Future<String?> _callOllama(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
            'max_tokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String?;
      }
      
      return null;
    } catch (e) {
      print('Ollama API Error: $e');
      return null;
    }
  }

  /// Build prompt for general insights
  String _buildInsightsPrompt(List<Task> tasks, List<Habit> habits, Map<String, dynamic> userStats, Map<String, dynamic> userData) {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final activeHabits = habits.where((h) => h.isActive).length;
    final avgStreak = habits.isNotEmpty 
        ? habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length 
        : 0;

    final taskHistory = userData['taskHistory'] as List? ?? [];
    final habitHistory = userData['habitHistory'] as List? ?? [];
    final userPatterns = userData['userPatterns'] as Map<String, dynamic>? ?? {};
    final productivityStats = userData['productivityStats'] as Map<String, dynamic>? ?? {};

    return '''
You are an AI productivity coach with access to the user's complete history and patterns. Provide 3 actionable insights in JSON format.

Current User Data:
- Tasks completed: $completedTasks/$totalTasks
- Active habits: $activeHabits
- Average habit streak: ${avgStreak.toStringAsFixed(1)} days
- Most productive time: ${userStats['mostProductiveTime'] ?? 'Not available'}

User History & Patterns:
- Total tasks in history: ${taskHistory.length}
- Total habits in history: ${habitHistory.length}
- Average streak: ${userPatterns['averageStreak']?.toStringAsFixed(1) ?? '0'} days
- Category preferences: ${userPatterns['categoryPreferences']?.toString() ?? 'None'}
- Completion rate: ${(productivityStats['completionRate'] ?? 0.0) * 100}%

Recent Tasks: ${tasks.take(5).map((t) => '${t.title} (${t.isCompleted ? 'completed' : 'pending'})').join(', ')}

Recent Habits: ${habits.take(5).map((h) => '${h.title} (streak: ${h.currentStreak})').join(', ')}

Based on the user's history and patterns, provide personalized insights in this JSON format:
{
  "insights": [
    {
      "title": "Insight title",
      "description": "Detailed explanation based on user's history",
      "action": "Specific action to take",
      "type": "productivity|motivation|habit|task"
    }
  ],
  "priority_tasks": ["task1", "task2", "task3"],
  "motivational_message": "Personalized encouraging message"
}
''';
  }

  /// Build prompt for task prioritization
  String _buildTaskPrioritizationPrompt(List<Task> tasks, List<Map<String, dynamic>> taskHistory, Map<String, dynamic> userPatterns) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    
    return '''
You are an AI task prioritization assistant with access to the user's complete task history and patterns. Analyze these tasks and return them in priority order.

Current Tasks:
${pendingTasks.map((t) => '- ${t.title} (${t.priority.name}, due: ${t.dueDate?.toString() ?? 'no deadline'})').join('\n')}

User History & Patterns:
- Total tasks in history: ${taskHistory.length}
- Category preferences: ${userPatterns['categoryPreferences']?.toString() ?? 'None'}
- Completion patterns: ${userPatterns['completionPatterns']?.toString() ?? 'None'}

Return the task IDs in priority order as a JSON array:
["task_id_1", "task_id_2", "task_id_3", ...]

Consider:
- High priority tasks first
- Tasks with deadlines
- Task complexity and estimated time
- User's historical productivity patterns
- Category preferences and completion rates
- Time of day and user's typical schedule
''';
  }

  /// Build prompt for habit suggestions
  String _buildHabitSuggestionsPrompt(List<Habit> currentHabits, Map<String, dynamic> userStats, List<Map<String, dynamic>> habitHistory, Map<String, dynamic> userPatterns) {
    final weakHabits = currentHabits.where((h) => h.currentStreak < 3).length;
    final strongHabits = currentHabits.where((h) => h.currentStreak >= 7).length;

    return '''
You are an AI habit coach with access to the user's complete habit history and patterns. Suggest 2-3 new habits based on the user's current habits and historical patterns.

Current Habits: ${currentHabits.map((h) => '${h.title} (${h.frequencyLabel}, streak: ${h.currentStreak})').join(', ')}

User History & Patterns:
- Total habits in history: ${habitHistory.length}
- Average streak: ${userPatterns['averageStreak']?.toStringAsFixed(1) ?? '0'} days
- Category preferences: ${userPatterns['categoryPreferences']?.toString() ?? 'None'}
- Frequency preferences: ${userPatterns['frequencyPreferences']?.toString() ?? 'None'}
- Weak habits (streak < 3): $weakHabits
- Strong habits (streak >= 7): $strongHabits
- Completion rate: ${(userStats['completionRate'] ?? 0.0) * 100}%

Based on the user's historical patterns and preferences, suggest habits in JSON format:
{
  "suggestions": [
    {
      "title": "Habit name",
      "description": "Why this habit is beneficial based on user's patterns",
      "frequency": "daily|weekly|monthly",
      "category": "health|productivity|learning|social",
      "difficulty": "easy|medium|hard"
    }
  ]
}
''';
  }

  /// Build prompt for motivational messages
  String _buildMotivationalPrompt(Map<String, dynamic> userStats, List<Task> recentTasks, List<Habit> recentHabits, Map<String, dynamic> userData) {
    final completionRate = userStats['completionRate'] ?? 0.0;
    final avgStreak = userStats['averageStreak'] ?? 0.0;
    final taskHistory = userData['taskHistory'] as List? ?? [];
    final habitHistory = userData['habitHistory'] as List? ?? [];
    final userPatterns = userData['userPatterns'] as Map<String, dynamic>? ?? {};

    return '''
You are an AI motivational coach with access to the user's complete history and patterns. Generate a short, encouraging message (1-2 sentences) based on the user's recent activity and historical patterns.

Recent Activity:
- Task completion rate: ${(completionRate * 100).toInt()}%
- Average habit streak: ${avgStreak.toStringAsFixed(1)} days
- Recent tasks: ${recentTasks.take(3).map((t) => t.title).join(', ')}
- Recent habits: ${recentHabits.take(3).map((h) => h.title).join(', ')}

User History & Patterns:
- Total tasks completed: ${taskHistory.length}
- Total habits tracked: ${habitHistory.length}
- Average streak: ${userPatterns['averageStreak']?.toStringAsFixed(1) ?? '0'} days
- Category preferences: ${userPatterns['categoryPreferences']?.toString() ?? 'None'}

Generate a personalized motivational message that is:
- Encouraging but realistic
- Specific to their recent activity and historical patterns
- Actionable and positive
- 1-2 sentences maximum
- Based on their long-term progress and patterns
''';
  }

  /// Parse insights response
  Map<String, dynamic> _parseInsightsResponse(String response) {
    try {
      // Extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Failed to parse insights response: $e');
    }
    return _getDefaultInsights();
  }

  /// Parse task prioritization response
  List<Task> _parseTaskPrioritizationResponse(String response, List<Task> originalTasks) {
    try {
      // Extract JSON array from response
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final priorityIds = List<String>.from(jsonDecode(jsonStr));
        
        // Reorder tasks based on AI priority
        final taskMap = {for (var task in originalTasks) task.id: task};
        final prioritizedTasks = <Task>[];
        
        for (final id in priorityIds) {
          if (taskMap.containsKey(id)) {
            prioritizedTasks.add(taskMap[id]!);
          }
        }
        
        // Add any remaining tasks
        for (final task in originalTasks) {
          if (!prioritizedTasks.contains(task)) {
            prioritizedTasks.add(task);
          }
        }
        
        return prioritizedTasks;
      }
    } catch (e) {
      print('Failed to parse task prioritization response: $e');
    }
    return originalTasks;
  }

  /// Parse habit suggestions response
  List<Map<String, dynamic>> _parseHabitSuggestionsResponse(String response) {
    try {
      // Extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final data = jsonDecode(jsonStr);
        return List<Map<String, dynamic>>.from(data['suggestions'] ?? []);
      }
    } catch (e) {
      print('Failed to parse habit suggestions response: $e');
    }
    return _getDefaultHabitSuggestions();
  }

  /// Parse motivational response
  String _parseMotivationalResponse(String response) {
    try {
      // Clean up the response
      final cleanResponse = response.trim().replaceAll('"', '');
      if (cleanResponse.isNotEmpty) {
        return cleanResponse;
      }
    } catch (e) {
      print('Failed to parse motivational response: $e');
    }
    return _getDefaultMotivationalMessage();
  }

  /// Default insights when AI is unavailable
  Map<String, dynamic> _getDefaultInsights() {
    return {
      'insights': [
        {
          'title': 'Start Small',
          'description': 'Focus on completing 3 important tasks today to build momentum.',
          'action': 'Pick your top 3 tasks and tackle them first.',
          'type': 'productivity'
        },
        {
          'title': 'Build Consistency',
          'description': 'Your habit streaks show you\'re building good routines.',
          'action': 'Keep up the great work with your daily habits!',
          'type': 'habit'
        },
        {
          'title': 'Track Progress',
          'description': 'Monitor your completion rates to identify patterns.',
          'action': 'Review your analytics to see what\'s working best.',
          'type': 'motivation'
        }
      ],
      'priority_tasks': [],
      'motivational_message': 'You\'re making great progress! Keep up the momentum.'
    };
  }

  /// Default habit suggestions
  List<Map<String, dynamic>> _getDefaultHabitSuggestions() {
    return [
      {
        'title': 'Morning Routine',
        'description': 'Start your day with a consistent morning routine for better productivity.',
        'frequency': 'daily',
        'category': 'productivity',
        'difficulty': 'medium'
      },
      {
        'title': 'Evening Reflection',
        'description': 'Take 5 minutes each evening to reflect on your day and plan tomorrow.',
        'frequency': 'daily',
        'category': 'productivity',
        'difficulty': 'easy'
      }
    ];
  }

  /// Default motivational message
  String _getDefaultMotivationalMessage() {
    return 'You\'re doing great! Every small step counts toward your goals.';
  }

  /// Check if Ollama server is available
  Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        return models.map((m) => m['name'] as String).toList();
      }
    } catch (e) {
      print('Failed to get available models: $e');
    }
    return [];
  }
} 