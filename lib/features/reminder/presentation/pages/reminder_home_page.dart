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

    // تحميل التذكيرات من provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false).loadReminders();

      if (widget.sharedText != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReminderPage(url: widget.sharedText!),
          ),
        );
      }
    });
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
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr, // URLs are LTR - corrected
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_linkController.text.isNotEmpty) {
                    _linksBox.add(_linkController.text);
                    _linkController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text(
                  'حفظ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تذكيري',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 4.0,
        shadowColor: Colors.black45,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF3E2723).withOpacity(0.9),
                const Color(0xFF5D4037),
              ],
            ),
          ),
          child: Column(
            children: [
              // Reminders section - هنا سيظهر التذكيرات المحفوظة
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, color: Colors.amberAccent),
                          const SizedBox(width: 8),
                          Text(
                            'التذكيرات',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.amberAccent,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return provider.reminders.isEmpty
                              ? Center(
                                child: Text(
                                  'لا توجد تذكيرات',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: provider.reminders.length,
                                itemBuilder: (context, index) {
                                  final reminder = provider.reminders[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    color: const Color(0xFF4E342E),
                                    elevation: 3,
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.amber,
                                        child: Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        reminder.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reminder.url,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'وقت التذكير: ${_formatDateTime(reminder.scheduledTime)}',
                                            style: TextStyle(
                                              color: Colors.amber[100],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          await NotificationService()
                                              .cancelNotification(
                                                reminder.id.hashCode,
                                              );
                                          await provider.deleteReminder(
                                            reminder.id,
                                          );
                                        },
                                      ),
                                      isThreeLine: true,
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
              // Links section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1C17),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, -3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: Colors.amberAccent),
                        const SizedBox(width: 8),
                        Text(
                          'الروابط',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _linksBox.listenable(),
                        builder: (context, Box<String> box, _) {
                          return box.isEmpty
                              ? Center(
                                child: Text(
                                  'لا توجد روابط',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: box.length,
                                itemBuilder: (context, index) {
                                  final link = box.getAt(index) ?? '';
                                  return Card(
                                    color: const Color(0xFF3E2723),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        link,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.alarm_add,
                                              color: Colors.amber,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          AddReminderPage(
                                                            url: link,
                                                          ),
                                                ),
                                              ).then((_) {
                                                // Reload reminders when returning from AddReminderPage
                                                Provider.of<ReminderProvider>(
                                                  context,
                                                  listen: false,
                                                ).loadReminders();
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              box.deleteAt(index);
                                            },
                                          ),
                                        ],
                                      ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLink,
        icon: const Icon(Icons.add_link),
        label: const Text('إضافة رابط'),
        backgroundColor: Colors.amber,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Simple formatting - can be enhanced with intl package
    return '${dateTime.day}/${dateTime.month}/ ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}
