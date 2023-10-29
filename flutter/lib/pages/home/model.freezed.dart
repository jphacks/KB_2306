// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$HomeModel {
  List<Music> get musics => throw _privateConstructorUsedError;
  Music? get selectedMusic => throw _privateConstructorUsedError;
  double get sliderProgress => throw _privateConstructorUsedError;
  bool get sliderDragging => throw _privateConstructorUsedError;
  double get playerProgress => throw _privateConstructorUsedError;
  bool get playing => throw _privateConstructorUsedError;
  bool get waitingForTranscription => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeModelCopyWith<HomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeModelCopyWith<$Res> {
  factory $HomeModelCopyWith(HomeModel value, $Res Function(HomeModel) then) =
      _$HomeModelCopyWithImpl<$Res, HomeModel>;
  @useResult
  $Res call(
      {List<Music> musics,
      Music? selectedMusic,
      double sliderProgress,
      bool sliderDragging,
      double playerProgress,
      bool playing,
      bool waitingForTranscription});
}

/// @nodoc
class _$HomeModelCopyWithImpl<$Res, $Val extends HomeModel>
    implements $HomeModelCopyWith<$Res> {
  _$HomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? musics = null,
    Object? selectedMusic = freezed,
    Object? sliderProgress = null,
    Object? sliderDragging = null,
    Object? playerProgress = null,
    Object? playing = null,
    Object? waitingForTranscription = null,
  }) {
    return _then(_value.copyWith(
      musics: null == musics
          ? _value.musics
          : musics // ignore: cast_nullable_to_non_nullable
              as List<Music>,
      selectedMusic: freezed == selectedMusic
          ? _value.selectedMusic
          : selectedMusic // ignore: cast_nullable_to_non_nullable
              as Music?,
      sliderProgress: null == sliderProgress
          ? _value.sliderProgress
          : sliderProgress // ignore: cast_nullable_to_non_nullable
              as double,
      sliderDragging: null == sliderDragging
          ? _value.sliderDragging
          : sliderDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      playerProgress: null == playerProgress
          ? _value.playerProgress
          : playerProgress // ignore: cast_nullable_to_non_nullable
              as double,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      waitingForTranscription: null == waitingForTranscription
          ? _value.waitingForTranscription
          : waitingForTranscription // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeModelImplCopyWith<$Res>
    implements $HomeModelCopyWith<$Res> {
  factory _$$HomeModelImplCopyWith(
          _$HomeModelImpl value, $Res Function(_$HomeModelImpl) then) =
      __$$HomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Music> musics,
      Music? selectedMusic,
      double sliderProgress,
      bool sliderDragging,
      double playerProgress,
      bool playing,
      bool waitingForTranscription});
}

/// @nodoc
class __$$HomeModelImplCopyWithImpl<$Res>
    extends _$HomeModelCopyWithImpl<$Res, _$HomeModelImpl>
    implements _$$HomeModelImplCopyWith<$Res> {
  __$$HomeModelImplCopyWithImpl(
      _$HomeModelImpl _value, $Res Function(_$HomeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? musics = null,
    Object? selectedMusic = freezed,
    Object? sliderProgress = null,
    Object? sliderDragging = null,
    Object? playerProgress = null,
    Object? playing = null,
    Object? waitingForTranscription = null,
  }) {
    return _then(_$HomeModelImpl(
      musics: null == musics
          ? _value._musics
          : musics // ignore: cast_nullable_to_non_nullable
              as List<Music>,
      selectedMusic: freezed == selectedMusic
          ? _value.selectedMusic
          : selectedMusic // ignore: cast_nullable_to_non_nullable
              as Music?,
      sliderProgress: null == sliderProgress
          ? _value.sliderProgress
          : sliderProgress // ignore: cast_nullable_to_non_nullable
              as double,
      sliderDragging: null == sliderDragging
          ? _value.sliderDragging
          : sliderDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      playerProgress: null == playerProgress
          ? _value.playerProgress
          : playerProgress // ignore: cast_nullable_to_non_nullable
              as double,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      waitingForTranscription: null == waitingForTranscription
          ? _value.waitingForTranscription
          : waitingForTranscription // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HomeModelImpl implements _HomeModel {
  const _$HomeModelImpl(
      {final List<Music> musics = const [],
      this.selectedMusic,
      this.sliderProgress = 0,
      this.sliderDragging = false,
      this.playerProgress = 0,
      this.playing = false,
      this.waitingForTranscription = false})
      : _musics = musics;

  final List<Music> _musics;
  @override
  @JsonKey()
  List<Music> get musics {
    if (_musics is EqualUnmodifiableListView) return _musics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_musics);
  }

  @override
  final Music? selectedMusic;
  @override
  @JsonKey()
  final double sliderProgress;
  @override
  @JsonKey()
  final bool sliderDragging;
  @override
  @JsonKey()
  final double playerProgress;
  @override
  @JsonKey()
  final bool playing;
  @override
  @JsonKey()
  final bool waitingForTranscription;

  @override
  String toString() {
    return 'HomeModel(musics: $musics, selectedMusic: $selectedMusic, sliderProgress: $sliderProgress, sliderDragging: $sliderDragging, playerProgress: $playerProgress, playing: $playing, waitingForTranscription: $waitingForTranscription)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeModelImpl &&
            const DeepCollectionEquality().equals(other._musics, _musics) &&
            (identical(other.selectedMusic, selectedMusic) ||
                other.selectedMusic == selectedMusic) &&
            (identical(other.sliderProgress, sliderProgress) ||
                other.sliderProgress == sliderProgress) &&
            (identical(other.sliderDragging, sliderDragging) ||
                other.sliderDragging == sliderDragging) &&
            (identical(other.playerProgress, playerProgress) ||
                other.playerProgress == playerProgress) &&
            (identical(other.playing, playing) || other.playing == playing) &&
            (identical(
                    other.waitingForTranscription, waitingForTranscription) ||
                other.waitingForTranscription == waitingForTranscription));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_musics),
      selectedMusic,
      sliderProgress,
      sliderDragging,
      playerProgress,
      playing,
      waitingForTranscription);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      __$$HomeModelImplCopyWithImpl<_$HomeModelImpl>(this, _$identity);
}

abstract class _HomeModel implements HomeModel {
  const factory _HomeModel(
      {final List<Music> musics,
      final Music? selectedMusic,
      final double sliderProgress,
      final bool sliderDragging,
      final double playerProgress,
      final bool playing,
      final bool waitingForTranscription}) = _$HomeModelImpl;

  @override
  List<Music> get musics;
  @override
  Music? get selectedMusic;
  @override
  double get sliderProgress;
  @override
  bool get sliderDragging;
  @override
  double get playerProgress;
  @override
  bool get playing;
  @override
  bool get waitingForTranscription;
  @override
  @JsonKey(ignore: true)
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
