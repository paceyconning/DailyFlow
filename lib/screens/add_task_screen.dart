import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.personal;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _estimatedMinutes = 30;
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Priority
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildPrioritySelector(),
              
              const SizedBox(height: 24),
              
              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildCategorySelector(),
              
              const SizedBox(height: 24),
              
              // Due Date & Time
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Estimated Time
              Text(
                'Estimated Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTimeEstimator(),
              
              const SizedBox(height: 24),
              
              // Tags
              Text(
                'Tags (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTagInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = priority),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? priority.color : priority.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: priority.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    priority.icon,
                    color: isSelected ? Colors.white : priority.color,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priority.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : priority.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskCategory.values.map((category) {
        final isSelected = _category == category;
        return GestureDetector(
          onTap: () => setState(() => _category = category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? category.color : category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: category.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? Colors.white : category.color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  category.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _dueDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _dueDate != null 
                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                : 'Set Due Date',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _dueTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _dueTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _dueTime != null 
                ? _dueTime!.format(context)
                : 'Set Time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeEstimator() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _estimatedMinutes.toDouble(),
            min: 5,
            max: 240,
            divisions: 47,
            label: '${_estimatedMinutes} min',
            onChanged: (value) {
              setState(() {
                _estimatedMinutes = value.round();
              });
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_estimatedMinutes} min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Add a tag (press Enter)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (tag) {
                  if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
                    setState(() {
                      _tags.add(tag.trim());
                    });
                  }
                },
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: _dueDate != null && _dueTime != null
            ? DateTime(
                _dueDate!.year,
                _dueDate!.month,
                _dueDate!.day,
                _dueTime!.hour,
                _dueTime!.minute,
              )
            : _dueDate,
        estimatedMinutes: _estimatedMinutes,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<TaskProvider>().addTask(task);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 