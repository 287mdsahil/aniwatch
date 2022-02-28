// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animeEpisodeWatchHistory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeEpisodeWatchHistoryAdapter
    extends TypeAdapter<AnimeEpisodeWatchHistory> {
  @override
  final int typeId = 0;

  @override
  AnimeEpisodeWatchHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeEpisodeWatchHistory(
      lastWatched: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AnimeEpisodeWatchHistory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.lastWatched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeEpisodeWatchHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
