part of 'm_player_bloc.dart';

@freezed
class MPlayerEvent with _$MPlayerEvent {
  const factory MPlayerEvent.started() = _Started;
  const factory MPlayerEvent.next() = _Next;
  const factory MPlayerEvent.play() = _Play;
  const factory MPlayerEvent.pause() = _Pause;
  const factory MPlayerEvent.prev() = _Prev;
  const factory MPlayerEvent.playMusic(MediaItem music) = _PlayMusic;
  const factory MPlayerEvent.addMusic() = _AddMusic;
  const factory MPlayerEvent.removeMusic(int index) = _RemoveMusic;
  const factory MPlayerEvent.dispose() = _Dispose;
  const factory MPlayerEvent.seek(Duration currentDuration) = _Seek;
  //TODO
  const factory MPlayerEvent.changeRepeatMode() = _ChangeRepeatMode;
  const factory MPlayerEvent.changeShuffleMode() = _ChangeShuffleMode;
  const factory MPlayerEvent.nextStateRepeat() = _NextStateRepeat;


  //UNTIL
  const factory MPlayerEvent.changeCurrentPosStream(Duration currentDuration) = _ChangeCurrentPositionStream;
  const factory MPlayerEvent.changeBufferedPosStream(Duration bufferedDuration) = _ChangeBufferedPositionStream;
  const factory MPlayerEvent.changeTotalPosStream(Duration totalDuration) = _ChangeTotalPositionStream;

  const factory MPlayerEvent.changeTitleStream(String title) = _ChangeTitlePositionStream;
  const factory MPlayerEvent.changeListStream(List<MediaItem> list) = _ChangeListPositionStream;
  const factory MPlayerEvent.changePlayButtonStream(PlayButtonEnum playState) = _ChangePlayButtonStream;
  const factory MPlayerEvent.updateStream() = _UpdateStream;
}
