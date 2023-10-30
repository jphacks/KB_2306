import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lyricscribe/entities/music.dart';
import 'package:lyricscribe/pages/home/model.dart';
import 'package:lyricscribe/repositories/music/repository.dart';
import 'package:lyricscribe/repositories/transcription/repository.dart';
import 'package:lyricscribe/utils/view_model_state_notifier.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeModel>(
  (ref) => HomeViewModel(
    musicRepository: ref.read(musicRepositoryProvider),
    transcriptionRepository: ref.read(transcriptionRepositoryProvider),
  ),
);

class HomeViewModel extends ViewModelStateNotifier<HomeModel> {
  HomeViewModel({
    required MusicRepository musicRepository,
    required TranscriptionRepository transcriptionRepository,
  })  : _musicRepository = musicRepository,
        _transcriptionRepository = transcriptionRepository,
        super(const HomeModel()) {
    _papersSubscription = _musicRepository.musicsStream.listen((musics) {
      state = state.copyWith(musics: musics);
    });

    _positionChangeSubscription = audioPlayer.positionStream.listen((position) {
      final selectedMusic = state.selectedMusic;
      if (state.sliderDragging || selectedMusic == null) {
        return;
      }

      final sliderProgress =
          position.inSeconds + (position.inMilliseconds.remainder(1000) / 1000);

      if (sliderProgress >
          selectedMusic.segmentEnds[state.currentSegmentIndex]) {
        // first segment that end is greater than sliderProgress
        final currentSegmentIndex = selectedMusic.segmentStarts
            .indexWhere((element) => element > sliderProgress);
        // indexWhere returns -1 if no element satisfies the condition
        if (currentSegmentIndex == -1) {
          return;
        }
        state = state.copyWith(
          sliderProgress: sliderProgress,
          currentSegmentIndex: currentSegmentIndex,
        );
      }
    });

    _playerStateSubscription = audioPlayer.playerStateStream.listen(
      (playerState) {
        state = state.copyWith(playing: playerState.playing);
      },
    );

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final selectedMusic = state.selectedMusic;
      if (!state.playing || state.sliderDragging || selectedMusic == null) {
        return;
      }
      final sliderProgress = state.sliderProgress + 0.1; // add 100ms
      if (sliderProgress >= selectedMusic.end) {
        state = state.copyWith(sliderProgress: selectedMusic.end);
        Future.microtask(selectNextMusic);
      } else {
        state = state.copyWith(sliderProgress: sliderProgress);
      }
    });
  }

  final MusicRepository _musicRepository;
  final TranscriptionRepository _transcriptionRepository;

  late final StreamSubscription<List<Music?>> _papersSubscription;

  final TextEditingController _titleTextEditingController =
      TextEditingController();
  TextEditingController get titleTextEditingController =>
      _titleTextEditingController;
  late final StreamSubscription<Duration> _positionChangeSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final Timer _timer;

  final audioPlayer = AudioPlayer();

  void clearTitleTextEditingController() => _titleTextEditingController.clear();

  Future<void> addMusic() async {
    if (state.waitingForTranscription) {
      return;
    }
    state = state.copyWith(waitingForTranscription: true);
    await _transcriptionRepository.transcribe();
    state = state.copyWith(waitingForTranscription: false);
  }

  Future<void> updateTitle(String musicId) async {
    await _musicRepository.updateTitle(
      musicId,
      _titleTextEditingController.text,
    );
  }

  Future<void> chooseMusic(int index) async {
    state = state.copyWith(
      selectedMusic: state.musics[index],
      selectedMusicIndex: index,
      sliderProgress: 0,
      playing: true,
    );
    await _startPlayer();
    await audioPlayer.play();
  }

  Future<void> _startPlayer() async {
    final music = state.selectedMusic;
    if (music == null) {
      return;
    }
    state = state.copyWith(playing: true);
    await audioPlayer.setUrl(music.audioUrl);
  }

  Future<void> pausePlayer() async {
    state = state.copyWith(playing: false);
    await audioPlayer.pause();
  }

  Future<void> resumePlayer() async {
    state = state.copyWith(playing: true);
    await audioPlayer.play();
  }

  void onSliderChangeStart() {
    if (state.selectedMusic == null) {
      return;
    }
    state = state.copyWith(sliderDragging: true);
  }

  Future<void> onSliderChangeEnd(double value) async {
    if (state.selectedMusic == null) {
      return;
    }
    state = state.copyWith(
      sliderDragging: false,
      sliderProgress: value,
    );
    await audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  void onSliderChanged(double value) {
    if (state.selectedMusic == null) {
      return;
    }
    state = state.copyWith(sliderProgress: value);
  }

  Future<void> deleteMusic(String musicId) async {
    await _musicRepository.deleteMusic(musicId);
  }

  Future<void> selectPreviousMusic() async {
    final musics = state.musics;
    final selectedMusicIndex = state.selectedMusicIndex;
    if (musics.isEmpty || selectedMusicIndex == null) {
      return;
    }
    final previousMusicIndex =
        selectedMusicIndex == 0 ? musics.length - 1 : selectedMusicIndex - 1;
    await chooseMusic(previousMusicIndex);
  }

  Future<void> selectNextMusic() async {
    final musics = state.musics;
    final selectedMusicIndex = state.selectedMusicIndex;
    if (musics.isEmpty || selectedMusicIndex == null) {
      return;
    }
    final nextMusicIndex =
        selectedMusicIndex == musics.length - 1 ? 0 : selectedMusicIndex + 1;
    await chooseMusic(nextMusicIndex);
  }

  @override
  Future<void> dispose() async {
    await _papersSubscription.cancel();
    await _positionChangeSubscription.cancel();
    await _playerStateSubscription.cancel();
    _timer.cancel();
    super.dispose();
  }
}
