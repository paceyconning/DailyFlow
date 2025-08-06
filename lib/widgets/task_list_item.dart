import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted 
            ? Colors.grey.withOpacity(0.2)
            : task.priorityColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<TaskProvider>().toggleTaskCompletion(task.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted 
                        ? task.priorityColor
                        : task.priorityColor.withOpacity(0.5),
                      width: 2,
                    ),
                    color: task.isCompleted 
                      ? task.priorityColor
                      : Colors.transparent,
                  ),
                  child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
                ),
                
                const SizedBox(width: 16),
                
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                                color: task.isCompleted 
                                  ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                                  : null,
                              ),
                            ),
                          ),
                          if (task.isOverdue && !task.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Overdue',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          // Priority indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priorityLabel,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: task.priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.categoryIcon,
                                  size: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.categoryLabel,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Due date/time
                          if (task.dueDate != null)
                            Text(
                              task.timeUntilDue,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: task.isOverdue && !task.isCompleted
                                  ? AppTheme.primaryRed
                                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                fontWeight: task.isOverdue && !task.isCompleted 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
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
} 