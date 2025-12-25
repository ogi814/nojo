# Flutter教科書 - 初級編 - 3. レイアウト & UI (農場たとえ話・増量版)

建築部品（Widget）の種類と性質を学んだあなた。いよいよ、それらを組み合わせて、自分だけの農場を美しく、機能的にレイアウトしていきます。この章は、Flutter開発で最もクリエイティブで楽しい部分です。

---

## 3.1 基本的なレイアウトWidget ～区画整理と配置の技術～

農場に建物を建てたり畑を作ったりするには、まず土地の区画整理が必要です。Flutterには、部品（Widget）を自在に配置するための、強力な区画整理ツールが揃っています。

### `Container`: 万能な一区画

`Container`は、**自由自在に装飾できる、一つの畑の区画**のようなものです。この区画の中に作物（`child` Widget）を一つ植えることができ、区画そのものを様々にデザインできます。

- **農場でのプロパティ解説**:
  - `child`: 区画の中に植える作物や設置物。
  - `padding`: **畝（うね）と作物の間のスペース**。区画の縁と中身との間に余白を作ります。
  - `margin`: **区画と隣の区画を隔てる道**。区画の外側に余白を作ります。
  - `decoration`: **区画そのものの装飾**。
    - `color`: 土の色を変える。
    - `border`: 区画の周りに柵を立てる。
    - `borderRadius`: 柵の角を丸くする。
    - `boxShadow`: 区画を少し盛り土して、地面に影を作る。

```dart
Container(
  // 道幅を確保 (外側の余白)
  margin: const EdgeInsets.all(10.0),
  // 畝と作物のスペースを確保 (内側の余白)
  padding: const EdgeInsets.all(16.0),
  // 区画の装飾
  decoration: BoxDecoration(
    // 土の色を青くする (colorはdecorationの中で指定)
    color: Colors.blue,
    // 黒い柵を立てる
    border: Border.all(color: Colors.black, width: 3),
    // 柵の角を丸くする
    borderRadius: BorderRadius.circular(12),
    // 盛り土して影を作る
    boxShadow: [
      BoxShadow(color: Colors.grey, blurRadius: 7, offset: const Offset(0, 3)),
    ],
  ),
  // 作物を植える
  child: const Text(
    '立派な区画',
    style: TextStyle(color: Colors.white, fontSize: 20),
  ),
)
```

### `Row` と `Column`: 区画の整列

複数の区画や建物を、**横一列 (`Row`)** または **縦一列 (`Column`)** にきれいに並べるためのツールです。

- `mainAxisAlignment`: **並べる方向**（主軸）に、どうやって区画を配置するか。
  - `spaceBetween`: 列の両端に区画を配置し、残りは等間隔に並べる。
  - `spaceAround`: 各区画が左右に同じだけの空間を持つように並べる。
  - `center`: 列の中央にすべての区画を集める。
- `crossAxisAlignment`: **並べる方向と直角の方向**（交差軸）に、どうやって配置するか。`Row`なら上下、`Column`なら左右の配置方法。

```dart
// 納屋、母屋、サイロを横一列に並べる
Row(
  // 均等な間隔を空けて配置
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: const <Widget>[
    Icon(Icons.house_siding, size: 50), // 納屋
    Icon(Icons.home, size: 50),         // 母屋
    Icon(Icons.silo, size: 50),         // サイロ
  ],
)
```

#### `Expanded`: 伸縮自在な魔法の牧草地
`Row`や`Column`の中で、特定の区画に「余った土地をすべて使って広がってほしい」と頼むのが`Expanded`です。これは**伸縮自在な魔法の牧草地**に例えられます。

```dart
Row(
  children: <Widget>[
    Icon(Icons.house_siding, size: 50), // 納屋
    // 魔法の牧草地。余ったスペースすべてに広がる。
    Expanded(
      child: Container(
        color: Colors.green,
        child: const Center(child: Text('牧草地')),
      ),
    ),
    Icon(Icons.silo, size: 50), // サイロ
  ],
)
```

### `Stack`: レイヤーを重ねる建築術

`Stack`は、**地面に地図を広げ、その上に駒を置いていく**ように、部品を重ねて配置する技術です。例えば、農場の風景写真の上に、動物がいる場所をアイコンで示したい時に使います。

`Positioned`を使うと、下のレイヤーに対する駒の正確な位置を指定できます。

```dart
Stack(
  alignment: Alignment.center,
  children: <Widget>[
    // 1層目: 背景となる農場の風景写真
    Image.asset('assets/images/farm_background.png'),
    
    // 2層目: 牛のアイコンを特定の場所に配置
    Positioned(
      top: 50,
      left: 30,
      child: Icon(Icons.pets, color: Colors.white, size: 40),
    ),

    // 3層目: 中央に農場の名前を表示
    const Text('My Farm', style: TextStyle(fontSize: 30, color: Colors.white)),
  ],
)
```

