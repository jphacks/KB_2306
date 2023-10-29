import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

// ignore: always_use_package_imports
import 'const copy.dart';

// main関数: アプリのエントリーポイントです。アプリの起動時に最初に実行される関数です。
void main() {
  runApp(MaterialApp(theme: ThemeData.dark(), home: const MyApp()));
}

// MyAppクラス: Flutterアプリケーションのルートウィジェットです。
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AudioPlayer? audioPlayer;
  double sliderProgress = 0;
  int playProgress = 0;
  double max_value = 60000;
  bool isTap = false;

  bool useEnhancedLrc = true;

  LyricsReaderModel lyricModel = LyricsModelBuilder.create()
      .bindLyricToMain(normalLyric)
      .bindLyricToExt(transLyric)
      .getModel();

  UINetease lyricUI = UINetease();

  @override
  void initState() {
    super.initState();
  }

  // Scaffoldウィジェット: 基本的なアプリの構造を提供するウィジェットです。
  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得
    final width = MediaQuery.of(context).size.width;

    // 画面の幅に応じて文字サイズを計算
    final mainTextSize = (width ~/ 100) * 2.5;
    // 計算されたmainTextSizeをlyricUI.defaultSizeに設定
    lyricUI.defaultSize = mainTextSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text('lyricScribe'),
      ),
      body: buildContainer(),
    );
  }

  //曲名のリスト
  List<Widget> buildSongList() => [
        const ListTile(title: Text('Song 1: Sample Title')),
        const ListTile(title: Text('Song 2: Another Title')),
        const ListTile(title: Text('Song 3: More Music')),
        const ListTile(title: Text('Song 4: Melody Tune')),
        const ListTile(title: Text('Song 5: Final Song')),
        const ListTile(title: Text('good-love')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  const Color.fromARGB(255, 84, 13, 117), // button's text color
            ),
            onPressed: () async => pickFile(context),
            child: const Text('曲を追加'),
          ),
        ),
      ];

  //全体の見た目をつかさどる
  Widget buildContainer() => Row(
        children: [
          //左側曲リスト
          Container(
            color: Colors.black,
            width: 250, // Width for song list
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
                        const ListTile(title: Text('good-love')),
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
  //歌詞表示部分
  Stack buildReaderWidget() => Stack(
        children: [
          ...buildReaderBackground(), //背景の設定

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
              width: double.infinity,
              child: Text(
                'No lyrics Now\n Please select or add music',
                textAlign: TextAlign.center, // テキストの配置を中央に設定
                style: lyricUI.getOtherMainTextStyle().copyWith(
                      fontSize: 24,
                    ),
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

  //再生コントロール　部分
  List<Widget> buildPlayControl() => [
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
                  activeColor: const Color.fromARGB(255, 220, 227, 230),
                  inactiveColor: const Color.fromARGB(255, 30, 33, 35),
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
                colors: [
                  Color.fromARGB(255, 84, 13, 117),
                  Color.fromARGB(255, 218, 134, 200),
                ],
              ),
            ),
          ),
        ),
      ];

  double lineGap = 16;
  double inlineGap = 10;
  LyricAlign lyricAlign = LyricAlign.CENTER;
  HighlightDirection highlightDirection = HighlightDirection.LTR;

  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }

  double bias = 0.5;
  LyricBaseLine lyricBiasBaseLine = LyricBaseLine.CENTER;

  Text buildTitle(String title) => Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      );
}

// Helper function to format milliseconds into mm:ss format
String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
}

// ファイルピックを実行する関数
Future<void> pickFile(BuildContext context) async {
  // ignore: unused_local_variable
  final filePickerResult = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3'], // Only allow mp3 files to be picked
  );
}
