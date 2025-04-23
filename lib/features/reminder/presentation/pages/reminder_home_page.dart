import 'package:flutter/material.dart';
import 'add_reminder_page.dart';

class ReminderHomePage extends StatelessWidget {
  final String? sharedText;

  const ReminderHomePage({Key? key, this.sharedText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Link Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sharedText != null) ...[
              Text(
                'Shared Link:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(sharedText!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddReminderPage(url: sharedText!),
                  ));
                },
                child: Text('Add Reminder'),
              ),
            ] else ...[
              Center(child: Text('No shared link received.')),
            ],
          ],
        ),
      ),
    );
  }
}
