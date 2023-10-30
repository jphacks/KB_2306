import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/pages/home/view_model.dart';

class LyricsReaderUI extends HookConsumerWidget {
  LyricsReaderUI({super.key});

  final lyricsUI = UINetease(highlight: false)..defaultSize = 28;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final selectedMusic = model.selectedMusic;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 84, 13, 117),
                  Color.fromARGB(255, 218, 134, 200),
                ],
              ),
            ),
          ),
        ),
        if (selectedMusic != null)
          LyricsReader(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            model: LyricsModelBuilder.create()
                .bindLyricToMain(selectedMusic.formattedSegments)
                .getModel(),
            position: model.sliderProgress.ceil() * 1000,
            lyricUi: lyricsUI,
            playing: false,
            emptyBuilder: () => SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              width: double.infinity,
              child: Center(
                child: Text(
                  'No lyrics Now\n Please select or add music',
                  textAlign: TextAlign.center,
                  style: lyricsUI.getOtherMainTextStyle().copyWith(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
