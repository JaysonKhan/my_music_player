import 'package:audio_service/audio_service.dart';
import 'package:dartz/dartz.dart';
import 'package:my_music_player/core/errors/failures.dart';

abstract class Usecase<Type> {
  Future<Either<Failure, Type>> getMusicList();
  Future<Either<Failure, Type>> addToFavourite(MediaItem musicModel);
  Future<Either<Failure, Type>> removeFromFavourite(MediaItem musicModel);
}
