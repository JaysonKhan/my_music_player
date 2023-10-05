part of 'm_player_bloc.dart';

@freezed
class MPlayerState with _$MPlayerState {
  const factory MPlayerState.uiState({
    @Default([]) List<MediaItem> list,
    @Default(ScreenPosition.LOADING) ScreenPosition screenState,
    @Default(PlayButtonEnum.LOADING) PlayButtonEnum playButtonState,
    @Default("") String title,
    @Default(RepeatEnum.OFF) RepeatEnum repeatState,
    @Default(true) bool isFirstSong,
    @Default(false) bool isLastSong,
    @Default(false) bool isShuffle,
    @Default(Duration.zero) Duration current,
    @Default(Duration.zero) Duration total,
    @Default(Duration.zero) Duration buffered,
  }) = _UiState;
}
