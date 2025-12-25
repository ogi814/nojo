# Flutter教科書 - 初級編 - 2. Flutterの基礎 (農場たとえ話・増量版)

Dartという言語（農作業の言葉）を覚えたあなた。次はいよいよ、Flutterを使って自分だけの農場を実際に作り上げていきます。この章では、農場を建てるための「道具一式」を揃え、Flutterの最も重要な設計思想である「Widget」について学びます。

---

## 2.1 開発環境のセットアップ ～万能ツールキットを手に入れよう～

農場を作るには、クワやスコップ、設計図が必要です。Flutter開発におけるこれらの道具が「開発環境」です。

### Flutter SDK: 魔法の農場ツールキット
Flutter SDKは、いわば「魔法の農場ツールキット」です。これ一つあれば、種（Widget）や設計図の描き方、建物の建て方まで、農場作りに必要なものがすべて揃います。

インストールは、公式サイトの最新の手順に従うのが最も安全で確実です。OS（Windows, macOS, Linux）ごとに手順が少し異なります。

> **公式ドキュメント:** [Flutter SDKのインストール](https://flutter.dev/docs/get-started/install)

### `flutter doctor`: 農場開設の監査人
ツールキットを揃えたら、`flutter doctor`というコマンドを実行してみましょう。これは、農場開設のライセンス（Android/iOSの開発環境）がすべて揃っているかを確認してくれる、頼れる監査人のようなものです。

```bash
$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (魔法の農場ツールキット)
[✓] Android toolchain (アンドロイド村への出荷許可)
[✓] Xcode (アップル国への出荷許可)
[✓] Chrome (ウェブサイト農場への出荷許可)
[✓] Android Studio (高機能な設計事務所)
[✓] VS Code (軽量な作業小屋)
[✓] Connected device (出荷先の市場)

• No issues found! (問題なし！いつでも開設できます)
```
すべてに `[✓]` がつけば、あなたの農場を開設する準備は万端です。

### エミュレータ: 魔法のミニチュア模型
エミュレータ（またはシミュレータ）は、**農場のミニチュア模型**です。実際に広大な土地に建物を建てる前に、この模型上で「ここに母屋を建てて、こっちに畑を作って…」と試すことができます。失敗してもすぐに元に戻せるので、時間と資源を大幅に節約できます。

---

## 2.2 Widgetツリーの理解 ～農場の全体設計図～

Flutterの最も重要な考え方、それは**「すべてがWidget（ウィジェット）である」**ということです。
農場に例えるなら**「農場を構成するものは、すべてが建築部品（Widget）である」**となります。母屋、納屋、畑、看板、さらには看板に書かれた文字一つ一つまで、すべてが「部品」なのです。

そして、これらの部品は、**農場の全体設計図（Widgetツリー）**に従って、階層的に組み立てられます。

```mermaid
graph TD
    A[農場全体 (MyApp)] --> B[ブランドデザイン (MaterialApp)];
    B --> C[母屋 (Scaffold)];
    C --> D[屋根 (AppBar)];
    C --> E[部屋の中央 (Center)];
    D --> F[表札 (Text)];
    E --> G[家具 (Text)];
```

この設計図は、「農場全体の中に、特定のブランドデザインがあり、その中心に母屋が建っている。母屋には屋根と部屋があり、屋根には表札が、部屋の中央には家具が置かれている」という構造を示しています。

#### サンプルコード: 設計図の記述

以下のコードは、まさに上の設計図をプログラミング言語で記述したものです。

```dart
import 'package:flutter/material.dart';

// 農場経営の開始！
void main() {
  runApp(const MyApp());
}

// MyApp: 農場全体の設計図
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp: 農場のブランドデザイン(色やフォントなど)を指定
    return MaterialApp(
      title: 'My Farm',
      // home: 母屋の設計図を指定
      home: Scaffold(
        // appBar: 屋根の設計図
        appBar: AppBar(
          title: const Text('My First Farm'), // 屋根についている表札
        ),
        // body: 母屋の本体
        body: const Center( // 部屋の中央に
          child: Text( // 家具を置く
            'Welcome to my farm!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

---

## 2.3 StatelessWidgetとStatefulWidgetの違い ～看板と電光掲示板～

農場に設置する「建築部品」には、その性質によって大きく2つの種類があります。

### StatelessWidget: ペンキで書いた看板

`StatelessWidget`は、一度設置したら内容が変わらない、**ペンキで書いた木製の看板**のようなものです。「牛小屋」や「トマト畑」といった、静的な情報を表示するのに使います。

- **特徴**:
  - 状態を持たないので、設置が簡単で軽い（パフォーマンスが良い）。
  - 一度描画されたら、自ら見た目を変えることはない。
  - 構造がシンプルなため、作るのも管理するのも楽。

```dart
// 「ようこそ」と書かれた、決して変わることのないウェルカムサイン
class WelcomeSign extends StatelessWidget {
  const WelcomeSign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Welcome to our Farm!');
  }
}
```

### StatefulWidget: ハイテクな電光掲示板

`StatefulWidget`は、表示内容が変わりうる、**ハイテクな電光掲示板**です。「本日の収穫卵: 53個」や「現在の気温: 25℃」など、時間やイベントによって動的に変化する情報を表示するのに使います。

この電光掲示板は、2つの部品から成り立っています。
1.  **`StatefulWidget`**: 電光掲示板の**外枠**。
2.  **`State`オブジェクト**: 掲示板の頭脳である**内部のコンピュータ**。現在の情報（卵の数など）を記憶し、表示を更新する役割を持つ。

重要なのは、**`setState()`**という命令です。これは、コンピュータについている**「表示更新ボタン」**です。農夫が新しい卵を1つ見つけたら、このボタンを押します。するとコンピュータは記憶している卵の数を1つ増やし、掲示板の表示を新しい数に更新するのです。

```mermaid
graph LR
    subgraph 電光掲示板システム
        A[掲示板の外枠<br/>(StatefulWidget)] --- B[内部コンピュータ<br/>(State Object)];
        B -- "現在の卵の数を記憶" --> C(int _eggCount);
        B -- "表示内容を組み立てる" --> D[build()メソッド];
    end
    E[農夫が卵を発見！] -- "更新ボタンを押す" --> F[setState()呼び出し];
    F -- "_eggCountを増やす" --> C;
    F -- "掲示板に再描画を命令" --> D;
