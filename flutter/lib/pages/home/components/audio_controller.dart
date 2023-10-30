import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/pages/home/view_model.dart';

String _formatTime(double time) {
  final minutes = (time ~/ 60).toString().padLeft(2, '0');
  final seconds = (time % 60).floor().toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class AudioControllerUI extends HookConsumerWidget {
  const AudioControllerUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.only(
        top: 5,
        bottom: 10,
        left: 30,
        right: 30,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Slider(
                  max: model.selectedMusic?.end ?? double.infinity,
                  label: model.sliderProgress.toString(),
                  value: model.sliderProgress,
                  activeColor: const Color.fromARGB(255, 220, 227, 230),
                  inactiveColor: const Color.fromARGB(255, 93, 99, 102),
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
    );
  }
}
