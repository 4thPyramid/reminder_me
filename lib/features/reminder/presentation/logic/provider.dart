import 'package:flutter/material.dart';
import 'package:reminder_me/features/reminder/domain/entities/reminder.dart';
import 'package:reminder_me/features/reminder/domain/repositories/reminder_repository.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderRepository _repository;
  List<Reminder> _reminders = [];

  ReminderProvider(this._repository) {
    loadReminders();
  }

  List<Reminder> get reminders => _reminders;

  Future<void> loadReminders() async {
    _reminders = await _repository.getReminders();
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _repository.addReminder(reminder);
    await loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _repository.deleteReminder(id);
    await loadReminders();
  }
}
