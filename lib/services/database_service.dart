import 'package:hive/hive.dart';
import '../models/animeEpisodeWatchHistory.dart';

class Boxes {
  static Box<AnimeEpisodeWatchHistory> getAnimeEpisodeWatchHistoryBox() =>
    Hive.box<AnimeEpisodeWatchHistory>('AnimeEpisodeWatchHistory');

  static void saveAnimeEpisodeWatchHistory(String id, int lastWatched) {
    final watchHistory = AnimeEpisodeWatchHistory(lastWatched: lastWatched);

    final box = Boxes.getAnimeEpisodeWatchHistoryBox();
    box.put(id, watchHistory);
  }
}
