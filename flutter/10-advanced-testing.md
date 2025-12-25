# Flutter教科書 - 上級編 - 2. テスト (農場たとえ話・増量版)

あなたの農場は、多機能で、見た目も美しくなりました。しかし、本当に信頼できる農場であるためには、すべての機能が正しく、そして安定して動き続けることを保証しなければなりません。この章では、農場の品質を最高レベルに保つための**「品質管理と衛生検査（テスト）」**の技術を学びます。

---

## 2.1 なぜテストが必要なのか？ ～安定経営のための品質管理～

- **バグの早期発見**: 新しい機械を導入したことで、古い井戸のポンプが動かなくなる、といった予期せぬ不具合（バグ）を、利用者が気づく前に発見できます。
- **リファクタリングの恐怖からの解放**: 農場の水路（コード）を、より効率的なものに改修したいと考えたとします。テストがなければ、「この改修で、どこか別の場所に水が供給されなくなるのではないか？」という恐怖で、手が出せません。自動化されたテストがあれば、改修後もすべての場所に水が行き渡ることを瞬時に確認でき、安心して改善に取り組めます。
- **品質の保証と信頼**: 「うちの農場の作物は、すべて厳格な品質検査をクリアしています」と胸を張って言えるようになります。

---

## 2.2 3種類のテスト ～土壌・機械・総合検査～

Flutterのテストは、その対象範囲によって、大きく3種類に分けられます。

| テストの種類 | 農場の例え | 検査対象 | 特徴 |
| :--- | :--- | :--- | :--- |
| **単体テスト (Unit Test)** | **土壌成分の検査** | ・単一の関数やクラス<br>・ビジネスロジック | ・高速に実行できる<br>・UIや外部依存から完全に独立 |
| **ウィジェットテスト (Widget Test)** | **農機具の動作テスト** | ・単一のWidget<br>・UIの表示とインタラクション | ・単体テストよりは遅い<br>・仮想環境でUIをテスト |
| **統合テスト (Integration Test)** | **農場全体の収穫シミュレーション** | ・アプリ全体の機能<br>・複数の画面やサービス連携 | ・最も遅いが、最も信頼性が高い<br>・実機やエミュレータで実行 |

### `test`パッケージの導入
これらすべてのテストは、`flutter_test`（Flutter SDKに同梱）と`test`というパッケージを基盤としています。`pubspec.yaml`の`dev_dependencies`に`test`が含まれていることを確認してください。テストコードは、プロジェクトルートの`test`フォルダに配置するのが慣例です。

---

## 2.3 単体テスト (Unit Test) ～土壌成分の検査～

単体テストは、特定の機能を持つ最小単位（関数やクラス）が、正しく動作するかを検証します。例えば、**「この土壌（関数）は、与えられた肥料（引数）に対して、期待される栄養価（戻り値）を返すか？」**を検査するようなものです。

例として、以前に作成した`CounterNotifier`（家畜の数を数える専門家）をテストしてみましょう。

```dart
// test/counter_notifier_test.dart
import 'package:test/test.dart';
import 'package:my_farm_app/riverpod/counter_notifier.dart'; // テスト対象のファイルをインポート

void main() {
  // `group`で関連するテストをまとめる
  group('CounterNotifierのテスト', () {
    
    test('初期値は0であるべき', () {
      // 1. 検査対象を用意する
      final notifier = CounterNotifier();
      // 2. 期待される結果と比較する
      expect(notifier.state, 0);
    });

    test('incrementメソッドを呼ぶと、状態が1増えるべき', () {
      final notifier = CounterNotifier();
      notifier.increment();
      expect(notifier.state, 1);
    });

    test('decrementメソッドを呼ぶと、状態が1減るべき', () {
      final notifier = CounterNotifier();
      notifier.decrement();
      expect(notifier.state, -1);
    });
  });
}
```
`test`関数でテストケースを定義し、`expect(actual, matcher)`で、実際の値が期待通りの値と一致するかを検証します。UIも外部APIも関係ないため、非常に高速に実行できます。

---

## 2.4 ウィジェットテスト (Widget Test) ～農機具の動作テスト～

ウィジェットテストは、特定の農機具（Widget）が、**正しく表示され、ボタンを押したら意図通りに動くか**をテストします。

`flutter_test`パッケージが提供する`testWidgets`関数と`WidgetTester`ユーティリティを使います。`WidgetTester`は、仮想の画面上でWidgetをタップしたり、テキストを読み取ったりできる、万能なテスト用ロボットアームです。

例として、カウンター表示とボタンを持つ`CounterWidget`をテストします。

```dart
// test/counter_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_farm_app/widgets/counter_widget.dart';

void main() {
  testWidgets('CounterWidgetのテスト', (WidgetTester tester) async {
    // 1. テスト対象のWidgetを仮想画面に表示させる
    await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

    // 2. 初期状態の検証: 「0」というテキストが1つだけ表示されているか？
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 3. アクションの実行: 「+」ボタンをタップする
    await tester.tap(find.byIcon(Icons.add));
    
    // 4. 再描画を待つ
    await tester.pump();

    // 5. 結果の検証: 「0」が消え、「1」が表示されているか？
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```
`find`で特定のWidgetを見つけ、`tester.tap()`で操作し、`expect`で結果を検証する、という流れが基本です。

---

## 2.5 統合テスト (Integration Test) ～農場全体の収穫シミュレーション～

統合テストは、**実際に種をまき、水やりをし、収穫して、市場に出荷するまでの一連の流れ（ユーザーシナリオ）**が、すべて正しく機能するかをテストします。

`integration_test`パッケージを導入し、`integration_test`フォルダにテストファイルを作成します。コードの書き方はウィジェットテストと非常によく似ていますが、これは**実機やエミュレータ上で、実際のアプリを動かしながら**実行されます。

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_farm_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('家畜の登録から詳細画面への遷移テスト', (WidgetTester tester) async {
    // 1. アプリを起動
    app.main();
    await tester.pumpAndSettle(); // アニメーションなどが終わるまで待つ

    // 2. フォームに名前を入力
    await tester.enterText(find.byType(TextFormField).first, 'ベッシー');
    
    // 3. 登録ボタンをタップ
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 4. 登録された「ベッシー」がリストに表示されていることを確認
    expect(find.text('ベッシー'), findsOneWidget);

    // 5. 「ベッシー」をタップして詳細画面へ遷移
    await tester.tap(find.text('ベッシー'));
    await tester.pumpAndSettle();

    // 6. 詳細画面に「ベッシー」の名前が表示されていることを確認
    expect(find.text('詳細: ベッシー'), findsOneWidget);
  });
}
```
統合テストは実行に時間がかかりますが、ログインから商品購入まで、といったクリティカルな機能が、様々な部品（DB、API、UI）と連携して正しく動作することを保証できる、最も信頼性の高いテストです。

---

### まとめ

この章では、農場の品質を保証するための3種類のテストについて学びました。

- **単体テスト (土壌検査)**: ロジックの最小単位を高速に検証する。
- **ウィジェットテスト (農機具テスト)**: 個々のUI部品が正しく表示・動作するかを検証する。
- **統合テスト (総合シミュレーション)**: アプリ全体の機能が、ユーザーの操作通りに正しく連携して動くかを検証する。

テストを書くことは、未来の自分への投資です。堅牢なテストスイートは、あなたの農場（アプリ）が、どんな嵐（仕様変更やリファクタリング）にも耐え、常に高品質な作物（価値）をユーザーに提供し続けるための、最強の保険となるでしょう。
