import 'package:flutter_firebase/entities/music.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

@freezed
abstract class HomeModel with _$HomeModel {
  const factory HomeModel({
    @Default([]) List<Music> musics,
    Music? selectedMusic,
    @Default(0) double sliderProgress,
    @Default(false) bool sliderDragging,
    @Default(0) double playerProgress,
    @Default(false) bool playing,
    @Default(false) bool waitingForTranscription,
  }) = _HomeModel;
}
