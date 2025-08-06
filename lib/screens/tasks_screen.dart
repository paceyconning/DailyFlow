import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../widgets/task_list_item.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<String> _filters = [
    'all',
    'today',
    'pending',
    'completed',
    'high_priority',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              context.read<TaskProvider>().prioritizeTasks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasks prioritized using AI'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'AI Prioritize',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTaskDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = taskProvider.currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: isSelected,
                          onSelected: (selected) {
                            taskProvider.setFilter(filter);
                          },
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected 
                              ? AppTheme.primaryBlue 
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
          
          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final tasks = taskProvider.filteredTasks;
                
                if (tasks.isEmpty) {
                  return _buildEmptyState(context, taskProvider.currentFilter);
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskListItem(task: tasks[index]);
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
      case 'today':
        title = 'No tasks for today';
        subtitle = 'Add some tasks to get started with your day';
        icon = Icons.today;
        break;
      case 'pending':
        title = 'No pending tasks';
        subtitle = 'All your tasks are completed! Great job!';
        icon = Icons.check_circle;
        break;
      case 'completed':
        title = 'No completed tasks';
        subtitle = 'Complete some tasks to see them here';
        icon = Icons.done_all;
        break;
      case 'high_priority':
        title = 'No high priority tasks';
        subtitle = 'Add some important tasks to see them here';
        icon = Icons.priority_high;
        break;
      default:
        title = 'No tasks yet';
        subtitle = 'Create your first task to get started';
        icon = Icons.task;
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
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'today':
        return 'Today';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'high_priority':
        return 'High Priority';
      default:
        return 'All';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.other;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

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
                  'Add New Task',
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
                labelText: 'Task Title',
                hintText: 'Enter task title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
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
                hintText: 'Enter task description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Priority
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _priority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(priority.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _priority = priority;
                        });
                      },
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Task.getPriorityColor(priority).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected 
                          ? Task.getPriorityColor(priority)
                          : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
              children: TaskCategory.values.map((category) {
                final isSelected = _category == category;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Task.getCategoryIcon(category),
                        size: 16,
                        color: isSelected 
                          ? Colors.white 
                          : Task.getCategoryColor(category),
                      ),
                      const SizedBox(width: 4),
                      Text(Task.getCategoryLabel(category)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _category = category;
                    });
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: Task.getCategoryColor(category),
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
            
            // Due date
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _dueDate == null ? 'No due date' : 'Due date',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      _dueDate == null 
                        ? 'Set a due date' 
                        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _dueDate = date;
                        });
                      }
                    },
                  ),
                ),
                if (_dueDate != null)
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _dueTime == null ? 'No time' : 'Due time',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        _dueTime == null 
                          ? 'Set a time' 
                          : _dueTime!.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _dueTime = time;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text('Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      DateTime? dueDate;
      
      if (_dueDate != null) {
        if (_dueTime != null) {
          dueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          dueDate = _dueDate;
        }
      }
      
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        dueDate: dueDate,
        priority: _priority,
        category: _category,
        createdAt: now,
        updatedAt: now,
      );
      
      context.read<TaskProvider>().addTask(task);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
} 