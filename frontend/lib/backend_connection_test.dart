import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

import 'services/api_config.dart';

class BackendConnectionTest extends StatefulWidget {
  const BackendConnectionTest({super.key});

  @override
  State<BackendConnectionTest> createState() => _BackendConnectionTestState();
}

class _BackendConnectionTestState extends State<BackendConnectionTest> {
  String status = 'Not tested';
  bool isConnected = false;
  bool isLoading = false;

  Future<void> checkConnection() async {
    setState(() {
      isLoading = true;
      status = 'Checking connection...';
      isConnected = false;
    });

    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          data is Map &&
          data['success'] == true) {
        setState(() {
          isConnected = true;
          status = 'Backend and Database Connected!';
        });
      } else {
        setState(() {
          status =
              'Backend returned an error: '
              '${response.statusCode}';
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isConnected = false;
        status = 'Connection failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.cloud_off,
          size: 42,
          color: isConnected ? Colors.green : Colors.red,
        ),

        const SizedBox(height: 12),

        Text(status, textAlign: TextAlign.center),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: isLoading ? null : checkConnection,
          child: Text(isLoading ? 'Checking...' : 'Test Backend Connection'),
        ),
      ],
    );
  }
}
