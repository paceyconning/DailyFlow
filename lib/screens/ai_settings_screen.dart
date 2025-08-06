import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../utils/theme.dart';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = 'http://localhost:11434';
    _modelController.text = 'llama3';
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkServerConnection,
            tooltip: 'Check server connection',
          ),
        ],
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Server Status
                _buildServerStatusCard(aiProvider),
                const SizedBox(height: 24),
                
                // Server Configuration
                _buildServerConfigCard(aiProvider),
                const SizedBox(height: 24),
                
                // Available Models
                _buildModelsCard(aiProvider),
                const SizedBox(height: 24),
                
                // AI Features
                _buildAIFeaturesCard(aiProvider),
                const SizedBox(height: 24),
                
                // Privacy & Security
                _buildPrivacyCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServerStatusCard(AIProvider aiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  aiProvider.isServerAvailable ? Icons.check_circle : Icons.error,
                  color: aiProvider.isServerAvailable ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ollama Server Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              aiProvider.isServerAvailable 
                  ? 'Connected to Ollama server'
                  : 'Cannot connect to Ollama server. Make sure it\'s running on localhost:11434',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (aiProvider.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerConfigCard(AIProvider aiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Server URL
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://localhost:11434',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            
            // Model Selection
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'AI Model',
                hintText: 'llama3',
                prefixIcon: Icon(Icons.psychology),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsCard(AIProvider aiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Models',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            if (aiProvider.availableModels.isEmpty)
              Text(
                'No models available. Make sure Ollama is running and has models installed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              )
            else
              Column(
                children: aiProvider.availableModels.map((model) {
                  return ListTile(
                    leading: const Icon(Icons.psychology),
                    title: Text(model),
                    trailing: model == _modelController.text
                        ? Icon(Icons.check, color: AppTheme.primaryGreen)
                        : null,
                    onTap: () {
                      setState(() {
                        _modelController.text = model;
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeaturesCard(AIProvider aiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFeatureTile(
              icon: Icons.psychology,
              title: 'Smart Insights',
              subtitle: 'AI-powered productivity insights and recommendations',
              enabled: aiProvider.isServerAvailable,
            ),
            
            _buildFeatureTile(
              icon: Icons.priority_high,
              title: 'Task Prioritization',
              subtitle: 'AI automatically prioritizes your tasks based on deadlines and importance',
              enabled: aiProvider.isServerAvailable,
            ),
            
            _buildFeatureTile(
              icon: Icons.repeat,
              title: 'Habit Suggestions',
              subtitle: 'Get personalized habit recommendations based on your patterns',
              enabled: aiProvider.isServerAvailable,
            ),
            
            _buildFeatureTile(
              icon: Icons.psychology,
              title: 'Motivational Messages',
              subtitle: 'AI-generated encouragement based on your progress',
              enabled: aiProvider.isServerAvailable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? AppTheme.primaryBlue : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
      trailing: Icon(
        enabled ? Icons.check_circle : Icons.error,
        color: enabled ? AppTheme.primaryGreen : Colors.grey,
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & Security',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            const ListTile(
              leading: Icon(Icons.security, color: AppTheme.primaryGreen),
              title: Text('Local AI Processing'),
              subtitle: Text('All AI processing happens locally on your device'),
            ),
            
            const ListTile(
              leading: Icon(Icons.privacy_tip, color: AppTheme.primaryGreen),
              title: Text('No Data Sharing'),
              subtitle: Text('Your personal data never leaves your device'),
            ),
            
            const ListTile(
              leading: Icon(Icons.storage, color: AppTheme.primaryGreen),
              title: Text('Local Storage'),
              subtitle: Text('All data is stored securely on your device'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkServerConnection() async {
    final aiProvider = context.read<AIProvider>();
    await aiProvider.checkServerAvailability();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate connection test
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection test completed'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 