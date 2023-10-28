import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

import 'const.dart';

// main関数: アプリのエントリーポイントです。アプリの起動時に最初に実行される関数です。
void main() {
  runApp(MaterialApp(home: MyApp()));
}

// MyAppクラス: Flutterアプリケーションのルートウィジェットです。
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AudioPlayer? audioPlayer;
  double sliderProgress = 111658;
  int playProgress = 111658;
  double max_value = 211658;
  bool isTap = false;

  bool useEnhancedLrc = true;

  var lyricModel = LyricsModelBuilder.create()
      .bindLyricToMain(advancedLyric)
      .bindLyricToExt(transLyric)
      .getModel();

  var lyricUI = UINetease();

  @override
  void initState() {
    super.initState();
  }

// Scaffoldウィジェット: 基本的なアプリの構造を提供するウィジェットです。
  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得
    double width = MediaQuery.of(context).size.width;

    // 画面の幅に応じて文字サイズを計算
    var mainTextSize = (width ~/100) * 2.5;
    var extTextSize = mainTextSize * 0.8;
    // 計算されたmainTextSizeをlyricUI.defaultSizeに設定
    lyricUI.defaultSize = mainTextSize;
    extTextSize = extTextSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: buildContainer(),
    );
  }

  Widget buildContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildReaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...buildPlayControl(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  var lyricPadding = 40.0;
//歌詞表示部分
  Stack buildReaderWidget() {
    return Stack(
      children: [
        ...buildReaderBackground(), //背景の設定
        LyricsReader(
          padding: EdgeInsets.symmetric(horizontal: lyricPadding),
          model: lyricModel,
          position: playProgress,
          lyricUi: lyricUI,
          playing: playing,
          size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
          emptyBuilder: () => Center(
            child: Text(
              "No lyrics",
              style: lyricUI.getOtherMainTextStyle(),
            ),
          ),
          selectLineBuilder: (progress, confirm) {
            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      LyricsLog.logD("点击事件");
                      confirm.call();
                      setState(() {
                        audioPlayer?.seek(Duration(milliseconds: progress));
                      });
                    },
                    icon: Icon(Icons.play_arrow, color: Colors.green)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.green),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                Text(
                  progress.toString(),
                  style: TextStyle(color: Colors.green),
                )
              ],
            );
          },
        )
      ],
    );
  }

  List<Widget> buildPlayControl() {
    return [
      Container(
        height: 20,
      ),
      if (sliderProgress < max_value)
        Slider(
          min: 0,
          max: max_value,
          label: sliderProgress.toString(),
          value: sliderProgress,
          activeColor: Colors.blueGrey,
          inactiveColor: Colors.blue,
          onChanged: (double value) {
            setState(() {
              sliderProgress = value;
            });
          },
          onChangeStart: (double value) {
            isTap = true;
          },
          onChangeEnd: (double value) {
            isTap = false;
            setState(() {
              playProgress = value.toInt();
            });
            audioPlayer?.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //前の曲に戻る
          ElevatedButton(
            onPressed: () {
              // 前の曲に関する処理をここに追加します。
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.grey,
              elevation: 5,
              shape: CircleBorder(),
            ),
            child: Icon(Icons.skip_previous),
          ),
          //一時停止再生
          ElevatedButton(
            onPressed: () async {
              if (audioPlayer == null || !playing) {
                audioPlayer = AudioPlayer()..play(AssetSource("music1.mp3"));
                setState(() {
                  playing = true;
                });
                audioPlayer?.onDurationChanged.listen((Duration event) {
                  setState(() {
                    max_value = event.inMilliseconds.toDouble();
                  });
                });
                audioPlayer?.onPositionChanged.listen((Duration event) {
                  if (isTap) return;
                  setState(() {
                    sliderProgress = event.inMilliseconds.toDouble();
                    playProgress = event.inMilliseconds;
                  });
                });

                audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
                  setState(() {
                    playing = state == PlayerState.playing;
                  });
                });
              } else {
                if (playing) {
                  audioPlayer?.pause();
                } else {
                  audioPlayer?.resume();
                }
                setState(() {
                  playing = !playing;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              primary: playing ? Colors.grey : Colors.white,
              onPrimary: playing ? Colors.white : Colors.grey,
              elevation: playing ? 0 : 5,
              shape: CircleBorder(),
            ),
            child: Icon(playing ? Icons.pause : Icons.play_arrow),
          ),
          //次の曲
          ElevatedButton(
            onPressed: () {
              // 次の曲に関する処理をここに追加します。
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.grey,
              elevation: 5,
              shape: CircleBorder(),
            ),
            child: Icon(Icons.skip_next),
          ),
        ],
      )
    ];
  }

  var playing = false;
// 背景の設定
  List<Widget> buildReaderBackground() {
    return [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.purple], //青から紫へのグラデーション
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      )
    ];
  }


  var extTextSize = 16.0;
  var lineGap = 16.0;
  var inlineGap = 10.0;
  var lyricAlign = LyricAlign.CENTER;
  var highlightDirection = HighlightDirection.LTR;


  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }

  var bias = 0.5;
  var lyricBiasBaseLine = LyricBaseLine.CENTER;

  Text buildTitle(String title) => Text(title,
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
}
