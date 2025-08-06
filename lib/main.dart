import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/add_habit_screen.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/ai_service.dart';
import 'providers/ai_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationService().initialize();
  AnalyticsService().recordSessionStart();
  
  // Initialize providers
  final themeProvider = ThemeProvider();
  final taskProvider = TaskProvider();
  final habitProvider = HabitProvider();
  final aiProvider = AIProvider();
  
  // Initialize AI provider
  await aiProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => taskProvider),
        ChangeNotifierProvider(create: (_) => habitProvider),
        ChangeNotifierProvider(create: (_) => aiProvider),
      ],
      child: const DailyFlowApp(),
    ),
  );
}

class DailyFlowApp extends StatelessWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DailyFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainNavigationScreen(),
          routes: {
            '/tasks': (context) => const TasksScreen(),
            '/habits': (context) => const HabitsScreen(),
            '/add-task': (context) => const AddTaskScreen(),
            '/add-habit': (context) => const AddHabitScreen(),
          },
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const HabitsScreen(),
    const AnalyticsScreen(),
    const GoalsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined),
              activeIcon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.repeat_outlined),
              activeIcon: Icon(Icons.repeat),
              label: 'Habits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
