// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// データベースのAppDatabaseとInventoryItemテーブルから生成されたデータクラスをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// DriftのValueクラスをインポートします。データベースの値を更新する際に使用します。
import 'package:drift/drift.dart';

// プレイヤーの持ち物（インベントリ）の状態を管理するStateNotifierクラスです。
// このクラスが、InventoryItemのリストを保持し、アイテムの追加・削除などのロジックを扱います。
class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  final AppDatabase _db; // データベースへの参照

  // コンストラクタ。データベースを受け取ります。
  InventoryNotifier(this._db) : super([]) {
    // Notifierが作成されたら、データベースからインベントリデータをロードします。
    _loadInventory();
  }

  // データベースからインベントリデータをロードする非同期メソッドです。
  Future<void> _loadInventory() async {
    // データベースからすべてのInventoryItemレコードを取得します。
    final items = await _db.select(_db.inventoryItems).get();
    // 取得したデータを現在の状態として設定します。
    state = items;
  }

  // インベントリにアイテムを追加するメソッドです。
  // amountが指定されない場合は1個追加します。
  Future<void> addItem(String itemCode, {int amount = 1}) async {
    // 既に同じアイテムがインベントリにあるか確認します。
    final existingItem = state.where((item) => item.itemCode == itemCode).firstOrNull;

    if (existingItem != null) {
      // 既存のアイテムがあれば、数量を更新します。
      await _db.update(_db.inventoryItems)
          .where((tbl) => tbl.itemCode.equals(itemCode))
          .write(InventoryItemsCompanion(
            quantity: Value(existingItem.quantity + amount),
          ));
    } else {
      // なければ、新しいアイテムとして追加します。
      await _db.into(_db.inventoryItems).insert(InventoryItemsCompanion(
        itemCode: Value(itemCode),
        quantity: Value(amount),
      ));
    }
    // データベースの更新後、現在の状態を再ロードしてUIを更新します。
    await _loadInventory();
  }

  // インベントリからアイテムを削除するメソッドです。
  // amountが指定されない場合は1個削除します。
  Future<bool> removeItem(String itemCode, {int amount = 1}) async {
    final existingItem = state.where((item) => item.itemCode == itemCode).firstOrNull;

    if (existingItem == null || existingItem.quantity < amount) {
      // アイテムがないか、数量が足りなければ削除できません。
      return false;
    }

    if (existingItem.quantity == amount) {
      // 数量がちょうど0になる場合は、アイテム自体を削除します。
      await _db.delete(_db.inventoryItems)
          .where((tbl) => tbl.itemCode.equals(itemCode))
          .go();
    } else {
      // 数量が残る場合は、数量を更新します。
      await _db.update(_db.inventoryItems)
          .where((tbl) => tbl.itemCode.equals(itemCode))
          .write(InventoryItemsCompanion(
            quantity: Value(existingItem.quantity - amount),
          ));
    }
    // データベースの更新後、現在の状態を再ロードしてUIを更新します。
    await _loadInventory();
    return true;
  }

  // 特定のアイテムをインベントリに持っているか、また指定された数量を持っているかを確認します。
  bool hasItem(String itemCode, {int amount = 1}) {
    final existingItem = state.where((item) => item.itemCode == itemCode).firstOrNull;
    return existingItem != null && existingItem.quantity >= amount;
  }

  // 特定のアイテムの数量を取得します。
  int getItemQuantity(String itemCode) {
    final existingItem = state.where((item) => item.itemCode == itemCode).firstOrNull;
    return existingItem?.quantity ?? 0;
  }
}

// InventoryNotifierのインスタンスを提供するStateNotifierProviderです。
// このProviderはAppDatabaseに依存するため、ref.watchを使ってインスタンスを取得します。
final inventoryNotifierProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  // データベースのインスタンスを取得します。
  final db = ref.watch(databaseProvider);
  // InventoryNotifierの新しいインスタンスを作成して返します。
  return InventoryNotifier(db);
});
