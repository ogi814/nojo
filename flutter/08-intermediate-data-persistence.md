# Flutter教科書 - 中級編 - 5. データ保存 (農場たとえ話・増量版)

農場の運営記録は非常に重要です。アプリを閉じても消えてほしくない情報、例えば「農場の各種設定」や「過去の全収穫記録」などを、きちんと保管しておく必要があります。この章では、様々な種類のデータを永続的に保存するための「記録・保管術」を学びます。

---

## 5.1 3つの記録保管術

農場で扱う記録には、その性質に応じていくつかの保管方法があります。

| 保管方法 | 農場の例え | 特徴 | 主な用途 |
| :--- | :--- | :--- | :--- |
| **SharedPreferences** | **机の上の付箋・メモ帳** | ・手軽で高速<br>・単純なキーと値のペアのみ<br>・複雑なデータは苦手 | ・ダークモード設定<br>・ユーザー名<br>・通知のON/OFF |
| **SQLite (`sqflite`)** | **巨大なスチール製ファイリングキャビネット** | ・大量の構造化データを扱える<br>・パワフルで信頼性が高い<br>・SQLという専門言語が必要 | ・全取引履歴<br>・家畜の血統データ<br>・詳細な日々の作業ログ |
| **Hive / Drift** | **優秀な図書館司書・データベースアシスタント** | ・SQLiteの力を、より簡単な言葉(Dart)で引き出せる<br>・高速で使いやすい<br>・型安全でミスが少ない | SQLiteと同様の用途だが、より開発者フレンドリー |

この章では、これら3つの使い方を順に見ていきましょう。

---

## 5.2 SharedPreferences ～机の上の付箋～

`SharedPreferences`は、最も手軽なデータ保存方法です。机の上の付箋に「BGM: ON」と書いて貼っておくようなイメージです。

### 使い方
1.  `shared_preferences` パッケージを `pubspec.yaml` に追加します。
2.  `getInstance()`で、自分の机のインスタンスを取得します。
3.  `setBool()`, `setString()`などで付箋を貼り、`getBool()`, `getString()`で内容を読み取ります。

```dart
import 'package:shared_preferences/shared_preferences.dart';

// 付箋を貼る (データの保存)
Future<void> saveDarkMode(bool isDarkMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', isDarkMode);
}

// 付箋を読む (データの読み込み)
Future<bool> loadDarkMode() async {
  final prefs = await SharedPreferences.getInstance();
  // 'isDarkMode'という付箋がなければ、デフォルトでfalse(OFF)とみなす
  return prefs.getBool('isDarkMode') ?? false;
}
```
`Riverpod`と組み合わせることで、アプリ起動時に設定を読み込み、`StateNotifierProvider`などで状態を管理するのが一般的なパターンです。

---

## 5.3 sqflite ～巨大なファイリングキャビネット～

`sqflite`は、リレーショナルデータベースであるSQLiteをFlutterで使うためのパッケージです。これは、農場のすべての記録を、体系的に整理・保管するための**巨大なファイリングキャビネット**です。

- **データベース**: ファイリングキャビネット全体。
- **テーブル**: 「収穫記録」「家畜台帳」といった、特定のテーマの引き出し。
- **カラム**: 「日付」「品目」「収穫量」といった、引き出しの中の仕切り（列）。
- **レコード**: 一回一回の記録（行）。

### 使い方
`sqflite`の操作には、**SQL (Structured Query Language)** という、ファイリングキャビネットを操作するための専門言語の知識が必要です。

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 1. キャビネット(DB)を開き、引き出し(Table)がなければ作る
Future<Database> openFarmDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'farm_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE harvests(id INTEGER PRIMARY KEY, crop TEXT, quantity REAL, date TEXT)',
      );
    },
    version: 1,
  );
}

// 2. 新しい収穫記録を追加する (SQLのINSERT文)
Future<void> insertHarvest(Harvest harvest) async {
  final db = await openFarmDatabase();
  await db.insert('harvests', harvest.toMap());
}

// 3. すべての収穫記録を取得する (SQLのSELECT文)
Future<List<Harvest>> getAllHarvests() async {
  final db = await openFarmDatabase();
  final List<Map<String, dynamic>> maps = await db.query('harvests');
  // ... MapのリストをHarvestオブジェクトのリストに変換する処理 ...
}
```
`sqflite`は非常にパワフルですが、SQLを文字列として書く必要があり、タイプミスがエラーに直結するなど、取り扱いが少し難しい側面もあります。

---

## 5.4 Drift ～優秀なデータベースアシスタント～

そこで登場するのが`Drift`（旧Moor）です。`Drift`は、**SQLを知らないあなたに代わって、ファイリングキャビネットの操作を完璧にこなしてくれる優秀なアシスタント**です。

あなたはアシスタントに、SQLではなくDartという普段使っている言葉で「こういう構造の引き出しを作って」「この条件に合う記録を探してきて」と指示するだけです。

### 使い方
1.  `drift`, `sqlite3_flutter_libs`, `path` パッケージを `dependencies` に、`drift_dev`, `build_runner` を `dev_dependencies` に追加します。
2.  **アシスタントへの指示書**をDartで書きます。

```dart
// database.dart
import 'package:drift/drift.dart';

// ① 引き出し(テーブル)の構造をDartのクラスで定義
class Harvests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get crop => text()();
  RealColumn get quantity => real()();
  DateTimeColumn get date => dateTime()();
}

// ② どの引き出しを使うかをアシスタントに教える
@DriftDatabase(tables: [Harvests])
class AppDatabase extends _$AppDatabase {
  // ... データベース接続のコード ...
}
```
3.  ターミナルで `flutter pub run build_runner build` を実行すると、Driftがこの指示書を元に、アシスタントの具体的な作業コード（`database.g.dart`）を**自動生成**します。
4.  アシスタントに作業を依頼します。

```dart
// データベースのインスタンスを取得
final database = AppDatabase();

// 新しい収穫記録を追加する
Future<void> addHarvest(Harvest harvest) {
  return database.into(database.harvests).insert(harvest);
}

// すべての収穫記録を取得する
Future<List<Harvest>> getAllHarvests() {
  return database.select(database.harvests).get();
}

// 特定の品目の記録だけを取得する
Future<List<Harvest>> getTomatoHarvests() {
  return (database.select(database.harvests)..where((tbl) => tbl.crop.equals('トマト'))).get();
}
```
SQLを直接書く必要がなくなり、すべてが型安全なDartのコードで完結します。アシスタントがタイプミスを防いでくれるため、非常に安全かつ高速に開発を進めることができます。

---

### まとめ

この章では、アプリのデータを永続化するための3つの保管術を学びました。

- **SharedPreferences (付箋)**: 簡単な設定値の保存に最適。
- **sqflite (ファイリングキャビネット)**: 大量の構造化データを扱うためのパワフルな選択肢だが、SQLの知識が必要。
- **Drift (データベースアシスタント)**: `sqflite`の力を、型安全でモダンなDartのコードで引き出せる、現代的で推奨されるアプローチ。

どの保管術を選ぶかは、あなたの農場（アプリ）で扱うデータの種類と量によって決まります。それぞれの長所と短所を理解し、適切に使い分けることが、優れたアプリケーション開発の鍵となります。
