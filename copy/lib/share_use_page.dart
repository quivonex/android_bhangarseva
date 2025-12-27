// screens/share_us_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ShareUsScreen extends StatefulWidget {
  @override
  _ShareUsScreenState createState() => _ShareUsScreenState();
}

class _ShareUsScreenState extends State<ShareUsScreen> {
  String apiStatus = '';
  String apiMessage = '';
  Map<String, dynamic>? apiData;

  // Call API service
  Future<void> handleCreateShare() async {
    final response = await ApiService.createShareContent();

    setState(() {
      apiStatus = response['status'] ?? '';
      apiMessage = response['message'] ?? '';
      apiData = response['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Us'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: handleCreateShare,
              child: Text('Create Share Content'),
            ),
            SizedBox(height: 20),
            Text(
              'Status: $apiStatus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Message: $apiMessage'),
            SizedBox(height: 20),
            if (apiData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${apiData!['id']}'),
                  Text('Title: ${apiData!['title']}'),
                  Text('Message: ${apiData!['message']}'),
                  Text('Link: ${apiData!['link']}'),
                  Text('Created At: ${apiData!['created_at']}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
