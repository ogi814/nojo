// Driftパッケージを利用するために必要な部品をインポートします。
import 'package:drift/drift.dart';
// データベースファイルをデバイスのどこに保存するかを見つけるために必要な部品をインポートします。
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'dart:io';

// part 'app_database.g.dart'; は、Driftがこのファイルから自動生成するコードを、
// このファイルの一部として取り込むための魔法の言葉です。
// これにより、後で `_$AppDatabase` のような、今はまだ存在しないクラス名を使ってもエラーになりません。
part 'app_database.g.dart';

// --- テーブル定義 ---
// ここから、ゲーム内で使用するデータの保管棚（テーブル）の設計図を定義していきます。

// プレイヤーの状態を保存するテーブル
// 使用例: 所持金、現在のスタミナなど
@DataClassName('PlayerState') // Driftが生成するデータクラスの名前を指定します。
class PlayerStates extends Table {
  // id: 各レコードを一位に識別するための番号。自動で連番が振られます。
  IntColumn get id => integer().autoIncrement()();
  // money: プレイヤーの所持金。デフォルトは0です。
  IntColumn get money => integer().withDefault(const Constant(0))();
  // stamina: プレイヤーの現在のスタミナ。デフォルトは100.0です。
  RealColumn get stamina => real().withDefault(const Constant(100.0))();
}

// プレイヤーの持ち物（インベントリ）を保存するテーブル
// 使用例: トマトを5個、木材を20本持っている、など
@DataClassName('InventoryItem')
class InventoryItems extends Table {
  // id: 各レコードを一位に識別するための番号。
  IntColumn get id => integer().autoIncrement()();
  // itemCode: アイテムの種類を識別するためのユニークな文字列コード（例: 'tomato', 'wood'）。
  TextColumn get itemCode => text()();
  // quantity: そのアイテムを何個持っているか。
  IntColumn get quantity => integer()();
}

// 畑の区画の状態を保存するテーブル
// 使用例: 座標(3, 5)の畑にはトマトが植えられていて、成長段階は2だ、など
@DataClassName('FarmPlot')
class FarmPlots extends Table {
  // id: 各レコードを一位に識別するための番号。
  IntColumn get id => integer().autoIncrement()();
  // x, y: 農場マップ内での区画の座標。
  IntColumn get x => integer()();
  IntColumn get y => integer()();
  // cropCode: 植えられている作物のアイテムコード。何も植えられていなければnull。
  TextColumn get cropCode => text().nullable()();
  // growthStage: 作物の成長段階（例: 0:種, 1:芽, 2:成長, 3:収穫可能）。
  IntColumn get growthStage => integer().withDefault(const Constant(0))();
  // wateredAt: 最後に水をやったゲーム内の日付。
  TextColumn get wateredAt => text().nullable()();
}

// 飼育している動物の情報を保存するテーブル
@DataClassName('Animal')
class Animals extends Table {
  // id: 各レコードを一位に識別するための番号。
  IntColumn get id => integer().autoIncrement()();
  // typeCode: 動物の種類を識別するコード（例: 'chicken', 'cow'）。
  TextColumn get typeCode => text()();
  // name: プレイヤーが付けた動物の名前。
  TextColumn get name => text()();
  // friendship: なかよし度。
  IntColumn get friendship => integer().withDefault(const Constant(0))();
}

// アイテムの静的な定義情報を保存するテーブル（図鑑データ）
// このテーブルは、ゲーム開始時に初期データを投入し、その後は基本的に読み取り専用として使います。
@DataClassName('ItemDefinition')
class ItemDefinitions extends Table {
  // code: アイテムを一位に識別するための文字列コード。
  TextColumn get code => text()();
  // name: アイテムの表示名（例: 'トマト'）。
  TextColumn get name => text()();
  // description: アイテムの説明文。
  TextColumn get description => text()();
  // sellPrice: 基本の売値。
  IntColumn get sellPrice => integer()();
  // itemType: アイテムの種類（例: 'CROP', 'FISH', 'DISH'）。
  TextColumn get itemType => text()();

  // codeをプライマリキー（このテーブルの主役となるユニークな値）に設定します。
  @override
  Set<Column> get primaryKey => {code};
}


// --- データベース本体の定義 ---

// Riverpodを使って、アプリ全体でただ一つのAppDatabaseのインスタンスを共有するための「提供者」を定義します。
// これにより、どのWidgetからでも同じデータベースにアクセスできるようになります。
// いわば、データベースの鍵を管理する「金庫番」を、アプリ内に一人だけ配置するイメージです。
final databaseProvider = Provider<AppDatabase>((ref) {
  // AppDatabaseのインスタンスを生成して返す。
  return AppDatabase();
});

// `@DriftDatabase` というアノテーション（目印）を付けることで、
// このクラスがDriftデータベースの本体であることを示します。
// `tables` プロパティに、上で定義したすべてのテーブルクラスを登録します。
@DriftDatabase(tables: [
  PlayerStates,
  InventoryItems,
  FarmPlots,
  Animals,
  ItemDefinitions,
])
class AppDatabase extends _$AppDatabase {
  // AppDatabaseのコンストラクタ（インスタンスが作られる時に呼ばれる処理）
  AppDatabase() : super(_openConnection());

  // スキーマバージョン。将来テーブルの構造を変える（カラムを追加するなど）場合に、
  // この数値を上げることで、Driftにデータベースの更新が必要であることを伝えます。
  @override
  int get schemaVersion => 1;

  // ゲーム開始時に静的なアイテム定義データをデータベースに挿入するメソッドです。
  // ItemDefinitionsテーブルが空の場合にのみ実行されます。
  Future<void> insertInitialItemDefinitions(List<Item> items) async {
    // ItemDefinitionsテーブルにデータが既に存在するか確認します。
    final count = await (select(itemDefinitions).get()).then((value) => value.length);
    if (count == 0) { // データが一つもなければ挿入します。
      // 渡されたItemリストを、Driftが扱えるItemDefinitionsCompanionのリストに変換します。
      final companions = items.map((item) => ItemDefinitionsCompanion(
        code: Value(item.code),
        name: Value(item.name),
        description: Value(item.description),
        sellPrice: Value(item.sellPrice),
        itemType: Value(item.type.toString().split('.').last), // enumを文字列に変換
      )).toList();
      // 変換したデータを一括で挿入します。
      await batch((batch) {
        batch.insertAll(itemDefinitions, companions);
      });
    }
  }
}

// データベースファイルを開き、接続を確立するための補助的な関数です。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // アプリがファイルを保存できる安全な場所のパスを取得します。
    final dbFolder = await getApplicationDocumentsDirectory();
    // その場所の中に 'db.sqlite' という名前でデータベースファイルを作成します。
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    // 作成したファイルを使って、ネイティブ（iOS/Androidなど）のSQLiteデータベースに接続します。
    return NativeDatabase(file);
  });
}
