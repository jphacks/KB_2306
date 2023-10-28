import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/const.dart';
import 'package:flutter_firebase/firebase_options.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseAuth.instance.signInAnonymously();

      runApp(MaterialApp(theme: ThemeData.dark(), home: const MyApp()));
    },
    (error, stackTrace) {
      print('runZonedGuarded: Caught error in my root zone.');
      print('error\n$error');
      print('stacktrace\n$stackTrace');
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AudioPlayer? audioPlayer;
  double sliderProgress = 111658;
  int playProgress = 111658;
  double max_value = 211658;
  bool isTap = false;

  LyricsReaderModel lyricModel = LyricsModelBuilder.create()
      .bindLyricToMain(advancedLyric)
      .bindLyricToExt(transLyric)
      .getModel();

  UINetease lyricUI = UINetease();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final mainTextSize = (width ~/ 100) * 2.5;
    lyricUI.defaultSize = mainTextSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: buildContainer(),
    );
  }

  List<Widget> buildSongList() => [
        const ListTile(title: Text('Song 1: Sample Title')),
        const ListTile(title: Text('Song 2: Another Title')),
        const ListTile(title: Text('Song 3: More Music')),
        const ListTile(title: Text('Song 4: Melody Tune')),
        const ListTile(title: Text('Song 5: Final Song')),
      ];

  Widget buildContainer() => Row(
        children: [
          Container(
            color: Colors.grey,
            width: 250, // Width for song list
            child: ListView(
              children: buildSongList(),
            ),
          ),
          Expanded(
            child: Column(
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
            ),
          ),
        ],
      );

  double lyricPadding = 40;
  Stack buildReaderWidget() => Stack(
        children: [
          ...buildReaderBackground(),
          LyricsReader(
            padding: EdgeInsets.symmetric(horizontal: lyricPadding),
            model: lyricModel,
            position: playProgress,
            lyricUi: lyricUI,
            playing: playing,
            size: Size(
              double.infinity,
              MediaQuery.of(context).size.height * 0.75,
            ),
            emptyBuilder: () => SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Text(
                'No lyrics',
                style: lyricUI.getOtherMainTextStyle(),
              ),
            ),
            selectLineBuilder: (progress, confirm) => Row(
              children: [
                IconButton(
                  onPressed: () {
                    LyricsLog.logD('点击事件');
                    confirm.call();
                    setState(() async {
                      await audioPlayer?.seek(Duration(milliseconds: progress));
                    });
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.green),
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
      );

  List<Widget> buildPlayControl() => [
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
                  max: max_value,
                  label: sliderProgress.toString(),
                  value: sliderProgress,
                  activeColor: Colors.blueGrey,
                  inactiveColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      sliderProgress = value;
                    });
                  },
                  onChangeStart: (value) {
                    isTap = true;
                  },
                  onChangeEnd: (value) async {
                    isTap = false;
                    setState(() {
                      playProgress = value.toInt();
                    });
                    await audioPlayer
                        ?.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              //時間のテキスト
              Text(
                '${_formatDuration(Duration(milliseconds: playProgress))}/${_formatDuration(Duration(milliseconds: max_value.toInt()))}',
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
                foregroundColor: Colors.grey,
                backgroundColor: Colors.white,
                elevation: 5,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.skip_previous),
            ),
            //一時停止再生
            ElevatedButton(
              onPressed: () async {
                if (audioPlayer == null || !playing) {
                  audioPlayer = AudioPlayer();
                  await audioPlayer!.play(AssetSource('music1.mp3'));
                  setState(() {
                    playing = true;
                  });
                  audioPlayer?.onDurationChanged.listen((event) {
                    setState(() {
                      max_value = event.inMilliseconds.toDouble();
                    });
                  });
                  audioPlayer?.onPositionChanged.listen((event) {
                    if (isTap) {
                      return;
                    }
                    setState(() {
                      sliderProgress = event.inMilliseconds.toDouble();
                      playProgress = event.inMilliseconds;
                    });
                  });

                  audioPlayer?.onPlayerStateChanged.listen((state) {
                    setState(() {
                      playing = state == PlayerState.playing;
                    });
                  });
                } else {
                  if (playing) {
                    await audioPlayer?.pause();
                  } else {
                    await audioPlayer?.resume();
                  }
                  setState(() {
                    playing = !playing;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: playing ? Colors.white : Colors.grey,
                backgroundColor: playing ? Colors.grey : Colors.white,
                elevation: playing ? 0 : 5,
                shape: const CircleBorder(),
              ),
              child: Icon(playing ? Icons.pause : Icons.play_arrow),
            ),
            //次の曲
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
      ];

  bool playing = false;
  // 歌詞部分の背景の設定
  List<Widget> buildReaderBackground() => [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
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

// Helper function to format milliseconds into mm:ss format
String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
}
