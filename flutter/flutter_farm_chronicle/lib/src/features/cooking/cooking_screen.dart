// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// GoRouter（画面遷移）を使うために必要なパッケージをインポートします。
import 'package:go_router/go_router.dart';
// プレイヤーの状態を管理するProviderをインポートします。スタミナ消費のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。材料消費と完成品追加のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// レシピ定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/recipes.dart';
// ゲーム時間Notifierをインポートします。調理に時間がかかるため。
import 'package:flutter_farm_chronicle/src/core/providers/game_time_provider.dart';

// CookingScreenは、料理を行うための画面です。
// ConsumerWidgetを継承することで、RiverpodのProviderから必要な状態を読み取ることができます。
class CookingScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const CookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイヤーの現在のスタミナを監視します。
    final playerStamina = ref.watch(playerStateProvider.select((state) => state.stamina));
    // インベントリの状態を監視します。
    final inventory = ref.watch(inventoryNotifierProvider);
    // インベントリNotifierのインスタンスを取得します。
    final inventoryNotifier = ref.read(inventoryNotifierProvider.notifier);
    // プレイヤーの状態Notifierのインスタンスを取得します。
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    // ゲーム時間Notifierのインスタンスを取得します。
    final gameTimeNotifier = ref.read(gameTimeProvider.notifier);

    // すべてのアイテム定義を取得します。
    final allItems = allGameItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('キッチン'), // 画面のタイトル
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 戻るボタン
          onPressed: () => context.pop(), // 前の画面に戻る
        ),
      ),
      body: Column(
        children: [
          // プレイヤーのスタミナ表示
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'スタミナ: ${playerStamina.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          // レシピ一覧
          Expanded(
            child: ListView.builder(
              itemCount: allRecipes.length,
              itemBuilder: (context, index) {
                final recipe = allRecipes[index];
                // 完成品のアイテム定義を取得
                final outputItemDef = allItems.firstWhere(
                  (def) => def.code == recipe.outputItemCode,
                  orElse: () => Item(code: '', name: '不明な料理', description: '', sellPrice: 0, type: ItemType.misc),
                );

                // 材料が揃っているか、スタミナが足りているかを確認
                bool canCook = true;
                String missingIngredients = '';
                for (var entry in recipe.ingredients.entries) {
                  final requiredItemCode = entry.key;
                  final requiredQuantity = entry.value;
                  final currentQuantity = inventoryNotifier.getItemQuantity(requiredItemCode);
                  if (currentQuantity < requiredQuantity) {
                    canCook = false;
                    final missingItemDef = allItems.firstWhere(
                      (def) => def.code == requiredItemCode,
                      orElse: () => Item(code: '', name: '不明な材料', description: '', sellPrice: 0, type: ItemType.misc),
                    );
                    missingIngredients += '${missingItemDef.name} x${requiredQuantity - currentQuantity} ';
                  }
                }
                if (playerStamina < recipe.staminaCost) {
                  canCook = false;
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/item_${outputItemDef.code}.png', // 完成品の画像
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                    ),
                    title: Text(outputItemDef.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('必要スタミナ: ${recipe.staminaCost.toStringAsFixed(1)}'),
                        Text('調理時間: ${recipe.timeCostMinutes}分'),
                        Text('材料: ${recipe.ingredients.entries.map((e) {
                          final ingredientDef = allItems.firstWhere((def) => def.code == e.key, orElse: () => Item(code: '', name: '不明', description: '', sellPrice: 0, type: ItemType.misc));
                          return '${ingredientDef.name} x${e.value}';
                        }).join(', ')}'),
                        if (!canCook && missingIngredients.isNotEmpty)
                          Text(
                            '材料不足: $missingIngredients',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        if (!canCook && playerStamina < recipe.staminaCost)
                          const Text(
                            'スタミナ不足',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: canCook
                          ? () async {
                              // 材料を消費
                              for (var entry in recipe.ingredients.entries) {
                                await inventoryNotifier.removeItem(entry.key, amount: entry.value);
                              }
                              // スタミナを消費
                              playerStateNotifier.deductStamina(recipe.staminaCost);
                              // 調理時間を進める
                              for(int i=0; i<recipe.timeCostMinutes; i++) {
                                gameTimeNotifier.advanceTime();
                              }
                              // 完成品をインベントリに追加
                              await inventoryNotifier.addItem(recipe.outputItemCode);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${outputItemDef.name}を調理しました！')),
                              );
                            }
                          : null, // 調理できない場合はボタンを無効化
                      child: const Text('調理'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
