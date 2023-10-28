import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

import 'const.dart';

// main関数: アプリのエントリーポイントです。アプリの起動時に最初に実行される関数です。
void main() {

  runApp(MaterialApp(theme: ThemeData.dark(), home: MyApp()));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: buildContainer(),
    );
  }

  //曲名のリスト
  List<Widget> buildSongList() {
    return [
      ListTile(title: Text("Song 1: Sample Title")),
      ListTile(title: Text("Song 2: Another Title")),
      ListTile(title: Text("Song 3: More Music")),
      ListTile(title: Text("Song 4: Melody Tune")),
      ListTile(title: Text("Song 5: Final Song"))
    ];
  }
  //全体の見た目をつかさどる
  Widget buildContainer() {
    return Row(
      children: [
        //左側曲リスト
        Container(
          color: Colors.grey,
          width: 250,  // Width for song list
          child: ListView(
            children: buildSongList(),
          ),
        ),
        //右側　歌詞表示　再生操作類
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //歌詞表示
              buildReaderWidget(),
              //再生操作類の作成
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
          size: Size(double.infinity, MediaQuery.of(context).size.height * 0.75),
          emptyBuilder: () => Container(height: MediaQuery.of(context).size.height * 0.75,
          
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
        ),
      ],
    );
  }
  //再生コントロール　部分
  List<Widget> buildPlayControl() {
    return [
      Container(
        height: 15,
      ),
      //進行バーを最大値ではないとき表示
      if (sliderProgress < max_value)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //進行バー
            Expanded(  
              child: Slider(
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
            ),
            //時間のテキスト
            Text(
              "${_formatDuration(Duration(milliseconds: playProgress))}/${_formatDuration(Duration(milliseconds: max_value.toInt()))}"
            ),
          ],
        ),
      //再生戻る進むボタン
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //前の曲に戻る 色や機能変更必要
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
              if (!playing) {
                // 初めての再生の場合のみイベントリスナーを設定
                if (max_value == null) {
                  audioPlayer.onDurationChanged.listen((Duration event) {
                    setState(() {
                      max_value = event.inMilliseconds.toDouble();
                    });
                  });
                  audioPlayer.onPositionChanged.listen((Duration event) {
                    if (isTap) return;
                    setState(() {
                      sliderProgress = event.inMilliseconds.toDouble();
                      playProgress = event.inMilliseconds;
                    });
                  });
                  audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
                    setState(() {
                      playing = state == PlayerState.playing;
                    });
                  });
                }
                // 曲を再生
                await audioPlayer.play(AssetSource("music1.mp3"));
              } else {
                // 一時停止または再開
                if (playing) {
                  audioPlayer.pause();
                } else {
                  audioPlayer.resume();
                }
              }
              setState(() {
                playing = !playing;
              });
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
  // 歌詞部分の背景の設定
  List<Widget> buildReaderBackground() {
    return [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.purple], //青から紫へのグラデーション変更必須
            ),
          ),
        ),
      ),
    ];
  }



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
  // Helper function to format milliseconds into mm:ss format
  String _formatDuration(Duration duration) {
    var minutes = duration.inMinutes;
    var seconds = duration.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
                 