```

#### サンプルコード: 卵カウンター

```dart
class EggCounter extends StatefulWidget {
  const EggCounter({Key? key}) : super(key: key);
  @override
  State<EggCounter> createState() => _EggCounterState();
}

// `_EggCounterState`が内部コンピュータの役割
class _EggCounterState extends State<EggCounter> {
  int _eggCount = 0; // コンピュータが卵の数を記憶している

  void _findNewEgg() {
    // setState()、つまり「表示更新ボタン」を押す
    setState(() {
      // 内部で卵の数を1増やす
      _eggCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('本日の収穫卵: $_eggCount 個', style: const TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: _findNewEgg, // ボタンが押されたら卵を探す
          child: const Text('新しい卵を1つ見つけた！'),
        )
      ],
    );
  }
}
```

| | StatelessWidget (看板) | StatefulWidget (電光掲示板) |
| :--- | :--- | :--- |
| **目的** | 変わらない情報を表示 | 変わりうる情報を表示 |
| **状態** | 持たない | 持つ（内部コンピュータが記憶） |
| **更新方法** | 変わらない | `setState()`ボタンで更新 |
| **例** | 農場の名前、建物の表札 | カウンター、チェックリスト、入力欄 |

---

## 2.4 BuildContextとHot Reload

### BuildContext: 部品の現在地を示すGPS

`BuildContext`は、すべての建築部品（Widget）が持っている**魔法のGPS**です。このGPSを使えば、部品は「自分が農場のどこにいるのか」を正確に知ることができます。

- **何に使うのか？**:
  - **周囲の環境を知る**: 「私がいる母屋（`Scaffold`）の壁の色は何色？それに合わせて自分の色を決めよう」(`Theme.of(context)`)
  - **他の建物への道順を知る**: 「ここから納屋（別の画面）へ移動したい」(`Navigator.of(context)`)

今は「**すべての部品が持つ、自分の場所を知るための道具**」と覚えておけばOKです。

### Hot Reload: 魔法の建築術

Flutterが「最高の農場作りツール」と言われる最大の理由が、この**ホットリロード**です。

これは、**魔法の建築術**です。例えば、母屋の壁を赤色で塗った後で、「やっぱり青色の方がいいな」と思ったとします。普通の建築なら壁を壊して作り直す必要がありますが、Flutterならコードを修正して保存するだけ。すると、**アプリを止めずに、電光掲示板のカウントもそのまま**で、壁の色だけがスッと青色に変わるのです。

この驚異的な速さのフィードバックにより、農場のデザインを試行錯誤する効率が劇的に向上します。

---

### まとめ

この章では、あなたの農場を建設するための、Flutterの基本的な考え方と道具について学びました。

- **環境構築**: 魔法のツールキット(SDK)と監査人(`doctor`)、ミニチュア模型(Emulator)を準備しました。
- **Widgetツリー**: 農場が建築部品(Widget)の階層的な設計図でできていることを理解しました。
- **Stateless/Stateful**: 部品には静的な「看板」と動的な「電光掲示板」の2種類があることを学びました。
- **Hot Reload**: 魔法の建築術で、超高速に農場をデザインできることを知りました。

次の章では、これらの部品を実際に組み合わせて、美しいレイアウトの農場を設計する方法を学んでいきます。