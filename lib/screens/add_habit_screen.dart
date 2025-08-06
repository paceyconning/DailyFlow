import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  HabitCategory _category = HabitCategory.health;
  List<String> _frequency = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  int _targetCount = 1;
  List<String> _tags = [];

  final List<String> _daysOfWeek = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

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
        title: const Text('Add Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
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
                  labelText: 'Habit Title',
                  hintText: 'Enter habit title',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
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
              
              // Frequency
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildFrequencySelector(),
              
              const SizedBox(height: 24),
              
              // Target Count
              Text(
                'Target Count',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTargetCountSelector(),
              
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitCategory.values.map((category) {
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

  Widget _buildFrequencySelector() {
    return Column(
      children: [
        // Quick select buttons
        Row(
          children: [
            Expanded(
              child: _buildQuickSelectButton('Daily', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickSelectButton('Weekdays', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickSelectButton('Weekends', ['saturday', 'sunday']),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Individual day selectors
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _daysOfWeek.map((day) {
            final isSelected = _frequency.contains(day);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _frequency.remove(day);
                  } else {
                    _frequency.add(day);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  day.substring(0, 1).toUpperCase() + day.substring(1, 3),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(String label, List<String> days) {
    final isSelected = _frequency.length == days.length && 
                      days.every((day) => _frequency.contains(day));
    
    return GestureDetector(
      onTap: () => setState(() => _frequency = List.from(days)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTargetCountSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _targetCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_targetCount',
                onChanged: (value) {
                  setState(() {
                    _targetCount = value.round();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_targetCount',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Text(
          _targetCount == 1 
            ? 'Complete once per day'
            : 'Complete $_targetCount times per day',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
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

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (_frequency.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day for your habit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _category,
        frequency: _frequency,
        targetCount: _targetCount,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<HabitProvider>().addHabit(habit);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 