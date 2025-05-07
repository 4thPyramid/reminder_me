import 'package:flutter/material.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart'
    show ReceiveSharingIntent;
import 'package:reminder_me/core/services/notification_service.dart';
import 'package:reminder_me/features/reminder/data/datasources/reminder_local_data_source.dart';
import 'package:reminder_me/features/reminder/data/models/reminder_model.dart';
import 'package:reminder_me/features/reminder/data/repositories/reminder_repository_impl.dart'
    show ReminderRepositoryImpl;
import 'package:reminder_me/features/reminder/presentation/logic/provider.dart';
import 'package:reminder_me/features/reminder/presentation/pages/reminder_home_page.dart'
    show ReminderHomePage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the notification service
  await NotificationService().init();
  // Initialize the ReceiveSharingIntent

  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  await Hive.openBox<ReminderModel>('remindersBox');
  await Hive.openBox<String>('linksBox');

  final reminderRepository = ReminderRepositoryImpl(
    ReminderLocalDataSourceImpl(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(reminderRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _sharedText;

  @override
  void initState() {
    super.initState();

    // Handle initial shared text
    ReceiveSharingIntent.instance.getInitialMedia().then((mediaFiles) {
      if (mediaFiles.isNotEmpty) {
        setState(() {
          _sharedText = mediaFiles[0].message;
        });
      }
    });

    // Handle shared text stream
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (mediaFiles) {
        if (mediaFiles.isNotEmpty) {
          setState(() {
            _sharedText = mediaFiles[0].message;
          });
        }
      },
      onError: (err) {
        print("Error receiving media: $err");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Link Reminder',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF3E2723), // Dark brown
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E342E), // Lighter brown
          foregroundColor: Colors.white, // White text/icons
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black26,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber, // Accent color
          foregroundColor: Colors.white,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFF3E2723),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: ReminderHomePage(sharedText: _sharedText),
      ),
    );
  }
}
