import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/pages/home/view_model.dart';

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final selectedMusic = model.selectedMusic;
    final viewModel = ref.watch(homeViewModelProvider.notifier);

    final lyricsUI = UINetease(highlight: false);

    final mainTextSize = (MediaQuery.of(context).size.width ~/ 100) * 2.5;
    lyricsUI.defaultSize = mainTextSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedMusic?.title ?? 'Please select a music',
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView.builder(
          itemCount: model.musics.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 15,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(
                      255,
                      84,
                      13,
                      117,
                    ), // button text color
                  ),
                  onPressed: () async {
                    await viewModel.addMusic();
                  },
                  child: Center(
                    child: model.waitingForTranscription
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              const Icon(Icons.add),
                              Container(
                                width: 10,
                              ),
                              const Text('Add Music'),
                            ],
                          ),
                  ),
                ),
              );
            }
            final music = model.musics[index - 1];
            return ListTile(
              title: Text(
                music.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await viewModel.chooseMusic(index - 1);
              },
              trailing: IconButton(
                onPressed: () async {
                  await viewModel.deleteMusic(music.id);
                },
                icon: const Icon(Icons.delete),
              ),
            );
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
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
                    size: Size(
                      double.infinity,
                      MediaQuery.of(context).size.height * 0.75,
                    ),
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
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
            child: Column(
              children: [
                Container(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Slider(
                        max: model.selectedMusic?.end ?? double.infinity,
                        label: model.sliderProgress.toString(),
                        value: model.sliderProgress,
                        activeColor: const Color.fromARGB(255, 220, 227, 230),
                        inactiveColor: const Color.fromARGB(255, 30, 33, 35),
                        onChanged: viewModel.onSliderChanged,
                        onChangeStart: (value) {
                          viewModel.onSliderChangeStart();
                        },
                        onChangeEnd: (value) async {
                          await viewModel.onSliderChangeEnd(value);
                        },
                      ),
                    ),
                    Text(
                      '${_formatTime(model.sliderProgress)}/${_formatTime(model.selectedMusic?.end ?? 0)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.selectPreviousMusic();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.skip_previous),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (model.playing) {
                          await viewModel.pausePlayer();
                        } else {
                          await viewModel.resumePlayer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            model.playing ? Colors.white : Colors.grey[800],
                        backgroundColor:
                            model.playing ? Colors.grey[800] : Colors.white,
                        elevation: model.playing ? 0 : 5,
                        shape: const CircleBorder(),
                      ),
                      child: Icon(
                        model.playing ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.selectNextMusic();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(double time) {
  final minutes = (time ~/ 60).toString().padLeft(2, '0');
  final seconds = (time % 60).floor().toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
