# Flutter教科書 - 中級編 - 2. 画面遷移 (農場たとえ話・増量版)

あなたの農場には、母屋、納屋、畑、牧草地など、様々なエリア（画面）ができてきました。この章では、これらのエリア間をスムーズに移動するための「道と案内標識」の作り方を学びます。Flutterにおける画面遷移の技術です。

---

## 2.1 基本的な画面遷移 ～隣の建物への移動～

`Navigator.push`は、最も基本的な移動方法です。これは、**「あの納屋まで歩いて行って」**と、目的地を直接指し示すようなものです。

```dart
// 納屋(BarnScreen)へ移動する
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const BarnScreen()),
);
```

しかし、農場が広大になり、建物が増えてくると、この方法は問題を引き起こします。
- **道順が複雑になる**: 「納屋の裏を抜けて、大きな木の先にあるサイロへ…」のように、移動のロジックがUIコードの中に散らばってしまいます。
- **改築に弱い**: 大きな木を伐採したら、その道順は使えなくなります。UIの変更が、移動ロジックを壊してしまうのです。

---

## 2.2 名前付きルート ～住所録の作成～

そこで登場するのが**名前付きルート**です。これは、農場のすべての建物に**「住所」**を割り振るようなものです。「母屋: `/home`」「納屋: `/barn`」のように。

`MaterialApp`で住所録を定義しておけば、移動する際は「`/barn`へ行って」と住所を伝えるだけです。

```dart
// main.dart: 住所録の定義
MaterialApp(
  initialRoute: '/home',
  routes: {
    '/home': (context) => const HomeScreen(),
    '/barn': (context) => const BarnScreen(),
  },
)

// 移動の指示
Navigator.pushNamed(context, '/barn');
```
これにより、UIから道順の詳細が分離され、少し管理がしやすくなりました。しかし、この方法にも「特定の牛（ID: 5）の詳細ページに行きたい」「移動時に『餌の袋』という荷物を持っていきたい」といった、より複雑な要求に応えるのが難しいという弱点があります。

---

## 2.3 GoRouter ～農場専用GPSナビゲーションシステム～

`GoRouter`は、これらの問題をすべて解決する、近代的な**農場専用GPSナビゲーションシステム**です。農場内のすべての道と住所を**一箇所で集中管理**し、複雑な移動も簡単な指示で行えるようになります。

### 導入: GPSシステムの設置
`pubspec.yaml`に`go_router`を追加し、`flutter pub get`を実行します。

### 設定: 農場全体の地図の作成
まず、農場全体の地図（ルート設定）を1つのファイルに作成します。

```dart
// router.dart
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  // 最初の場所
  initialLocation: '/home',
  // 地図情報
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/barn',
      builder: (context, state) => const BarnScreen(),
    ),
    // :id の部分は「牛の耳標番号」などの可変な情報が入る
    GoRoute(
      path: '/animal/:id',
      builder: (context, state) {
        // URLから耳標番号を取得
        final String animalId = state.params['id']!;
        return AnimalDetailScreen(animalId: animalId);
      },
    ),
  ],
);
```

そして、`MaterialApp`に、このGPSナビシステムを使うよう設定します。

```dart
// main.dart
MaterialApp.router(
  routerConfig: router, // 我々の農場では、このGPSを使います
  title: 'GoRouter Farm',
);
```

### 使い方: GPSに行き先を告げる

`GoRouter`の使い方は非常にシンプルです。`context`からGPSを呼び出し、行き先の住所を告げるだけです。

- **単純な移動**: 「納屋へ行って」
  ```dart
  context.go('/barn');
  ```

- **パラメータ付きの移動**: 「耳標番号'007'の牛のところへ行って」
  ```dart
  context.go('/animal/007');
  ```

- **戻る**: 「一つ前の場所へ戻って」
  ```dart
  context.pop();
  ```

### なぜGoRouterが優れているのか？

- **一元管理**: 農場のすべての道と住所が、地図ファイル（`GoRouter`の設定）に集約されているため、見通しが良く、変更も容易です。
- **型安全な引数渡し**: `extra`パラメータを使えば、次の画面にオブジェクトなどの複雑な荷物を安全に渡すことができます。
- **Web対応**: ブラウザのアドレスバーと完全に連携し、ディープリンク（特定のページに直接アクセスすること）も簡単に実現できます。

```mermaid
graph TD
    subgraph GoRouter: GPSナビシステム
        A[一元管理された地図]
        B[UI (ボタンなど)] -- "「/animal/007」へ行け" --> C[context.go()];
        C -- 地図を参照 --> A;
        A -- 最適な道順を計算 --> D[AnimalDetailScreen (ID: 007)];
    end
```

---

### まとめ

この章では、農場内の移動手段が、時代と共に進化していく様子を学びました。

- **`Navigator.push` (徒歩)**: シンプルだが、農場が大きくなると道順が複雑になり管理が大変。
- **名前付きルート (住所録)**: 建物に住所を割り振ることで、少し管理が楽になった。
- **`GoRouter` (GPSナビ)**: すべての道と住所を地図として一元管理し、「どこへでも、どんな荷物を持ってでも」簡単かつ安全に移動できる現代的な解決策。

大規模で複雑な農場（アプリケーション）を建設・運営していく上で、`GoRouter`のような優れたナビゲーションシステムは、もはや不可欠なインフラと言えるでしょう。
