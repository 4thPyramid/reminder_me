import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'features/reminder/presentation/pages/reminder_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _sharedText;

  @override
  void initState() {
    super.initState();
    
    // Handling media sharing
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> mediaFiles) {
      if (mediaFiles.isNotEmpty) {
        setState(() {
          _sharedText = mediaFiles[0].path;  // Example: Get media path, adjust as needed
        });
      }
    });

    // Listening for stream of media files (if you want continuous updates)
    ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> mediaFiles) {
      if (mediaFiles.isNotEmpty) {
        setState(() {
          _sharedText = mediaFiles[0].path;  // Example: Get media path
        });
      }
    }, onError: (err) {
      print("Error receiving media: $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Reminder',
      home: ReminderHomePage(sharedText: _sharedText),
    );
  }
}

 


