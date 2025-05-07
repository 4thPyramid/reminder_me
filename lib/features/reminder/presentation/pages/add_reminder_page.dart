import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder.dart';
import '../logic/provider.dart'; // Import the provider

class AddReminderPage extends StatefulWidget {
  final String url;

  const AddReminderPage({super.key, required this.url});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Use URL domain as initial title suggestion
    try {
      final uri = Uri.parse(widget.url);
      _titleController.text = 'تذكير ${uri.host}';
    } catch (e) {
      _titleController.text = 'تذكير جديد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة تذكير')),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0xFF4E342E),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الرابط:',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.url,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'عنوان التذكير',
                  labelStyle: TextStyle(color: Colors.amberAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.amberAccent,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Color(0xFF4E342E),
                  prefixIcon: Icon(Icons.title, color: Colors.amber),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFF4E342E),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.amber),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? 'لم يتم اختيار الوقت'
                              : 'الوقت: ${_formatDateTime(_selectedDateTime!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('اختر الوقت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'حفظ التذكير',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: const Color(0xFF3E2723),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF3E2723),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now().replacing(
        minute: TimeOfDay.now().minute + 1,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: const Color(0xFF3E2723),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF3E2723),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _selectedDateTime = selected;
    });
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty || _selectedDateTime == null) {
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('خطأ'),
              content: const Text(
                'يرجى إدخال عنوان التذكير واختيار وقت للتذكير',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حسنًا'),
                ),
              ],
            ),
      );
      return;
    }

    final reminder = Reminder(
      id: const Uuid().v4(),
      title: _titleController.text,
      url: widget.url,
      scheduledTime: _selectedDateTime!,
    );

    // Schedule the notification
    NotificationService().scheduleNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: 'تذكير للرابط: ${reminder.url}',
      scheduledTime: reminder.scheduledTime,
      payload: reminder.id,
    );

    // Save the reminder using the provider
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    provider.addReminder(reminder).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ التذكير بنجاح',

            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to home page
      Navigator.pop(context);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    // Format date and time in Arabic-friendly format
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
