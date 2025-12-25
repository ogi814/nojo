// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// データベースのAppDatabaseとAnimalsテーブルから生成されたデータクラスをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// プレイヤーの状態を管理するProviderをインポートします。スタミナ消費のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。餌の消費や生産物の追加のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// ゲーム時間Notifierをインポートします。動物の成長や生産物の生成に時間を使うため。
import 'package:flutter_farm_chronicle/src/core/providers/game_time_provider.dart';
// DriftのValueクラスをインポートします。データベースの値を更新する際に使用します。
import 'package:drift/drift.dart';

// 動物の種類を定義するクラスです。
// このクラスは、動物の静的な情報（名前、購入価格、生産物など）を保持します。
class AnimalType {
  final String code; // 動物の種類を識別するコード（例: 'chicken', 'cow'）
  final String name; // 動物の表示名（例: 'ニワトリ', 'ウシ'）
  final int buyPrice; // 購入価格
  final String productCode; // 生産物のアイテムコード（例: 'egg', 'milk'）
  final double staminaCostFeed; // 餌やりにかかるスタミナ
  final double staminaCostPet; // なでるのにかかるスタミナ

  AnimalType({
    required this.code,
    required this.name,
    required this.buyPrice,
    required this.productCode,
    this.staminaCostFeed = 5.0,
    this.staminaCostPet = 2.0,
  });
}

// ゲーム内で利用可能なすべての動物の種類を定義します。
final List<AnimalType> allAnimalTypes = [
  AnimalType(
    code: 'chicken',
    name: 'ニワトリ',
    buyPrice: 500,
    productCode: 'egg',
  ),
  AnimalType(
    code: 'cow',
    name: 'ウシ',
    buyPrice: 2000,
    productCode: 'milk',
    staminaCostFeed: 10.0,
    staminaCostPet: 5.0,
  ),
];

// 飼育している動物の状態を管理するStateNotifierクラスです。
// このクラスが、Animalsのリストを保持し、動物の追加、餌やり、生産物の収集などのロジックを扱います。
class AnimalNotifier extends StateNotifier<List<Animal>> {
  final AppDatabase _db; // データベースへの参照
  final PlayerStateNotifier _playerStateNotifier; // プレイヤーの状態Notifierへの参照
  final InventoryNotifier _inventoryNotifier; // インベントリNotifierへの参照
  final GameTimeNotifier _gameTimeNotifier; // ゲーム時間Notifierへの参照

  // コンストラクタ。データベース、プレイヤー状態Notifier、インベントリNotifier、ゲーム時間Notifierを受け取ります。
  AnimalNotifier(this._db, this._playerStateNotifier, this._inventoryNotifier, this._gameTimeNotifier) : super([]) {
    // Notifierが作成されたら、データベースから動物データをロードします。
    _loadAnimals();
    // ゲーム時間の変更を監視し、日が変わったら動物の生産物生成などを進めます。
    _gameTimeNotifier.addListener((gameTime) {
      if (state.isNotEmpty && gameTime.hour == 0 && gameTime.minute == 0) { // 0時0分になったら日が変わったと判断
        _advanceAnimalProduction();
      }
    });
  }

  // データベースから動物データをロードする非同期メソッドです。
  Future<void> _loadAnimals() async {
    final animals = await _db.select(_db.animals).get();
    state = animals;
  }

  // 新しい動物を購入し、農場に追加するメソッドです。
  Future<bool> addAnimal(String typeCode, String name) async {
    final animalType = allAnimalTypes.firstWhere((type) => type.code == typeCode);
    // プレイヤーの所持金が足りているか確認します。
    if (_playerStateNotifier.state.money < animalType.buyPrice) {
      print('所持金が足りません！');
      return false;
    }
    // 所持金を減らします。
    _playerStateNotifier.deductMoney(animalType.buyPrice);

    // データベースに新しい動物を追加します。
    await _db.into(_db.animals).insert(AnimalsCompanion(
      typeCode: Value(typeCode),
      name: Value(name),
      friendship: const Value(0), // 初期なかよし度は0
    ));
    await _loadAnimals(); // 状態を更新
    return true;
  }

