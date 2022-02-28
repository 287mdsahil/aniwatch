import 'package:aniwatch/models/animeEpisodeWatchHistory.dart';
import 'package:aniwatch/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AnimeEpisodeWatchHistoryAdapter());
  await Hive.openBox<AnimeEpisodeWatchHistory>("AnimeEpisodeWatchHistory");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search page',
      home: SearchPage()
    );
  }
}
