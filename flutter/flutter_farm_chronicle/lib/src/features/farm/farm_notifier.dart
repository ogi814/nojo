// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// データベースのAppDatabaseとFarmPlotテーブルから生成されたデータクラスをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// プレイヤーの状態を管理するProviderをインポートします。スタミナを消費するため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// インベントリの状態を管理するProviderをインポートします。種を消費するため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// ゲーム時間システムを管理するProviderをインポートします。作物の成長に時間を使うため。
import 'package:flutter_farm_chronicle/src/core/providers/game_time_provider.dart';
// DriftのValueクラスをインポートします。データベースの値を更新する際に使用します。
import 'package:drift/drift.dart';

// 農場のグリッドサイズを定義します。例として5x5の農場とします。
const int farmGridSizeX = 5;
const int farmGridSizeY = 5;

// 農場の区画全体の状態を管理するStateNotifierクラスです。
// このクラスが、FarmPlotのリストを保持し、区画の耕作や作物の成長などのロジックを扱います。
class FarmNotifier extends StateNotifier<List<FarmPlot>> {
  final AppDatabase _db; // データベースへの参照
  final PlayerStateNotifier _playerStateNotifier; // プレイヤーの状態Notifierへの参照
  final InventoryNotifier _inventoryNotifier; // インベントリNotifierへの参照
  // ゲーム時間Notifierへの参照。作物の成長を管理するために必要です。
  final GameTimeNotifier _gameTimeNotifier;

  // コンストラクタ。データベースとプレイヤー状態Notifier、インベントリNotifier、ゲーム時間Notifierを受け取ります。
  FarmNotifier(this._db, this._playerStateNotifier, this._inventoryNotifier, this._gameTimeNotifier) : super([]) {
    // Notifierが作成されたら、データベースから農場の区画データをロードします。
    _loadFarmPlots();
    // ゲーム時間の変更を監視し、日が変わったら作物の成長を進めます。
    _gameTimeNotifier.addListener((gameTime) {
      // 日が変わったタイミングで成長処理を実行します。
      // ただし、ゲーム開始直後など、まだ農場がロードされていない場合はスキップします。
      if (state.isNotEmpty && gameTime.hour == 0 && gameTime.minute == 0) { // 0時0分になったら日が変わったと判断
        _advanceCropGrowth();
      }
    });
  }

  // データベースから農場の区画データをロードする非同期メソッドです。
  Future<void> _loadFarmPlots() async {
    // データベースからすべてのFarmPlotレコードを取得します。
    final plots = await _db.select(_db.farmPlots).get();
    if (plots.isEmpty) {
      // もしデータベースに区画データがなければ、初期の空の農場グリッドを作成します。
      await _initializeFarmGrid();
      // 初期化後、再度ロードします。
      state = await _db.select(_db.farmPlots).get();
    } else {
      // データがあれば、それを現在の状態として設定します。
      state = plots;
    }
  }

  // 農場グリッドを初期化するメソッドです。
  // ゲーム開始時や新しいゲーム開始時に呼ばれます。
  Future<void> _initializeFarmGrid() async {
    final List<FarmPlotsCompanion> initialPlots = [];
    for (int y = 0; y < farmGridSizeY; y++) {
      for (int x = 0; x < farmGridSizeX; x++) {
        initialPlots.add(FarmPlotsCompanion(
          x: Value(x),
          y: Value(y),
          cropCode: const Value(null), // 最初は何も植えられていない
          growthStage: const Value(0), // 空の土の状態
          wateredAt: const Value(null),
        ));
      }
    }
    // 生成した初期区画データをデータベースに一括挿入します。
    await _db.batch((batch) {
      batch.insertAll(_db.farmPlots, initialPlots);
    });
  }

