import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class AddReminder {
  final ReminderRepository repository;

  AddReminder(this.repository);

  Future<void> call(Reminder reminder) async {
    await repository.addReminder(reminder);
  }
}