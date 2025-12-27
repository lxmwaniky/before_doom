// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchlistItemAdapter extends TypeAdapter<WatchlistItem> {
  @override
  final int typeId = 0;

  @override
  WatchlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistItem(
      tmdbId: fields[0] as int,
      title: fields[1] as String,
      runtime: fields[2] as int,
      posterPath: fields[3] as String?,
      overview: fields[4] as String?,
      releaseDate: fields[5] as String,
      targetMonth: fields[6] as String,
      watchPath: fields[7] as String,
      isWatched: fields[8] as bool,
      order: fields[9] as int,
      contentType: fields[10] as int,
      season: fields[11] as int?,
      episodeCount: fields[12] as int,
      episodesWatched: fields[13] as int,
      comingSoon: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistItem obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.tmdbId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.runtime)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.targetMonth)
      ..writeByte(7)
      ..write(obj.watchPath)
      ..writeByte(8)
      ..write(obj.isWatched)
      ..writeByte(9)
      ..write(obj.order)
      ..writeByte(10)
      ..write(obj.contentType)
      ..writeByte(11)
      ..write(obj.season)
      ..writeByte(12)
      ..write(obj.episodeCount)
      ..writeByte(13)
      ..write(obj.episodesWatched)
      ..writeByte(14)
      ..write(obj.comingSoon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
