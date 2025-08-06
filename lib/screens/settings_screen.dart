import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/ai_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          _SettingsSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primaryBlue,
                    ),
                    title: const Text('Theme'),
                    subtitle: Text(
                      themeProvider.themeMode == ThemeMode.system
                          ? 'System'
                          : themeProvider.themeMode == ThemeMode.light
                              ? 'Light'
                              : 'Dark',
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeProvider.setThemeMode(newValue);
                        }
                      },
                      items: ThemeMode.values.map((ThemeMode mode) {
                        return DropdownMenuItem<ThemeMode>(
                          value: mode,
                          child: Text(
                            mode == ThemeMode.system
                                ? 'System'
                                : mode == ThemeMode.light
                                    ? 'Light'
                                    : 'Dark',
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // AI Features
          _SettingsSection(
            title: 'AI Features',
            children: [
              Consumer<AIProvider>(
                builder: (context, aiProvider, child) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: const Text('Smart Insights'),
                    subtitle: Text(
                      aiProvider.isUsingAdvancedAI 
                          ? 'Advanced AI (Premium)'
                          : 'Basic AI (Free)',
                    ),
                    trailing: Icon(
                      aiProvider.isUsingAdvancedAI ? Icons.star : Icons.check_circle,
                      color: aiProvider.isUsingAdvancedAI ? AppTheme.primaryPurple : AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
              Consumer<AIProvider>(
                builder: (context, aiProvider, child) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.priority_high,
                        color: AppTheme.primaryOrange,
                        size: 20,
                      ),
                    ),
                    title: const Text('Task Prioritization'),
                    subtitle: Text(
                      aiProvider.isUsingAdvancedAI 
                          ? 'Advanced AI prioritization'
                          : 'Basic priority sorting',
                    ),
                    trailing: Icon(
                      aiProvider.isUsingAdvancedAI ? Icons.star : Icons.check_circle,
                      color: aiProvider.isUsingAdvancedAI ? AppTheme.primaryPurple : AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
              Consumer<AIProvider>(
                builder: (context, aiProvider, child) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                    ),
                    title: const Text('Habit Suggestions'),
                    subtitle: Text(
                      aiProvider.isUsingAdvancedAI 
                          ? 'AI-powered habit coaching'
                          : 'Basic habit recommendations',
                    ),
                    trailing: Icon(
                      aiProvider.isUsingAdvancedAI ? Icons.star : Icons.check_circle,
                      color: aiProvider.isUsingAdvancedAI ? AppTheme.primaryPurple : AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Premium Features
          _SettingsSection(
            title: 'Premium Features',
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                title: const Text('Upgrade to Premium'),
                subtitle: const Text('Unlock advanced AI features and analytics'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  _showPremiumDialog(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                title: const Text('Advanced Analytics'),
                subtitle: const Text('Detailed insights and progress reports'),
                trailing: const Icon(Icons.lock, size: 16),
                onTap: () {
                  _showPremiumFeatureDialog(context, 'Advanced Analytics');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppTheme.primaryOrange,
                    size: 20,
                  ),
                ),
                title: const Text('AI Habit Coaching'),
                subtitle: const Text('Personalized habit formation guidance'),
                trailing: const Icon(Icons.lock, size: 16),
                onTap: () {
                  _showPremiumFeatureDialog(context, 'AI Habit Coaching');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bedtime,
                    color: AppTheme.primaryRed,
                    size: 20,
                  ),
                ),
                title: const Text('Sleep Optimization'),
                subtitle: const Text('AI-powered sleep recommendations'),
                trailing: const Icon(Icons.lock, size: 16),
                onTap: () {
                  _showPremiumFeatureDialog(context, 'Sleep Optimization');
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // App Info
          _SettingsSection(
            title: 'App Info',
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                title: const Text('About DailyFlow'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.privacy_tip,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                title: const Text('Privacy Policy'),
                subtitle: const Text('How we protect your data'),
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                title: const Text('Terms of Service'),
                subtitle: const Text('Usage terms and conditions'),
                onTap: () {
                  _showTermsDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text(
          'Unlock advanced features including:\n\n'
          '• AI-powered habit coaching\n'
          '• Advanced analytics and insights\n'
          '• Sleep optimization recommendations\n'
          '• Custom themes and personalization\n'
          '• Priority support\n\n'
          'Coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium features coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Get Notified'),
          ),
        ],
      ),
    );
  }

  void _showPremiumFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature - Premium Feature'),
        content: Text(
          '$feature is a premium feature that will be available in the upcoming update. '
          'Upgrade to Premium to unlock this and many other advanced features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPremiumDialog(context);
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About DailyFlow'),
        content: const Text(
          'DailyFlow is an AI-powered productivity app designed to help you organize your life, '
          'build better habits, and achieve your goals.\n\n'
          'Version: 1.0.0\n'
          'Build: 2024.1.0\n\n'
          'Made with ❤️ for productivity enthusiasts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'DailyFlow respects your privacy. We collect minimal data necessary to provide our services. '
          'Your personal data is stored locally on your device and is never shared with third parties '
          'without your explicit consent.\n\n'
          'For more information, please contact our support team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text(
          'By using DailyFlow, you agree to our terms of service. '
          'The app is provided "as is" without any warranties. '
          'We are not responsible for any data loss or damages.\n\n'
          'For complete terms, please visit our website.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
} 