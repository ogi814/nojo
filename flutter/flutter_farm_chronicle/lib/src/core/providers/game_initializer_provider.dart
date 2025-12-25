// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// データベースのAppDatabaseと、そのProviderをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// アイテム定義のリストをインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// プレイヤーの状態Notifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリNotifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// 農場Notifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/farm_notifier.dart';
// 動物Notifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/animal_farm/animal_notifier.dart';

// ゲームの初期化状態を表すクラスです。
// 初期化が完了したかどうかを示すために使います。
class GameInitializationState {
  final bool isInitialized; // 初期化が完了したかどうか

  GameInitializationState({required this.isInitialized});
}

// ゲームの初期化処理を管理するFutureProviderです。
// アプリ起動時に一度だけ実行され、データベースの準備や初期データの投入を行います。
final gameInitializerProvider = FutureProvider<GameInitializationState>((ref) async {
  // データベースのインスタンスを取得します。
  // これにより、データベースが初期化（ファイル作成、テーブル作成）されます。
  final db = ref.read(databaseProvider);

  // データベースに初期のアイテム定義データを投入します。
  // ItemDefinitionsテーブルが空の場合にのみ実行されます。
  await db.insertInitialItemDefinitions(allGameItems);

  // 各Notifierを初期化（データベースからデータをロード）します。
  // ref.read(notifier.notifier)を呼び出すことで、Notifierのコンストラクタが実行され、
  // その中でデータロード処理が走ります。
  ref.read(playerStateProvider.notifier);
  ref.read(inventoryNotifierProvider.notifier);
  ref.read(farmNotifierProvider.notifier);
  ref.read(animalNotifierProvider.notifier);

  // TODO: 今後、セーブデータのロードや、新しいゲーム開始時の処理などをここに追加します。

  // すべての初期化処理が完了したことを示します。
  return GameInitializationState(isInitialized: true);
});
