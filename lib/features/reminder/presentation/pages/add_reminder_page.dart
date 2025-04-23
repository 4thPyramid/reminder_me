import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' ;  // Add this import
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Reminder Title'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No time selected'
                        : 'Time: ${DateFormat.yMd().add_jm().format(_selectedDateTime!)}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDateTime,
                  child: Text('Pick Time'),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveReminder,
              child: Text('Save Reminder'),
            ),
          ],
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
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now().replacing(minute: TimeOfDay.now().minute + 1),
    );

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _selectedDateTime = selected;
    });
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty || _selectedDateTime == null) return;

    final reminder = Reminder(
      id: Uuid().v4(),
      title: _titleController.text,
      url: widget.url,
      scheduledTime: _selectedDateTime!,
    );

    NotificationService().scheduleNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: 'Reminder for: ${reminder.url}',
      scheduledTime: reminder.scheduledTime,
      payload: reminder.id,
    );

    Navigator.pop(context);
  }
}
