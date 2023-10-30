import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/pages/home/view_model.dart';

class MusicList extends HookConsumerWidget {
  const MusicList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeViewModelProvider);
    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return ListView.builder(
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
    );
  }
}
