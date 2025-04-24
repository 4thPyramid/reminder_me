import 'package:hive/hive.dart' show Box;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<void> saveReminder(ReminderModel reminder);
  Future<List<ReminderModel>> getAllReminders();
  Future<void> deleteReminder(String id);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final Box<ReminderModel> _reminderBox;

  ReminderLocalDataSourceImpl()
    : _reminderBox = Hive.box<ReminderModel>('remindersBox');

  @override
  Future<void> saveReminder(ReminderModel reminder) async {
    await _reminderBox.put(reminder.id, reminder);
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    return _reminderBox.values.toList();
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _reminderBox.delete(id);
  }
}
