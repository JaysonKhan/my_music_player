
import 'package:flutter/material.dart';
import 'package:my_music_player/feature/m_player/presentation/pages/home/home_page.dart';
import 'package:my_music_player/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Music Player",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
