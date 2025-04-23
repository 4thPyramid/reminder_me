import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<void> addReminder(Reminder reminder);
  Future<List<Reminder>> getReminders();
  Future<void> deleteReminder(String id);
}