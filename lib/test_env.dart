import 'package:flutter/material.dart';
import 'core/utils/env_loader.dart';

class TestEnvScreen extends StatefulWidget {
  const TestEnvScreen({super.key});

  @override
  State<TestEnvScreen> createState() => _TestEnvScreenState();
}

class _TestEnvScreenState extends State<TestEnvScreen> {
  String _status = 'Testing...';
  Map<String, String> _envInfo = {};

  @override
  void initState() {
    super.initState();
    _testEnv();
  }

  Future<void> _testEnv() async {
    try {
      // Try to load .env
      await EnvLoader.load();
      
      // Get values
      final geminiKey = EnvLoader.geminiApiKey;
      final groqKey = EnvLoader.groqApiKey;
      final geminiBase = EnvLoader.geminiBaseUrl;
      final groqBase = EnvLoader.groqBaseUrl;
      final environment = EnvLoader.environment;
      
      setState(() {
        _status = '✅ .env file loaded successfully!';
        _envInfo = {
          'GEMINI_API_KEY': '${geminiKey.substring(0, 10)}...${geminiKey.substring(geminiKey.length - 5)}',
          'GROQ_API_KEY': '${groqKey.substring(0, 10)}...${groqKey.substring(groqKey.length - 5)}',
          'GEMINI_BASE_URL': geminiBase,
          'GROQ_BASE_URL': groqBase,
          'ENVIRONMENT': environment,
        };
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load .env file: $e';
        _envInfo = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('.env File Test'),
        backgroundColor: _status.contains('✅') ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('✅') ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status.contains('✅') ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.contains('✅') ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Current Configuration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._envInfo.entries.map((entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.key),
                title: Text(entry.key),
                subtitle: Text(entry.value),
              ),
            )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Troubleshooting Tips:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Ensure .env file is in the project root (same folder as pubspec.yaml)'),
                  const Text('2. Check for spaces around the = sign'),
                  const Text('3. No quotes around values'),
                  const Text('4. No trailing spaces'),
                  const Text('5. Restart the app completely after changes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}