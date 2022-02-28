import 'package:hive/hive.dart';

part 'animeEpisodeWatchHistory.g.dart';

@HiveType(typeId: 0)
class AnimeEpisodeWatchHistory extends HiveObject {
  AnimeEpisodeWatchHistory({this.lastWatched = 0});

  @HiveField(0)
  int lastWatched;
}
