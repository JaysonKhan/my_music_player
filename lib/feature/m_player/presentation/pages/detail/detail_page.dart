import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:my_music_player/core/utils/enums/play_button_enum.dart';
import 'package:my_music_player/core/utils/enums/play_button_enum.dart';
import 'package:my_music_player/core/utils/enums/play_button_enum.dart';
import 'package:my_music_player/core/utils/enums/repeat_enum.dart';
import 'package:my_music_player/core/utils/enums/repeat_enum.dart';
import 'package:my_music_player/core/utils/enums/repeat_enum.dart';
import 'package:my_music_player/feature/m_player/presentation/blocs/home/m_player_bloc.dart';
import 'package:my_music_player/injection_container.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

final bloc = di<MPlayerBloc>();

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<MPlayerBloc, MPlayerState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF00041F),
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Color(0xFFE7A1FF),
              ),
              backgroundColor: const Color(0xFF7569FF),
              foregroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/images/music.png",
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: 56,
                    child: Marquee(
                      text: "  ${state.title}  ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Orbitation",
                        fontSize: 32,
                        color: Colors.white
                      ),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ProgressBar(
                      progress: state.current,
                      buffered: state.buffered,
                      total: state.total,
                      onSeek: (value) => bloc.add(MPlayerEvent.seek(value)),
                      thumbColor: const Color(0xFF7569FF),
                      timeLabelTextStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Builder(
                        builder: (BuildContext context) {
                          Icon icon;
                          switch (state.repeatState) {
                            case RepeatEnum.OFF:
                              icon =
                                  const Icon(Icons.repeat, color: Colors.grey);
                              break;
                            case RepeatEnum.REPEAT_ONE:
                              icon = const Icon(Icons.repeat_one, color: Colors.white);
                              break;
                            case RepeatEnum.REPEAT_PLAYLIST:
                              icon = const Icon(Icons.repeat, color: Colors.white);
                              break;
                          }
                          return IconButton(
                            icon: icon,
                            onPressed: () =>
                                bloc.add(const MPlayerEvent.changeRepeatMode()),
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          if (state.isFirstSong) {
                            return IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous_outlined,
                                    color: Colors.grey));
                          } else {
                            return IconButton(
                                onPressed: () =>
                                    bloc.add(const MPlayerEvent.prev()),
                                icon: const Icon(Icons.skip_previous_outlined, color: Colors.white,));
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          switch (state.playButtonState) {
                            case PlayButtonEnum.LOADING:
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                width: 16.0,
                                height: 16.0,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            case PlayButtonEnum.PAUSED:
                              return IconButton(
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                iconSize: 32.0,
                                onPressed: () =>
                                    bloc.add(const MPlayerEvent.play()),
                              );
                            case PlayButtonEnum.PLAYING:
                              return IconButton(
                                icon: const Icon(Icons.pause, color: Colors.white),
                                iconSize: 32.0,
                                onPressed: () =>
                                    bloc.add(const MPlayerEvent.pause()),
                              );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          if (state.isLastSong) {
                            return IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_next_outlined,
                                    color: Colors.grey));
                          } else {
                            return IconButton(
                                onPressed: () =>
                                    bloc.add(const MPlayerEvent.next()),
                                icon: const Icon(Icons.skip_next_outlined, color: Colors.white));
                          }
                        },
                      ),
                      IconButton(
                        icon: (state.isShuffle)
                            ? const Icon(Icons.shuffle, color: Colors.white,)
                            : const Icon(Icons.shuffle, color: Colors.grey),
                        onPressed: () => bloc.add(
                          const MPlayerEvent.changeShuffleMode(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
