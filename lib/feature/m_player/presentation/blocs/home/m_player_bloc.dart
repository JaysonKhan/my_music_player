import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_music_player/core/utils/enums/play_button_enum.dart';
import 'package:my_music_player/core/utils/enums/repeat_enum.dart';
import 'package:my_music_player/core/utils/enums/screen_position_enum.dart';
import 'package:my_music_player/core/utils/my_colored_log.dart';
import 'package:my_music_player/feature/m_player/data/repository/demo_playlist_repository_impl.dart';
import 'package:my_music_player/feature/m_player/domain/usecase/UsecaseImpl.dart';
import 'package:my_music_player/feature/m_player/presentation/pages/detail/detail_page.dart';
import 'package:my_music_player/injection_container.dart';

part 'm_player_event.dart';

part 'm_player_state.dart';

part 'm_player_bloc.freezed.dart';

class MPlayerBloc extends Bloc<MPlayerEvent, MPlayerState> {
  UsecaseImpl usecase;
  AudioHandler audioHandler;
  late StreamSubscription<Duration> currentDurationStream;
  late StreamSubscription<MediaItem?> mediaStream;

  late StreamSubscription<PlaybackState> playbackStream;
  late StreamSubscription<List<MediaItem>> playListStream;

  MPlayerBloc({required this.audioHandler, required this.usecase})
      : super(const MPlayerState.uiState()) {
    currentDurationStream = AudioService.position.listen((position) {
      add(MPlayerEvent.changeCurrentPosStream(position));
    });

    mediaStream = audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        add(MPlayerEvent.changeTotalPosStream(
            mediaItem.duration ?? Duration.zero));
        add(MPlayerEvent.changeTitleStream(mediaItem.title));
        add(const MPlayerEvent.updateStream());
      }
    });

    playbackStream = audioHandler.playbackState.listen((playbackState) async {
      add(MPlayerEvent.changeBufferedPosStream(playbackState.bufferedPosition));
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        add(const MPlayerEvent.changePlayButtonStream(PlayButtonEnum.LOADING));
      } else if (!isPlaying) {
        add(const MPlayerEvent.changePlayButtonStream(PlayButtonEnum.PAUSED));
      } else if (processingState != AudioProcessingState.completed) {
        add(const MPlayerEvent.changePlayButtonStream(PlayButtonEnum.PLAYING));
      } else {
        await audioHandler.seek(Duration.zero);
        await audioHandler.pause();
        add(const MPlayerEvent.changeCurrentPosStream(Duration.zero));
        add(const MPlayerEvent.changePlayButtonStream(PlayButtonEnum.PAUSED));
      }
    });

    playListStream = audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        add(const MPlayerEvent.changeListStream([]));
        add(const MPlayerEvent.changeTitleStream(""));
      } else {
        add(MPlayerEvent.changeListStream(playlist));
      }
      add(const MPlayerEvent.updateStream());
    });

    on<_Started>((event, emit) async {
      final either = await usecase.getMusicList();
      either.fold((l) {
        emit(state.copyWith(screenState: ScreenPosition.EMPTY));
      }, (list) {
        emit(state.copyWith(list: list, screenState: ScreenPosition.SUCCESS));
      });
    });
    on<_Next>((event, emit) async {
      await audioHandler.skipToNext();
    });

    on<_Play>((event, emit) async {
      await audioHandler.play();
    });

    on<_Prev>((event, emit) async {
      await audioHandler.skipToPrevious();
    });

    on<_PlayMusic>((event, emit) async {
      myLogColored("_PlayMusic", "URL: ${event.music.extras}", false);
      try {
        await audioHandler
            .playMediaItem(event.music)
            .onError((error, stackTrace) {
          myLogColored("_PlayMusic", "$error", true);
        });
      } catch (e) {
        myLogColored("_PlayMusic", "$e", true);
      }
    });

    on<_Pause>((event, emit) async {
      await audioHandler.pause();
    });

    on<_AddMusic>((event, emit) async {
      final songRepository = di<DemoPlaylist>();
      final song = await songRepository.fetchAnotherSong();
      final mediaItem = MediaItem(
        id: song['id'] ?? '',
        album: song['album'] ?? '',
        title: song['title'] ?? '',
        extras: {'url': song['url']},
      );
      await audioHandler.addQueueItem(mediaItem);
    });

    on<_RemoveMusic>((event, emit) async {
      if (event.index < 0) return;
      await audioHandler.removeQueueItemAt(event.index);
    });

    on<_Dispose>((event, emit) async {
      await audioHandler.customAction('dispose');
    });

    on<_UpdateStream>((event, emit) {
      final mediaItem = audioHandler.mediaItem.value;
      final playlist = audioHandler.queue.value;
      if (playlist.length < 2 || mediaItem == null) {
        emit(state.copyWith(isFirstSong: true, isLastSong: true));
      } else {
        emit(state.copyWith(
          isFirstSong: playlist.first == mediaItem,
          isLastSong: playlist.last == mediaItem,
        ));
      }
    });

    on<_ChangeCurrentPositionStream>((event, emit) {
      emit(state.copyWith(
        current: event.currentDuration,
      ));
    });

    on<_ChangeBufferedPositionStream>((event, emit) {
      emit(state.copyWith(
        buffered: event.bufferedDuration,
      ));
    });

    on<_ChangeTotalPositionStream>((event, emit) {
      emit(state.copyWith(
        total: event.totalDuration,
      ));
    });

    on<_ChangeTitlePositionStream>((event, emit) {
      emit(state.copyWith(title: event.title));
    });

    on<_ChangeListPositionStream>((event, emit) {
      emit(state.copyWith(list: event.list));
    });

    on<_ChangePlayButtonStream>((event, emit) {
      emit(state.copyWith(playButtonState: event.playState));
    });

    on<_Seek>((event, emit) {
      audioHandler.seek(event.currentDuration);
    });
    on<_ChangeRepeatMode>((event, emit) {
      bloc.add(const MPlayerEvent.nextStateRepeat());
      switch (state.repeatState) {
        case RepeatEnum.OFF:
          audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          break;
        case RepeatEnum.REPEAT_ONE:
          audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
          break;
        case RepeatEnum.REPEAT_PLAYLIST:
          audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
          break;
      }
    });
    on<_NextStateRepeat>((event, emit) {
      final next = (state.repeatState.index + 1) % RepeatEnum.values.length;
      emit(state.copyWith(repeatState: RepeatEnum.values[next]));
    });

    on<_ChangeShuffleMode>((event, emit) {
      final enable = !state.isShuffle;
      emit(state.copyWith(isShuffle: enable));
      if (enable) {
        audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
      } else {
        audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
      }
    });
  }
}
