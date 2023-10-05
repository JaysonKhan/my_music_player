import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_music_player/core/utils/enums/play_button_enum.dart';
import 'package:my_music_player/core/utils/enums/screen_position_enum.dart';
import 'package:my_music_player/feature/m_player/presentation/blocs/home/m_player_bloc.dart';
import 'package:my_music_player/feature/m_player/presentation/pages/detail/detail_page.dart';
import 'package:my_music_player/injection_container.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bloc = di<MPlayerBloc>();

  Future<void> _refresh() async {
    bloc.add(const MPlayerEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<MPlayerBloc, MPlayerState>(
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            endDrawerEnableOpenDragGesture: false,
            extendBody: true,
            backgroundColor: const Color(0xFF00041F),
            appBar: AppBar(
              title: const Text(
                "Music Player...",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Orbitation",
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                GestureDetector(
                  child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      )),
                  onTap: () {
                    bloc.add(const MPlayerEvent.addMusic());
                  },
                )
              ],
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
            body: Builder(builder: (context) {
              if (state.screenState == ScreenPosition.LOADING) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.screenState == ScreenPosition.EMPTY) {
                return const Center(
                    child: Text(
                  "Empty List or Musics not found...",
                  style:
                      TextStyle(fontFamily: "Orbitation", color: Colors.white),
                ));
              } else if (state.screenState == ScreenPosition.ERROR) {
                return const Center(
                    child: Text(
                  "Error!!!",
                  style:
                      TextStyle(fontFamily: "Orbitation", color: Colors.white),
                ));
              }
              return LiquidPullToRefresh(
                color: const Color(0xFF7569FF),
                height: 300,
                backgroundColor: const Color(0xFFD869FF),
                onRefresh: _refresh,
                animSpeedFactor: 3,
                child: ListView(
                  children: state.list
                      .map(
                        (musicItem) => Dismissible(
                          key: Key(musicItem.id),
                          onDismissed: (direction) {
                            bloc.add(MPlayerEvent.removeMusic(
                                state.list.indexOf(musicItem)));
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Row(
                              children: [
                                SizedBox(width: 16),
                                Icon(Icons.delete),
                                Spacer(),
                                Icon(Icons.delete),
                                SizedBox(width: 16)
                              ],
                            ),
                          ),
                          child: ListTile(
                            leading: Image.asset("assets/images/music.png",
                                width: 56, height: 56, fit: BoxFit.fill),
                            title: Text(
                              musicItem.title,
                              style: const TextStyle(
                                  fontFamily: "Orbitation",
                                  color: Colors.white),
                            ),
                            onTap: () {
                              bloc.add(MPlayerEvent.playMusic(musicItem));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DetailPage(),
                                  ));
                            },
                            subtitle: Text(
                              musicItem.id,
                              style: const TextStyle(
                                  fontFamily: "Orbitation",
                                  color: Colors.blueGrey),
                            ),
                            trailing: const Icon(
                              Icons.favorite_border,
                              color: Color(0xFF7569FF),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.94, -0.33),
                    end: Alignment(-0.94, 0.33),
                    colors: [
                      Color(0xFF7569FF),
                      Color(0xFFD869FF),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.music_note_outlined,
                      color: Colors.white,
                    ),
                    Text(
                      state.title,
                      style: const TextStyle(
                          fontFamily: "Orbitation", color: Colors.white),
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
                              icon: const Icon(
                                Icons.skip_previous_outlined,
                                color: Colors.white,
                              ));
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
                                  color: Colors.white),
                            );
                          case PlayButtonEnum.PAUSED:
                            return IconButton(
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              iconSize: 32.0,
                              onPressed: () =>
                                  bloc.add(const MPlayerEvent.play()),
                            );
                          case PlayButtonEnum.PLAYING:
                            return IconButton(
                              icon: const Icon(
                                Icons.pause,
                                color: Colors.white,
                              ),
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
                              icon: const Icon(
                                Icons.skip_next_outlined,
                                color: Colors.white,
                              ));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    bloc.add(const MPlayerEvent.dispose());
    bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    bloc.add(const MPlayerEvent.started());
    super.initState();
  }
}
