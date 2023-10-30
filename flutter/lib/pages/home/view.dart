import 'package:flutter/material.dart';
import 'package:flutter_firebase/pages/home/view_model.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final selectedMusic = model.selectedMusic;
    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: model.musics.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ElevatedButton(
                onPressed: () async {
                  await viewModel.addMusic();
                },
                child: const Text('Add'),
              );
            }
            final music = model.musics[index - 1];
            return ListTile(
              title: Text(
                music.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
                        colors: [Colors.blue, Colors.purple],
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
                    position: model.sliderProgress.floor(),
                    lyricUi: viewModel.lyricUI,
                    playing: model.playing,
                    size: Size(
                      double.infinity,
                      MediaQuery.of(context).size.height * 0.75,
                    ),
                    emptyBuilder: () => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Text(
                        'No lyrics',
                        style: viewModel.lyricUI.getOtherMainTextStyle(),
                      ),
                    ),
                    selectLineBuilder: (progress, confirm) => Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            confirm.call();
                          },
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.green),
                        ),
                        Expanded(
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Colors.green),
                            height: 1,
                            width: double.infinity,
                          ),
                        ),
                        Text(
                          progress.toString(),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Container(height: 15),
              if (model.sliderProgress <
                  (model.selectedMusic?.end ?? double.infinity))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Slider(
                        max: model.selectedMusic?.end ?? double.infinity,
                        label: model.sliderProgress.toString(),
                        value: model.sliderProgress,
                        activeColor: Colors.blueGrey,
                        inactiveColor: Colors.blue,
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
                      '${_formatTime(model.playerProgress)}/${_formatTime(model.selectedMusic?.end ?? 0)}',
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 前の曲に関する処理をここに追加します。
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
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
                          model.playing ? Colors.white : Colors.grey,
                      backgroundColor:
                          model.playing ? Colors.grey : Colors.white,
                      elevation: model.playing ? 0 : 5,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(
                      model.playing ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 次の曲に関する処理をここに追加します。
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
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
        ],
      ),
    );
  }
}

String _formatTime(double time) {
  final minutes = time ~/ 60;
  final seconds = time % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
}
