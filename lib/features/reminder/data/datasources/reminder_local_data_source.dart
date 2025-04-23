import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<void> saveReminder(ReminderModel reminder);
  Future<List<ReminderModel>> getAllReminders();
  Future<void> deleteReminder(String id);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final List<ReminderModel> _storage = [];

  @override
  Future<void> saveReminder(ReminderModel reminder) async {
    _storage.add(reminder);
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    return _storage;
  }

  @override
  Future<void> deleteReminder(String id) async {
    _storage.removeWhere((r) => r.id == id);
  }
}