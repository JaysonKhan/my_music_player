import 'package:audio_service/audio_service.dart';
import 'package:dartz/dartz.dart';
import 'package:my_music_player/core/errors/exeptions.dart';
import 'package:my_music_player/core/errors/failures.dart';
import 'package:my_music_player/core/usecase/usecase.dart';
import 'package:my_music_player/feature/m_player/data/datasource/locale_datasource.dart';

class UsecaseImpl extends Usecase<List<MediaItem>> {
  LocaleDataSource localeDataSource;

  UsecaseImpl({required this.localeDataSource});

  @override
  Future<Either<Failure, List<MediaItem>>> addToFavourite(
      MediaItem musicModel) async {
    try {
      await localeDataSource.addToFavourite(musicModel);
      return Future.value(Right(localeDataSource.getAllMusic()));
    } on CacheException {
      return Future.value(Left(CacheFailure()));
    }
  }

  @override
  Future<Either<Failure, List<MediaItem>>> getMusicList() async {
    try {
      return Future.value(Right(localeDataSource.getAllMusic()));
    } on EmptyException {
      return Future.value(Left(EmptyFailure()));
    }
  }

  @override
  Future<Either<Failure, List<MediaItem>>> removeFromFavourite(
      MediaItem musicModel) async {
    try {
      await localeDataSource.removeFromFavourite(musicModel);
      return Future.value(Right(localeDataSource.getAllMusic()));
    } on CacheException {
      return Future.value(Left(CacheFailure()));
    }
  }
}
