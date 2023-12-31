import 'package:audioplayers/audioplayers.dart';


void main() async {
  AudioPlayer a = AudioPlayer();
  while (true) {
    await a.play(UrlSource("./../../assets/letter_audio/A.mp3"));
  }
}