  // 動物に餌をやるメソッドです。
  Future<bool> feedAnimal(int animalId) async {
    final animal = state.firstWhere((a) => a.id == animalId);
    final animalType = allAnimalTypes.firstWhere((type) => type.code == animal.typeCode);

    // スタミナが足りているか確認します。
    if (_playerStateNotifier.state.stamina < animalType.staminaCostFeed) {
      print('スタミナが足りません！');
      return false;
    }
    // 餌を持っているか確認します。
    if (!_inventoryNotifier.hasItem('animal_feed')) {
      print('餌を持っていません！');
      return false;
    }

    _playerStateNotifier.deductStamina(animalType.staminaCostFeed); // スタミナ消費
    await _inventoryNotifier.removeItem('animal_feed'); // 餌を消費

    // なかよし度を少し上げます。
    await _db.update(_db.animals).where((tbl) => tbl.id.equals(animalId)).write(
      AnimalsCompanion(friendship: Value(animal.friendship + 5)),
    );
    await _loadAnimals();
    return true;
  }

  // 動物をなでるメソッドです。
  Future<bool> petAnimal(int animalId) async {
    final animal = state.firstWhere((a) => a.id == animalId);
    final animalType = allAnimalTypes.firstWhere((type) => type.code == animal.typeCode);

    // スタミナが足りているか確認します。
    if (_playerStateNotifier.state.stamina < animalType.staminaCostPet) {
      print('スタミナが足りません！');
      return false;
    }

    _playerStateNotifier.deductStamina(animalType.staminaCostPet); // スタミナ消費

    // なかよし度を少し上げます。
    await _db.update(_db.animals).where((tbl) => tbl.id.equals(animalId)).write(
      AnimalsCompanion(friendship: Value(animal.friendship + 10)),
    );
    await _loadAnimals();
    return true;
  }

  // 動物の生産物（卵、ミルクなど）を収集するメソッドです。
  Future<bool> collectProduct(int animalId) async {
    final animal = state.firstWhere((a) => a.id == animalId);
    final animalType = allAnimalTypes.firstWhere((type) => type.code == animal.typeCode);

    // TODO: 生産物収集に必要なスタミナを定義する
    const double staminaCost = 5.0;

    if (_playerStateNotifier.state.stamina < staminaCost) {
      print('スタミナが足りません！');
      return false;
    }
    _playerStateNotifier.deductStamina(staminaCost);

    // インベントリに生産物を追加します。
    await _inventoryNotifier.addItem(animalType.productCode);
    print('${animal.name}から${animalType.productCode}を収集しました！');
    // TODO: 生産物収集後、動物が再度生産物を生成するまでのクールダウンを設ける

    await _loadAnimals();
    return true;
  }

  // 日が変わった際に動物の生産物生成などを進めるメソッドです。
  Future<void> _advanceAnimalProduction() async {
    print('動物の生産物生成を進めます...');
    for (final animal in state) {
      // TODO: なかよし度や時間経過に応じて生産物を生成するロジックを実装
      // 例: ニワトリは毎日卵を産む、ウシは毎日ミルクを出すなど
      // 現時点では、日が変わるたびに生産物を生成するロジックは未実装です。
    }
    await _loadAnimals();
  }
}

// AnimalNotifierのインスタンスを提供するStateNotifierProviderです。
final animalNotifierProvider = StateNotifierProvider<AnimalNotifier, List<Animal>>((ref) {
  final db = ref.watch(databaseProvider);
  final playerStateNotifier = ref.watch(playerStateProvider.notifier);
  final inventoryNotifier = ref.watch(inventoryNotifierProvider.notifier);
  final gameTimeNotifier = ref.watch(gameTimeProvider.notifier);
  return AnimalNotifier(db, playerStateNotifier, inventoryNotifier, gameTimeNotifier);
});
