import 'package:audio_service/audio_service.dart';
import 'package:my_music_player/feature/m_player/data/repository/demo_playlist_repository_impl.dart';
import 'package:my_music_player/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const SHARED_PREF_KEY = "FAVOURITE_MUSICS";

abstract class LocaleDataSource {
  List<MediaItem> getAllMusic();

  Future<void> addToFavourite(MediaItem music);

  Future<void> removeFromFavourite(MediaItem music);
}

class LocaleDataSourceImpl extends LocaleDataSource {
  final AudioHandler audioHandler;
  final SharedPreferences sharedPreference;

  LocaleDataSourceImpl(
      {required this.audioHandler, required this.sharedPreference});

  void init() async {
    await _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final songRepository = di<DemoPlaylist>();
    final playlist = await songRepository.fetchInitialPlaylist();
    final mediaItems = playlist
        .map((song) => MediaItem(
              id: song['id'] ?? '',
              album: song['album'] ?? '',
              title: song['title'] ?? '',
              extras: {'url': song['url']},
            ))
        .toList();
    audioHandler.addQueueItems(mediaItems);
  }

  @override
  Future<void> addToFavourite(MediaItem music) async {
    await sharedPreference.setBool(music.id, true);
  }

  @override
  List<MediaItem> getAllMusic() {
    return audioHandler.queue.value;
  }

  @override
  Future<void> removeFromFavourite(MediaItem music) async {
    await sharedPreference.setBool(music.id, false);
  }
}
