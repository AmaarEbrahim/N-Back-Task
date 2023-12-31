import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('', () async {
    AudioPlayer a = AudioPlayer();
    await a.play(UrlSource("../assets/letter_audio/A.mp3"));
  });
}