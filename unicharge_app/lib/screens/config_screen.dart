import 'package:flutter/material.dart';
import '../constants/appwrite_config.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _endpointController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _databaseIdController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    _endpointController.text = AppwriteConfig.endpoint;
    _projectIdController.text = AppwriteConfig.projectId;
    _databaseIdController.text = AppwriteConfig.databaseId;
    _apiKeyController.text = AppwriteConfig.apiKey;
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _projectIdController.dispose();
    _databaseIdController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentConfig,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigStatus(),
            const SizedBox(height: 24),
            _buildConfigForm(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigStatus() {
    final isConfigured = AppwriteConfig.isConfigured;
    
    return Card(
      color: isConfigured ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConfigured ? Icons.check_circle : Icons.warning,
              color: isConfigured ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConfigured ? 'Configuration Valid' : 'Configuration Required',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isConfigured ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConfigured 
                        ? 'Appwrite is properly configured and ready to use.'
                        : 'Please configure your Appwrite settings below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appwrite Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'Appwrite Endpoint',
                hintText: 'https://cloud.appwrite.io/v1',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _projectIdController,
              decoration: const InputDecoration(
                labelText: 'Project ID',
                hintText: 'your-project-id',
                prefixIcon: Icon(Icons.fingerprint),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _databaseIdController,
              decoration: const InputDecoration(
                labelText: 'Database ID',
                hintText: 'parkcharge_db',
                prefixIcon: Icon(Icons.storage),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'your-api-key',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _testConnection,
            child: const Text('Test Connection'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveConfig,
            child: const Text('Save Configuration'),
          ),
        ),
      ],
    );
  }

  void _testConnection() {
    // This would test the connection in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection test not implemented in demo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveConfig() {
    // In a real implementation, this would save to persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved (demo mode)'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