  // 指定された座標の区画を耕すメソッドです。
  // プレイヤーのスタミナを消費し、区画の状態を「耕された土」に更新します。
  Future<bool> tillPlot(int x, int y) async {
    // 耕すアクションに必要なスタミナを定義します。
    const double staminaCost = 5.0;

    // プレイヤーの現在のスタミナが足りているか確認します。
    if (_playerStateNotifier.state.stamina < staminaCost) {
      print('スタミナが足りません！'); // デバッグ出力
      return false; // スタミナが足りなければ処理を中断します。
    }

    // プレイヤーのスタミナを消費します。
    _playerStateNotifier.deductStamina(staminaCost);

    // データベース内で、指定されたx,y座標の区画を検索します。
    final plotQuery = _db.update(_db.farmPlots)
      ..where((tbl) => tbl.x.equals(x) & tbl.y.equals(y));

    // 区画の状態を「耕された土」に更新します。
    // cropCodeはnullのまま、growthStageを1（耕された状態）にします。
    await plotQuery.write(FarmPlotsCompanion(
      cropCode: const Value(null), // 耕された土にはまだ作物は植えられていない
      growthStage: const Value(1), // 耕された状態
    ));

    // データベースの更新後、現在の状態（List<FarmPlot>）を再ロードしてUIを更新します。
    await _loadFarmPlots();
    return true;
  }

  // 指定された座標の区画に種をまくメソッドです。
  // プレイヤーのインベントリから種を消費し、区画の状態を「作物が植えられた状態」に更新します。
  Future<bool> plantSeed(int x, int y, String seedItemCode) async {
    // 種まきに必要なスタミナを定義します。
    const double staminaCost = 2.0;

    // プレイヤーの現在のスタミナが足りているか確認します。
    if (_playerStateNotifier.state.stamina < staminaCost) {
      print('スタミナが足りません！');
      return false;
    }

    // プレイヤーが指定された種をインベントリに持っているか確認します。
    if (!_inventoryNotifier.hasItem(seedItemCode)) {
      print('種を持っていません！');
      return false;
    }

    // プレイヤーのスタミナを消費します。
    _playerStateNotifier.deductStamina(staminaCost);
    // インベントリから種を1つ消費します。
    await _inventoryNotifier.removeItem(seedItemCode);

    // 種のアイテムコードから、対応する作物のアイテムコードを推測します。
    // 例: 'turnip_seed' -> 'turnip_crop'
    final cropItemCode = seedItemCode.replaceAll('_seed', '_crop');

    // データベース内で、指定されたx,y座標の区画を検索します。
    final plotQuery = _db.update(_db.farmPlots)
      ..where((tbl) => tbl.x.equals(x) & tbl.y.equals(y));

    // 区画の状態を「作物が植えられた状態」に更新します。
    // cropCodeに作物のコードを設定し、growthStageを0（種が植えられたばかり）にします。
    await plotQuery.write(FarmPlotsCompanion(
      cropCode: Value(cropItemCode),
      growthStage: const Value(0), // 種が植えられたばかり
      wateredAt: Value(null), // 水やり状態をリセット
    ));

    // データベースの更新後、現在の状態（List<FarmPlot>）を再ロードしてUIを更新します。
    await _loadFarmPlots();
    return true;
  }

  // 作物の成長を進めるメソッドです。ゲーム内で日が変わるたびに呼ばれます。
  Future<void> _advanceCropGrowth() async {
    print('作物の成長を進めます...'); // デバッグ出力
    final updatedPlots = <FarmPlotsCompanion>[];

    for (final plot in state) {
      // 作物が植えられていない区画、または既に収穫可能な区画はスキップします。
      if (plot.cropCode == null || plot.growthStage == null) continue;

      // アイテム定義から作物の情報を取得します。
      final cropDefinition = allGameItems.firstWhere(
        (item) => item.code == plot.cropCode,
        orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc), // 見つからない場合
      );

      // 作物でなければスキップします。
      if (cropDefinition.type != ItemType.crop || cropDefinition.maxGrowthStage == null) continue;

      // 現在の成長段階が最大成長段階未満の場合のみ成長を進めます。
      if (plot.growthStage! < cropDefinition.maxGrowthStage!) {
        updatedPlots.add(FarmPlotsCompanion(
          id: Value(plot.id),
          growthStage: Value(plot.growthStage! + 1), // 成長段階を1進める
        ));
      }
    }

