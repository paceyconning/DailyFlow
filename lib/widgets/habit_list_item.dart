import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/theme.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;

  const HabitListItem({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: habit.isCompletedToday 
            ? habit.categoryColor.withOpacity(0.3)
            : habit.categoryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
                  child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.read<HabitProvider>().toggleHabitCompletion(habit.id);
            },
            onLongPress: () {
              _showDeleteDialog(context);
            },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Completion indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: habit.isCompletedToday 
                        ? habit.categoryColor
                        : habit.categoryColor.withOpacity(0.5),
                      width: 2,
                    ),
                    color: habit.isCompletedToday 
                      ? habit.categoryColor
                      : Colors.transparent,
                  ),
                  child: habit.isCompletedToday
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
                ),
                
                const SizedBox(width: 16),
                
                // Habit details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: habit.isCompletedToday 
                                  ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                                  : null,
                              ),
                            ),
                          ),
                          if (habit.targetCount > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: habit.categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${habit.currentCount}/${habit.targetCount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: habit.categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      if (habit.description != null && habit.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: habit.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  habit.categoryIcon,
                                  size: 12,
                                  color: habit.categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  habit.categoryLabel,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: habit.categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Frequency
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              habit.frequencyLabel,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Delete button
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppTheme.primaryRed.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () => _showDeleteDialog(context),
                          ),
                          
                          // Streak
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: AppTheme.primaryOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  habit.streakText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Progress bar for multi-count habits
                      if (habit.targetCount > 1) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: habit.completionProgress,
                          backgroundColor: habit.categoryColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(habit.categoryColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Are you sure you want to delete "${habit.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<HabitProvider>().deleteHabit(habit.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
} 