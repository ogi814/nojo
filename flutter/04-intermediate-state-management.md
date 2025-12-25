# Flutter教科書 - 中級編 - 1. 状態管理 (農場たとえ話・増量版)

あなたの農場も大きくなり、建物や畑、働く人々（Widget）が増えてきました。ここで一つ問題が起こります。「母屋で決まったこと（状態）を、どうやって農場の隅々にまで、効率よく伝えるか？」です。

この章では、複雑化する農場の情報を整理し、隅々まで届けるための高度な「情報伝達システム」について学びます。今回は、その中でも特に強力な**Riverpod**というシステムを導入します。

---

## 1.1 なぜ状態管理が必要なのか？ ～伝言ゲームの限界～

`setState()`は、いわば**建物内での叫び声**です。牛小屋の中で「餌の時間だ！」と叫べば、牛小屋の中には聞こえます。しかし、その声は遠くの畑で作業している人には届きません。

農場全体で共有したい情報、例えば「嵐が接近中！」という緊急速報を、`setState()`だけで伝えようとするとどうなるでしょう？
母屋の人が納屋の人に伝え、納屋の人が畑の人に伝え、畑の人が牧草地の人に伝え…という、**伝言ゲーム（プロパティドリル）**が発生します。

```mermaid
graph TD
    subgraph "伝言ゲームの問題"
        A[母屋<br/>(嵐の情報を知る)] -- "嵐が来るぞ！" --> B[納屋];
        B -- "嵐が来るらしい！" --> C[畑];
        C -- "なんか嵐が来るって！" --> D[牧草地];
        D -- "嵐…？" --> E[作業員<br/>(やっと情報を受け取る)];
    end
```
これでは情報が正確に、そして迅速に伝わりません。途中の人々は、自分に関係なくても情報を伝えなければならず、非効率です。

そこで登場するのが、Riverpodのような状態管理、すなわち**農場内一斉放送システム**です。

```mermaid
graph TD
    subgraph "一斉放送システム (Riverpod)"
        A[放送局 (Provider)<br/>「嵐が接近中！」];
        B[母屋];
        C[納屋];
        D[畑];
        E[牧草地];
        F[作業員] -- "放送を聞いて直接知る" --> A;
        G[別の作業員] -- "放送を聞いて直接知る" --> A;
    end
```
このシステムを使えば、農場のどこにいても、必要な人が直接、正確な情報をリアルタイムで受け取ることができます。

---

## 1.2 Riverpodをはじめよう ～放送システムの設置～

### インストール
まず、放送システム一式を業者（pub.dev）から取り寄せます。`pubspec.yaml`に以下を追記し、`flutter pub get`を実行します。

```yaml
dependencies:
  flutter_riverpod: ^2.0.0 # 最新のバージョンを確認
```

### `ProviderScope`: 放送アンテナの設置
次に、農場全体に放送が届くように、母屋に大きな**アンテナ (`ProviderScope`)**を設置します。これにより、農場のすべての建物、すべての作業員が放送を受信できるようになります。

```dart
// main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // アンテナを設置し、農場全体をカバーする
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
```

---

## 1.3 Providerの種類と使い方 ～多彩な放送チャンネル～

放送システムには、用途に応じて様々な**専門チャンネル (Provider)** があります。農場の作業員（Widget）は、**トランシーバー (`WidgetRef`)** を使って、これらのチャンネルにアクセスします。

### `Provider`: 変わらない情報を流す「農場ルール」チャンネル
農場の設立日や、経営理念など、一度決めたら変わらない情報を流し続けるチャンネルです。

```dart
// 農場の名前を流すチャンネル
final farmNameProvider = Provider<String>((ref) => 'リバーポッド農場');

class FarmGateSign extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トランシーバーでチャンネルを聞く
    final farmName = ref.watch(farmNameProvider);
    return Text('ようこそ、$farmName へ！');
  }
}
```
`StatelessWidget`を`ConsumerWidget`に変えることで、トランシーバー`ref`が使えるようになります。

### `StateProvider`: シンプルな情報を更新する「今日の直売所」チャンネル
「本日の特売品: トマト」や「ゲート: 開/閉」など、単純で変わりやすい情報を流すチャンネルです。

```dart
// ゲートの開閉状態を流すチャンネル (初期値: false=閉)
final gateOpenProvider = StateProvider<bool>((ref) => false);

class GateControlPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGateOpen = ref.watch(gateOpenProvider);

    return SwitchListTile(
      title: const Text('ゲートを開ける'),
      value: isGateOpen,
      onChanged: (bool newValue) {
        // 放送局に連絡して、情報を更新してもらう
        ref.read(gateOpenProvider.notifier).state = newValue;
      },
    );
  }
}
```

