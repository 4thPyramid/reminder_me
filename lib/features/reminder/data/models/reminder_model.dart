import 'package:hive/hive.dart';
part 'reminder_model.g.dart';

@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime scheduledTime;

  ReminderModel({
    required this.id,
    required this.url,
    required this.title,
    required this.scheduledTime,
  });
}
