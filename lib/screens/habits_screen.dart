import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../utils/theme.dart';
import '../widgets/habit_list_item.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final List<String> _filters = [
    'all',
    'active',
    'completed_today',
    'pending_today',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-habit');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatsCard(
                        title: 'Active',
                        value: '${habitProvider.activeHabitsCount}',
                        icon: Icons.repeat,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatsCard(
                        title: 'Completed Today',
                        value: '${habitProvider.completedTodayCount}',
                        icon: Icons.check_circle,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatsCard(
                        title: 'Completion Rate',
                        value: '${(habitProvider.todayCompletionRate * 100).toInt()}%',
                        icon: Icons.trending_up,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = habitProvider.currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: isSelected,
                          onSelected: (selected) {
                            habitProvider.setFilter(filter);
                          },
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected 
                              ? AppTheme.primaryGreen 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          
          // Habits list
          Expanded(
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                final habits = habitProvider.filteredHabits;
                
                if (habits.isEmpty) {
                  return _buildEmptyState(context, habitProvider.currentFilter);
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    return HabitListItem(habit: habits[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    String title;
    String subtitle;
    IconData icon;
    
    switch (filter) {
      case 'active':
        title = 'No active habits';
        subtitle = 'Create some habits to start building consistency';
        icon = Icons.repeat;
        break;
      case 'completed_today':
        title = 'No completed habits today';
        subtitle = 'Complete some habits to see them here';
        icon = Icons.check_circle;
        break;
      case 'pending_today':
        title = 'No pending habits today';
        subtitle = 'All your habits are completed! Great job!';
        icon = Icons.done_all;
        break;
      default:
        title = 'No habits yet';
        subtitle = 'Create your first habit to get started';
        icon = Icons.repeat;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddHabitDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'active':
        return 'Active';
      case 'completed_today':
        return 'Completed Today';
      case 'pending_today':
        return 'Pending Today';
      default:
        return 'All';
    }
  }

  void _showAddHabitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitSheet(),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitCategory _category = HabitCategory.other;
  List<String> _selectedDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  int _targetCount = 1;

  final List<Map<String, dynamic>> _days = [
    {'key': 'monday', 'label': 'Mon'},
    {'key': 'tuesday', 'label': 'Tue'},
    {'key': 'wednesday', 'label': 'Wed'},
    {'key': 'thursday', 'label': 'Thu'},
    {'key': 'friday', 'label': 'Fri'},
    {'key': 'saturday', 'label': 'Sat'},
    {'key': 'sunday', 'label': 'Sun'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Add New Habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'Enter habit title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter habit description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Category
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: HabitCategory.values.map((category) {
                final isSelected = _category == category;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Habit.getCategoryIcon(category),
                        size: 16,
                        color: isSelected 
                          ? Colors.white 
                          : Habit.getCategoryColor(category),
                      ),
                      const SizedBox(width: 4),
                      Text(Habit.getCategoryLabel(category)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _category = category;
                    });
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: Habit.getCategoryColor(category),
                  labelStyle: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Frequency
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _days.map((day) {
                final isSelected = _selectedDays.contains(day['key']);
                return FilterChip(
                  label: Text(day['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day['key']);
                      } else {
                        _selectedDays.remove(day['key']);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected 
                      ? AppTheme.primaryGreen 
                      : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Target count
            Text(
              'Target Count',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_targetCount > 1) {
                      setState(() {
                        _targetCount--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    '$_targetCount',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _targetCount++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addHabit,
                child: const Text('Add Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addHabit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      final now = DateTime.now();
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        category: _category,
        frequency: _selectedDays,
        targetCount: _targetCount,
        createdAt: now,
        updatedAt: now,
      );
      
      context.read<HabitProvider>().addHabit(habit);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
} 