### `StateNotifierProvider`: 専門家が管理する「家畜の健康状態」チャンネル
これは、Riverpodで最も強力なチャンネルです。家畜の健康状態のように、複雑で重要な情報は、誰でも勝手に変更できては困ります。そこで、専門の**獣医 (`StateNotifier`)** を配置し、その人だけが情報を更新できるようにします。

1.  **獣医（`StateNotifier`）を準備する**
    - 獣医は、家畜のリスト（状態）を管理します。
    - 「新しい家畜を追加する」「病気の家畜を治療する」といった専門的な仕事（メソッド）を持っています。

```dart
// `Animal`は家畜の情報を表すクラス（名前、健康状態など）

// 獣医クラスの定義
class LivestockNotifier extends StateNotifier<List<Animal>> {
  // 最初は空のリストから
  LivestockNotifier() : super([]);

  // 新しい家畜を追加する仕事
  void addAnimal(String name) {
    final newAnimal = Animal(name: name, status: 'Healthy');
    state = [...state, newAnimal]; // 状態を更新して放送
  }
}
```

2.  **獣医を配置した専門チャンネルを開設する**

```dart
final livestockProvider = StateNotifierProvider<LivestockNotifier, List<Animal>>((ref) {
  return LivestockNotifier();
});
```

3.  **作業員がチャンネルの情報を確認する**

```dart
class LivestockList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 家畜の健康状態チャンネルを監視
    final animals = ref.watch(livestockProvider);

    return ListView.builder(
      itemCount: animals.length,
      itemBuilder: (context, index) {
        return Text('${animals[index].name}: ${animals[index].status}');
      },
    );
  }
}
```
この仕組みにより、**情報の閲覧（UI）**と**情報の更新（ビジネスロジック）**が綺麗に分離され、農場の管理が非常にしやすくなります。

### `FutureProvider`: 結果が不確かな「天気予報」チャンネル
天気予報のように、情報が届くまでに時間がかかったり、通信障害で失敗したりする可能性がある非同期の情報を扱うチャンネルです。

`when`を使うと、**「予報を取得中」「予報が届いた」「予報の取得に失敗した」**という3つの状態に応じて、表示を自動で切り替えてくれる賢い受信機が手に入ります。

```dart
// 天気予報チャンネル
final weatherProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 2)); // 予報の取得に2秒かかる
  return '快晴';
  // throw '衛星通信エラー'; // 失敗した場合
});

class WeatherDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeather = ref.watch(weatherProvider);

    return asyncWeather.when(
      data: (weather) => Text('今日の天気: $weather'), // 予報が届いた
      loading: () => const CircularProgressIndicator(), // 取得中
      error: (err, stack) => Text('エラー: $err'), // 失敗した
    );
  }
}
```

---

## 1.4 `ref.watch` vs `ref.read` ～トランシーバーの使い方～

トランシーバー(`ref`)の2つの使い方、`watch`と`read`の区別は、農場を効率的に運営する上で極めて重要です。

- **`ref.watch()` (常時監視リスニング)**
  - **使い方**: 畑の見張り番が、天気予報チャンネルを**常に聞き続けている**イメージ。
  - **動作**: 放送内容（状態）に変化があれば、**即座に反応**して行動（Widgetの再描画）を起こす。「雨が降る」と聞こえた瞬間に、シートをかけ始める。
  - **目的**: **最新の情報を常に画面に表示し続ける**こと。

- **`ref.read()` (単発での問い合わせ)**
  - **使い方**: 卵の収穫数を報告する作業員が、報告ボタンを押した瞬間にだけ、トランシーバーで**一度だけ放送局に連絡する**イメージ。
  - **動作**: 放送内容が変わっても、普段は気にしない。行動を起こす時だけ、その瞬間の情報を取得・利用する。
  - **目的**: **情報を更新する**、**何らかのアクションを起こす**こと。

| トランシーバー | 使い方 | 動作 | 目的 |
| :--- | :--- | :--- | :--- |
| `ref.watch()` | `build`メソッド内 | 常にチャンネルを聞き、変化があれば再行動 | **表示** |
| `ref.read()` | `onPressed`などの中 | ボタンを押した時だけ、一度問い合わせる | **行動** |

---

### まとめ

この章では、あなたの農場に、Riverpodという強力な情報伝達システムを導入しました。

- **なぜ必要か**: 伝言ゲームの非効率さをなくし、情報を正確・迅速に伝えるため。
- **基本設定**: 放送システム(`flutter_riverpod`)を導入し、アンテナ(`ProviderScope`)を立てた。
- **チャンネル**: 用途に応じて`Provider`(ルール)、`StateProvider`(直売所)、`StateNotifierProvider`(専門家)、`FutureProvider`(天気予報)を使い分ける。
- **`watch`と`read`**: 「常時監視」と「単発問い合わせ」という、トランシーバーの正しい使い方を学んだ。

この放送システムを使いこなせば、あなたの農場がどれだけ大きく、複雑になっても、情報をきれいに整理し、スムーズに運営していくことができるでしょう。