# LyricScribe

<img src="https://github.com/jphacks/KB_2306/assets/147470382/1e7d8f9a-9485-43be-9f01-a6de53ec822a" width="500px">

## 製品ページ

https://lyrics-transcriber.web.app/

注）歌詞の文字起こしを長時間行っていない場合、初回の処理に失敗することがあります。もう一度試してください。

## 製品概要

https://github.com/jphacks/KB_2306/assets/53816975/e0c310ff-33fb-4ac9-8b6c-cfcec829b959

### Lyrics × Tech

音楽ファイルをダウンロードし、文字起こし AI「Whisper」を使って歌詞を自動生成します。  
使い方は簡単！！　どんな音楽も歌詞を見ながら楽しめる  
音楽を再生すれば、聴いているところの歌詞が表示されます！

### 背景(製品開発のきっかけ、課題等）

<img src="https://github.com/jphacks/KB_2306/assets/147470382/a0a3f2d8-28e3-4eed-912a-201fcccad5b1" width="350px">

#### １コマ目：ある日、石川少年はインディーズアーティストの楽曲にどハマりしました。

#### ２コマ目：携帯の音楽再生アプリでそのアーティストの楽曲を聴こうとすると音楽が早すぎて何を言っているのかわかりません。

#### ３コマ目：歌詞が見たい！！　でも調べても歌詞が出てこない...。

#### ４コマ目：「そうだ！歌詞を自動生成してくれるアプリを作ろう！！」と考えたのでした。

### 製品説明（具体的な製品の説明）

### 特長

#### 1. 特長 1 　アーティストがマイナーで、歌詞が公開されていないものも、歌詞を自動生成

音楽ファイルから、ボーカルの音だけを抽出して  
文字起こし AI の「Whisper」を使うことで歌詞を生成しているので  
歌詞が公開されていない曲でも、いつも聴いているサブスクで歌詞が見れない曲でも  
どんな曲の歌詞も自動生成できます。

#### 2. 特長 2 　音楽のファイルをアップするだけだから簡単

操作は簡単！！  
音楽ファイルをアップロードするだけで歌詞を自動生成します。

#### 3. 特長 3 　音楽に合わせて歌詞が流れる

現在の歌詞がどの部分なのか、1 文ずつ細かく区切られていてわかりやすい！  
どんなに早口な歌でも、歌詞をスムーズに追いながら楽しむことができます。

### 解決出来ること

さまざまな音楽ストリーミングサービスがある中で、特定の楽曲、

特にインディーズアーティストのものやライブ音源、童謡などには、歌詞が付属していないことが多い。

音楽を聴くときに、歌詞を見ながら聴きたいと言う人は多く当アプリを使うことで

どんな音楽でも歌詞と一緒に音楽を楽しむことができるようになる。

### 今後の展望

- ユーザーが現在利用中のサブスクリプションサービスを補完する形での利用が期待される。
- 技術的な課題として、現状はハモリやデュオなど、複数の音声が同時にある場合は歌詞が崩れる。  
  この場合の対策として前処理を増やして、ボーカルごとに音を分離するアプローチを検討中である。
- 言語サポートに関しては、英語やスペイン語、中国語などの主要言語には対応できているが、  
  日本語においては文脈に合った漢字を正確に出すことが難しいため改善の余地がある。

### 注力したこと（こだわり等）

- 音楽を楽しむために作られた、シンプルでおしゃれな UI
- 歌詞が音楽と同時に流れる形式
- 音楽ファイルをアップロードするだけで、歌詞が表示されるシンプルさ

## 開発技術

### 活用した技術

#### API・データ

- 文字起こし実行
  - [Hugging Face Inference Endpoints](https://huggingface.co/inference-endpoints)
    - [Moseca](https://github.com/fabiogra/moseca) でボーカルとそれ以外の音源分離
    - [Whisper](https://github.com/openai/whisper) でボーカルを文字起こし
- クライアント
  - Flutter Web
    - [Hive](https://pub.dev/packages/hive) で歌詞と音楽データを管理
  - Firebase Hosting にデプロイ
- Firebase
  - Web アプリと Hugging Face の処理の中継を Firebase Cloud Functions で行う

#### フレームワーク・ライブラリ・モジュール

- Hugging Face
  - Python
  - PyTorch
- Web アプリ
  - Dart
  - Flutter
- サーバ
  - Firebase
    - Firebase Cloud Functions
      - Typescript
    - Firebase Authentication

### 独自技術

#### ハッカソンで開発した独自機能・技術

- Web クライアントアプリ全般
  - [`flutter/`](https://github.com/jphacks/KB_2306/tree/master/flutter)
- Moseca の音源分離モデルを動作させるための音声データの処理
  - [`huggingface/src/services/vocal_remover`](https://github.com/jphacks/KB_2306/tree/master/huggingface/src/services/vocal_remover)
- 音源分離モデルと文字起こしモデルの統合
  - [`huggingface/app.py`](https://github.com/jphacks/KB_2306/blob/master/huggingface/app.py)
- Web アプリと Hugging Face の中継
  - [`firebase/functions/`](https://github.com/jphacks/KB_2306/tree/master/firebase/functions)

#### 特に力を入れた項目

- モデルの実行系を自作
  - OpenAI の API などを利用せずに Hugging Face で実行
    - [`huggingface/src/services/`](https://github.com/jphacks/KB_2306/tree/master/huggingface/src/services/)
    - OpenAI の API では何秒のところで何と言っているかが取得できないため自作
- データ管理
  - IndexedDB ベースでブラウザにデータを保存
    - [`flutter/lib/helpers/hive.dart`](https://github.com/jphacks/KB_2306/tree/master/flutter/lib/helpers/hive.dart)
      - 曲と歌詞のデータを保存する
