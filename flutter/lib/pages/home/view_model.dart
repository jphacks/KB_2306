import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase/entities/music.dart';
import 'package:flutter_firebase/pages/home/model.dart';
import 'package:flutter_firebase/repositories/music/repository.dart';
import 'package:flutter_firebase/repositories/transcription/repository.dart';
import 'package:flutter_firebase/utils/view_model_state_notifier.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  }

  final MusicRepository _musicRepository;
  final TranscriptionRepository _transcriptionRepository;

  late final StreamSubscription<List<Music?>> _papersSubscription;

  final TextEditingController _titleTextEditingController =
      TextEditingController();
  TextEditingController get titleTextEditingController =>
      _titleTextEditingController;

  final audioPlayer = AudioPlayer();
  final lyricUI = UINetease();

  void clearTitleTextEditingController() => _titleTextEditingController.clear();

  Future<void> addMusic() async {
    await _transcriptionRepository.transcribe();
  }

  Future<void> updateTitle(String musicId) async {
    await _musicRepository.updateTitle(
      musicId,
      _titleTextEditingController.text,
    );
  }

  void chooseMusic(int index) {
    state = state.copyWith(
      selectedMusic: state.musics[index],
      sliderProgress: 0,
      playerProgress: 0,
    );
  }

  Future<void> startPlayer() async {
    final audio = state.selectedMusic?.audio;
    if (audio == null) {
      return;
    }
    state = state.copyWith(playing: true);
    await audioPlayer.play(BytesSource(audio));
  }

  Future<void> pausePlayer() async {
    state = state.copyWith(playing: false);
    await audioPlayer.pause();
  }

  void onSliderChangeStart() {
    state = state.copyWith(sliderDragging: true);
  }

  Future<void> onSliderChangeEnd(double value) async {
    state = state.copyWith(
      sliderDragging: false,
      sliderProgress: value,
      playerProgress: value,
    );
    await audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  void onSliderChanged(double value) {
    state = state.copyWith(sliderProgress: value);
  }

  @override
  Future<void> dispose() async {
    await _papersSubscription.cancel();
    super.dispose();
  }
}
