import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  ReminderModel({
    required super.id,
    required super.url,
    required super.title,
    required super.scheduledTime,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'],
        url: json['url'],
        title: json['title'],
        scheduledTime: DateTime.parse(json['scheduledTime']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'scheduledTime': scheduledTime.toIso8601String(),
      };
}