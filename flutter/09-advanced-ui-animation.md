# Flutter教科書 - 上級編 - 1. 高度なUIとアニメーション (農場たとえ話・増量版)

あなたの農場は、機能的には非常に優れたものになりました。しかし、訪れる人々をさらに魅了するには、見た目の美しさや、心地よい動きの演出が重要になります。この章では、農場を「ただ機能的な場所」から「感動を与える空間」へと昇華させるための、高度なUIとアニメーション技術を学びます。

---

## 1.1 `CustomPainter`: あなただけの壁画を描く

これまでのWidgetは、Flutterが用意してくれた建築部品でした。`CustomPainter`は、あなた自身が**絵筆を握り、母屋の壁に自由な絵（壁画）を描く**ための道具です。円、四角、線、ベジェ曲線などを駆使して、既存のWidgetでは表現できない、完全にオリジナルのUIを創造できます。

### 使い方
1.  `CustomPainter`を継承した、あなただけの画家クラスを作ります。
2.  `paint`メソッドの中に、壁画の描き方を記述します。`canvas`がキャンバス、`paint`が絵の具や筆の種類です。
3.  `shouldRepaint`メソッドで、どのような場合に壁画を再描画するかを決定します。

```dart
// 農場のロゴを描く画家
class FarmLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // 農場の山を表現するパス
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 壁画を表示する
CustomPaint(
  size: const Size(200, 100),
  painter: FarmLogoPainter(),
)
```
`CustomPainter`は、グラフ、チャート、ゲームのUIなど、その可能性は無限大です。

---

## 1.2 暗黙的アニメーション ～ひとりでに動く仕掛け～

Flutterには、プロパティを変えるだけで、**自動的にアニメーションしてくれる賢い建築部品**が用意されています。これらを**暗黙的アニメーションWidget (Implicitly Animated Widgets)** と呼びます。

代表的なものに`AnimatedContainer`があります。これは、**魔法の伸縮式フェンス**のようなものです。幅(`width`)や色(`color`)を変更するだけで、指定した時間(`duration`)をかけて、にゅるっと滑らかに変化します。

```dart
// bool _isExpanded = false; // StatefulWidgetのStateで管理

AnimatedContainer(
  duration: const Duration(seconds: 1), // 1秒かけて変化
  curve: Curves.easeInOut, // 変化の緩急をつける
  width: _isExpanded ? 300 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  child: const Center(child: Text('伸縮フェンス')),
)

// ボタンなどで _isExpanded を setState() で切り替えるとアニメーションが発動
```
`AnimatedOpacity`（透明度が変わる）、`AnimatedPositioned`（位置が変わる）など、たくさんの仲間がいます。簡単なアニメーションなら、これらを使うのが最も手軽で効率的です。

---

## 1.3 明示的アニメーション ～からくり人形の設計～

より複雑で、再生・停止・逆再生などを自由にコントロールしたいアニメーションは、**明示的アニメーション (Explicit Animations)** で実装します。これは、**精巧なからくり人形を設計する**ようなものです。

### `AnimationController`と`Tween`
- **`AnimationController` (人形の動力源)**: アニメーションの進行を管理するタイマーです。0.0 (開始) から 1.0 (終了) までの値を、指定した時間で生成します。
- **`Tween` (動きの変換装置)**: `AnimationController`が生成する0.0〜1.0の値を、具体的なプロパティ値（例: 「サイズを100から200へ」「色を赤から青へ」）に変換します。
- **`AnimatedBuilder` (人形の部品)**: `AnimationController`の動きに合わせて、UIを効率的に再描画します。

例として、農場の風車が回転するアニメーションを作ってみましょう。

```dart
class Windmill extends StatefulWidget {
  // ...
}

class _WindmillState extends State<Windmill> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1. 動力源を準備 (5秒で1回転)
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(); // 繰り返し回転させる
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 2. 動力源の値を、回転角度(0.0〜2π)に変換して風車を回す
        return Transform.rotate(
          angle: _controller.value * 2.0 * math.pi,
          child: child,
        );
      },
      child: const Icon(Icons.settings, size: 100), // 風車のアイコン
    );
  }
}
```
明示的アニメーションは習得が少し大変ですが、一度マスターすれば、ユーザーをあっと言わせるような、あらゆる動きを表現できます。

---

## 1.4 HeroアニメーションとLottie

### Hero: 魔法の瞬間移動
`Hero` Widgetは、画面遷移時に、**同じ要素が魔法のように変形しながら瞬間移動する**アニメーションを簡単に実装できるツールです。

例えば、農場の一覧画面にある小さな家畜の写真（`Image`）をタップした時、その写真がスーッと拡大しながら詳細画面のメイン画像に変化する、といった演出が可能です。

1.  移動元のWidgetと移動先のWidgetを、同じ`tag`を持つ`Hero` Widgetで囲むだけです。

```dart
// 一覧画面
Hero(
  tag: 'animal_photo_007',
  child: Image.asset('.../animal_007_thumbnail.png'),
)

// 詳細画面
Hero(
  tag: 'animal_photo_007',
  child: Image.asset('.../animal_007_large.png'),
)
```
Flutterが自動で2つの画面間のアニメーションを補間してくれます。これにより、ユーザーは視覚的な繋がりを感じ、アプリ内の位置関係を直感的に理解できます。

### Lottie: プロ製アニメーションの再生
`lottie`パッケージを使えば、デザイナーがAdobe After Effectsなどで作成した、**プロ品質のベクターアニメーション**を、Flutterアプリ内で簡単に再生できます。

これは、**専門のアニメーターが作ったアニメーション映画のフィルムを、農場の映写機で上映する**ようなものです。自前で複雑なアニメーションを組むことなく、非常にリッチな表現が可能になります。

1.  `lottie`パッケージを追加します。
2.  デザイナーから`json`形式のアニメーションファイルをもらいます。
3.  `Lottie.asset()`や`Lottie.network()`で表示します。

```dart
import 'package:lottie/lottie.dart';

// ダウンロードしたアニメーションを表示
Lottie.asset('assets/animations/cow_eating.json')
```

---

### まとめ

この章では、あなたの農場に生命を吹き込むための、高度なUIとアニメーション技術を学びました。

- **`CustomPainter` (壁画)**: 完全に自由な発想で、独自のUIを描画する。
- **暗黙的アニメーション (伸縮フェンス)**: プロパティを変えるだけで、簡単に滑らかなアニメーションを実現する。
- **明示的アニメーション (からくり人形)**: `AnimationController`を使い、再生・停止などを自在に操る、精巧なアニメーションを設計する。
- **Hero (瞬間移動)**: 画面遷移を、視覚的に楽しく、分かりやすく演出する。
- **Lottie (アニメ映画)**: プロが作った高品質なアニメーションを、簡単にアプリに組み込む。

これらの技術は、アプリケーションの「使いやすさ」や「楽しさ」といった、ユーザー体験（UX）を劇的に向上させます。機能だけでなく、心地よさも追求することが、多くの人に愛されるアプリを作る秘訣です。
