import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reminder_me/features/reminder/presentation/logic/provider.dart'
    show ReminderProvider;
import '../../../../core/services/notification_service.dart';
import 'add_reminder_page.dart';

class ReminderHomePage extends StatefulWidget {
  final String? sharedText;

  const ReminderHomePage({Key? key, this.sharedText}) : super(key: key);

  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  final TextEditingController _linkController = TextEditingController();
  late Box<String> _linksBox;

  @override
  void initState() {
    super.initState();
    _linksBox = Hive.box<String>('linksBox');

    // If there's a shared link, navigate to AddReminderPage
    if (widget.sharedText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReminderPage(url: widget.sharedText!),
          ),
        );
      });
    }
  }

  void _addLink() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة رابط', textDirection: TextDirection.rtl),
            content: TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                hintText: 'أدخل الرابط (مثال: https://example.com)',
                hintTextDirection: TextDirection.rtl,
              ),
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr, // URLs are LTR
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', textDirection: TextDirection.rtl),
              ),
              TextButton(
                onPressed: () {
                  if (_linkController.text.isNotEmpty) {
                    _linksBox.add(_linkController.text);
                    _linkController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ', textDirection: TextDirection.rtl),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكيري', textDirection: TextDirection.rtl),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Reminders section
            Expanded(
              child: Consumer<ReminderProvider>(
                builder: (context, provider, _) {
                  return provider.reminders.isEmpty
                      ? const Center(child: Text('لا توجد تذكيرات'))
                      : ListView.builder(
                        itemCount: provider.reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = provider.reminders[index];
                          return ListTile(
                            title: Text(reminder.title),
                            subtitle: Text(
                              reminder.url,
                              style: const TextStyle(color: Colors.blue),
                              textDirection: TextDirection.ltr,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await NotificationService().cancelNotification(
                                  reminder.id.hashCode,
                                );
                                await provider.deleteReminder(reminder.id);
                              },
                            ),
                          );
                        },
                      );
                },
              ),
            ),
            // Links section
            Container(
              height: 200,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الروابط',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _linksBox.listenable(),
                      builder: (context, Box<String> box, _) {
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final link = box.getAt(index) ?? '';
                            return ListTile(
                              title: Text(
                                link,
                                style: const TextStyle(color: Colors.blue),
                                textDirection: TextDirection.ltr,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.alarm_add),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AddReminderPage(url: link),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLink,
        child: const Icon(Icons.add_link),
        tooltip: 'إضافة رابط',
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}
