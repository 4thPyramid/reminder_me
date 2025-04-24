import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:reminder_me/features/reminder/domain/entities/reminder.dart'
    show Reminder;
import 'package:reminder_me/features/reminder/domain/repositories/reminder_repository.dart'
    show ReminderRepository;

class ReminderProvider with ChangeNotifier {
  final ReminderRepository _repository;
  List<Reminder> _reminders = [];

  ReminderProvider(this._repository) {
    _loadReminders();
  }

  List<Reminder> get reminders => _reminders;

  Future<void> _loadReminders() async {
    _reminders = await _repository.getReminders();
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _repository.addReminder(reminder);
    _reminders = await _repository.getReminders();
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    await _repository.deleteReminder(id);
    _reminders = await _repository.getReminders();
    notifyListeners();
  }
}
