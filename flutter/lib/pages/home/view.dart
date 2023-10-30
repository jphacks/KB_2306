import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/pages/home/components/audio_controller.dart';
import 'package:lyricscribe/pages/home/components/lyrics_reader.dart';
import 'package:lyricscribe/pages/home/components/music_list.dart';
import 'package:lyricscribe/pages/home/view_model.dart';

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final selectedMusic = model.selectedMusic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedMusic?.title ?? 'Please select a music',
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      drawer: const Drawer(
        backgroundColor: Colors.black,
        child: MusicList(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: LyricsReaderUI()),
          const AudioControllerUI(),
        ],
      ),
    );
  }
}