    // 更新が必要な区画があれば、データベースを一括で更新します。
    if (updatedPlots.isNotEmpty) {
      await _db.batch((batch) {
        for (final plotCompanion in updatedPlots) {
          batch.update(_db.farmPlots, plotCompanion, where: (tbl) => tbl.id.equals(plotCompanion.id.value));
        }
      });
      // データベースの更新後、現在の状態を再ロードしてUIを更新します。
      await _loadFarmPlots();
    }
  }

  // 指定された座標の区画から作物を収穫するメソッドです。
  // プレイヤーのスタミナを消費し、インベントリに作物を追加し、区画を空の土に戻します。
  Future<bool> harvestCrop(int x, int y) async {
    // 収穫に必要なスタミナを定義します。
    const double staminaCost = 10.0;

    // プレイヤーの現在のスタミナが足りているか確認します。
    if (_playerStateNotifier.state.stamina < staminaCost) {
      print('スタミナが足りません！');
      return false;
    }

    // 指定された区画の現在の状態を取得します。
    final plot = state.firstWhere((p) => p.x == x && p.y == y);

    // 作物が植えられていない、または成長段階がnullの場合は収穫できません。
    if (plot.cropCode == null || plot.growthStage == null) {
      print('収穫できる作物がありません。');
      return false;
    }

    // アイテム定義から作物の情報を取得します。
    final cropDefinition = allGameItems.firstWhere(
      (item) => item.code == plot.cropCode,
      orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc),
    );

    // 作物でなければ収穫できません。
    if (cropDefinition.type != ItemType.crop || cropDefinition.maxGrowthStage == null) {
      print('これは作物ではありません。');
      return false;
    }

    // 作物が完全に成長しているか確認します。
    if (plot.growthStage! < cropDefinition.maxGrowthStage!) {
      print('作物はまだ成長途中です。');
      return false;
    }

    // プレイヤーのスタミナを消費します。
    _playerStateNotifier.deductStamina(staminaCost);
    // インベントリに収穫した作物を追加します。
    await _inventoryNotifier.addItem(cropDefinition.code);

    // データベース内で、指定されたx,y座標の区画を検索します。
    final plotQuery = _db.update(_db.farmPlots)
      ..where((tbl) => tbl.x.equals(x) & tbl.y.equals(y));

    // 区画の状態を「空の土」に戻します。
    await plotQuery.write(FarmPlotsCompanion(
      cropCode: const Value(null),
      growthStage: const Value(0), // 空の土の状態
      wateredAt: Value(null),
    ));

    // データベースの更新後、現在の状態（List<FarmPlot>）を再ロードしてUIを更新します。
    await _loadFarmPlots();
    return true;
  }

  // TODO: 今後、水やりをするなどのメソッドをここに追加していきます。
}

// FarmNotifierのインスタンスを提供するStateNotifierProviderです。
// このProviderは、AppDatabase、PlayerStateNotifier、InventoryNotifier、GameTimeNotifierに依存するため、
// ref.watchを使ってそれらのProviderからインスタンスを取得します。
final farmNotifierProvider = StateNotifierProvider<FarmNotifier, List<FarmPlot>>((ref) {
  // データベースのインスタンスを取得します。
  final db = ref.watch(databaseProvider);
  // プレイヤーの状態Notifierのインスタンスを取得します。
  final playerStateNotifier = ref.watch(playerStateProvider.notifier);
  // インベントリNotifierのインスタンスを取得します。
  final inventoryNotifier = ref.watch(inventoryNotifierProvider.notifier);
  // ゲーム時間Notifierのインスタンスを取得します。
  final gameTimeNotifier = ref.watch(gameTimeProvider.notifier);
  // FarmNotifierの新しいインスタンスを作成して返します。
  return FarmNotifier(db, playerStateNotifier, inventoryNotifier, gameTimeNotifier);
});


