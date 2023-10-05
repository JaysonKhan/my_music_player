import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:my_music_player/core/utils/my_audio_handler.dart';
import 'package:my_music_player/feature/m_player/data/datasource/locale_datasource.dart';
import 'package:my_music_player/feature/m_player/data/repository/demo_playlist_repository_impl.dart';
import 'package:my_music_player/feature/m_player/domain/usecase/UsecaseImpl.dart';
import 'package:my_music_player/feature/m_player/presentation/blocs/home/m_player_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> init() async {
  final sharedPref = await SharedPreferences.getInstance();
  di.registerLazySingleton<SharedPreferences>(() => sharedPref);

  di.registerLazySingleton(
      () => MPlayerBloc(audioHandler: di.call(), usecase: di.call()));

  di.registerSingleton<AudioHandler>(await initAudioService());

  di.registerLazySingleton<LocaleDataSource>(() => LocaleDataSourceImpl(
        audioHandler: di.call(),
        sharedPreference: di.call(),
      )..init());
  di.registerLazySingleton<DemoPlaylist>(() => DemoPlaylist());
  di.registerLazySingleton(() => UsecaseImpl(localeDataSource: di.call()));
}
