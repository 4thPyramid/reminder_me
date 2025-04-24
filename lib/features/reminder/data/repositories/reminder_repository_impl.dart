import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_data_source.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl(this.localDataSource);

  @override
  Future<void> addReminder(Reminder reminder) async {
    final model = ReminderModel(
      id: reminder.id,
      url: reminder.url,
      title: reminder.title,
      scheduledTime: reminder.scheduledTime,
    );
    await localDataSource.saveReminder(model);
  }

  @override
  Future<List<Reminder>> getReminders() async {
    return await localDataSource.getAllReminders().then((reminders) {
      return reminders.map((model) {
        return Reminder(
          id: model.id,
          url: model.url,
          title: model.title,
          scheduledTime: model.scheduledTime,
        );
      }).toList();
    });
  }

  @override
  Future<void> deleteReminder(String id) async {
    await localDataSource.deleteReminder(id);
  }
}