### `ListView`: 長大な畑と効率的な観察

`ListView`は、画面に収まりきらないほど長い、**トウモロコシ畑のようなリスト**を作るのに使います。トラクター（スクロール）に乗って、畑全体を見て回ることができます。

- **`ListView.builder()`**: **超効率的な作付け方法**。1000本のトウモロコシを一度にすべて植えるのではなく、トラクターから見える範囲の10本だけを植え（描画し）、通り過ぎたものは抜き、新しく見える範囲のものを植えていきます。これにより、農場全体のリソース（メモリ）を大幅に節約できます。

```dart
// 100区画分の畑のリスト
ListView.builder(
  itemCount: 100, // 畑の区画は100個
  itemBuilder: (context, index) {
    // index番目の区画の見た目を定義
    return ListTile(
      leading: Icon(Icons.grass),
      title: Text('${index + 1}番目の畑'),
    );
  },
)
```

---

## 3.2 基本的なUI Widget ～看板や装飾品～

レイアウトが決まったら、次は農場を彩る具体的な装飾品を配置していきます。

- **`Text` と `TextStyle`**: **看板に文字を書く**ための道具です。`TextStyle`は、文字のフォント、大きさ、色、太さを決めるための**カリグラフィーセット**です。
- **`Image`**: **農場の写真**です。
  - `Image.asset()`: 農場の倉庫（`assets`フォルダ）に保管してある写真を飾ります。倉庫の場所は、農場の登記簿（`pubspec.yaml`）に記載しておく必要があります。
  - `Image.network()`: よその農場のライブカメラ映像（URL）を映し出します。
- **`Icon` と `IconButton`**: **農場で使う絵文字やシンボル**です。`Icons.pets`で動物エリアを示したりできます。`IconButton`は、押すことができるシンボルで、例えば牛のアイコンを押すと鳴き声が聞こえる、といった仕掛けを作れます。

---

## 3.3 テーマとスタイリング ～農場の公式デザインガイド～

農場に立てる看板や建物の色、文字のスタイルを一つ一つ決めていくのは大変です。そこで、**農場の公式デザインガイド (`ThemeData`)** を作ります。

`MaterialApp`（農場のブランドデザイン）の`theme`プロパティで、このガイドを定義します。

```dart
// main.dart
MaterialApp(
  theme: ThemeData(
    // 基調となる色: "納屋の赤色"
    primarySwatch: Colors.red,
    // 看板の基本フォント: "田舎風フォント"
    fontFamily: 'CountryFont',
    // ボタンのデザイン
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown, // ボタンは茶色
      ),
    ),
  ),
  // ...
)
```

こうすることで、個々の建物や看板を作る際に、いちいち色を悩む必要がなくなります。「デザインガイド(`Theme.of(context)`)に従って作ってください」と指示するだけで、農場全体に統一感が生まれます。

---

## 3.4 レスポンシブデザインの基本 ～土地の広さに合わせた設計～

あなたの農場は、小さなスマホの画面かもしれませんし、大きなタブレットの画面かもしれません。**土地の広さに合わせてレイアウトを自動で変える**のが、レスポンシブデザインです。

- **`MediaQuery`**: **土地の測量士**。現在の土地（画面）の正確な幅と高さを教えてくれます。
- **`LayoutBuilder`**: **区画の測量士**。親から与えられた区画のサイズを教えてくれます。

```dart
// 測量士を呼ぶ
final double landWidth = MediaQuery.of(context).size.width;

if (landWidth > 600) {
  // 土地が広い場合: 納屋と母屋を横に並べる (Row)
  return buildWideLayout(); 
} else {
  // 土地が狭い場合: 納屋と母屋を縦に並べる (Column)
  return buildNarrowLayout();
}
```

---

### まとめ

この章では、農場の区画を整理し、美しく装飾するための様々な技術を学びました。

- **レイアウト**: `Container`(区画), `Row`/`Column`(整列), `Stack`(重ねる), `ListView`(長大な畑)を使い、部品を自在に配置しました。
- **UI部品**: `Text`(看板), `Image`(写真), `Icon`(シンボル)など、農場を彩る装飾品の使い方を学びました。
- **スタイリング**: `Theme`というデザインガイドで、農場全体の見た目に統一感を持たせました。
- **レスポンシブ**: `MediaQuery`で土地の広さを測り、レイアウトを自動で変える初歩を学びました。

これらの知識を組み合わせれば、あなたの思い描く素敵な農場（アプリ）が、もう目の前に見えてきているはずです。