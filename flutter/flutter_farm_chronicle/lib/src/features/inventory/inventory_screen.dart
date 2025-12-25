// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// GoRouter（画面遷移）を使うために必要なパッケージをインポートします。
import 'package:go_router/go_router.dart';
// インベントリの状態を管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';

// InventoryScreenは、プレイヤーの持ち物一覧を表示する画面です。
// ConsumerWidgetを継承することで、RiverpodのProviderからインベントリの状態を読み取ることができます。
class InventoryScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // inventoryNotifierProviderを監視し、現在のインベントリのアイテムリストを取得します。
    // インベントリの内容が更新されると、このWidgetは自動的に再描画されます。
    final inventory = ref.watch(inventoryNotifierProvider);

    // インベントリ内のアイテム定義も取得します。
    // TODO: このallGameItemsはデータベースから取得するように変更する必要があります。
    // 現時点では静的なリストから取得します。
    final allItems = allGameItems;

    // Scaffoldは、アプリの基本的な骨格を提供するWidgetです。
    return Scaffold(
      // AppBarは、画面上部に表示されるバーです。タイトルと戻るボタンを配置します。
      appBar: AppBar(
        title: const Text('インベントリ'), // 画面のタイトル
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 戻るアイコン
          onPressed: () {
            // 戻るボタンが押されたら、GoRouterを使って前の画面に戻ります。
            context.pop();
          },
        ),
      ),
      // bodyプロパティに、インベントリのアイテム一覧を配置します。
      body: inventory.isEmpty
          ? const Center(
              // インベントリが空の場合に表示するメッセージ
              child: Text(
                'インベントリは空です。',
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              // GridView.builderは、アイテムをグリッド状に効率的に表示するためのWidgetです。
              padding: const EdgeInsets.all(8.0), // グリッド全体のパディング
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 横方向に4つのアイテムを配置
                crossAxisSpacing: 8.0, // アイテム間の横方向のスペース
                mainAxisSpacing: 8.0, // アイテム間の縦方向のスペース
                childAspectRatio: 0.8, // アイテムの縦横比（少し縦長にする）
              ),
              itemCount: inventory.length, // 表示するアイテムの総数
              itemBuilder: (context, index) {
                // インベントリから現在のアイテムデータを取得します。
                final invItem = inventory[index];
                // アイテムコードに対応するアイテム定義を探します。
                final itemDef = allItems.firstWhere(
                  (def) => def.code == invItem.itemCode,
                  // 見つからない場合はダミーのアイテム定義を返します。
                  orElse: () => Item(code: 'unknown', name: '不明なアイテム', description: '', sellPrice: 0, type: ItemType.misc),
                );

                // 各アイテムの表示
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // アイテムの画像
                      Image.asset(
                        'assets/images/item_${itemDef.code}.png', // アイテムの画像パス
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48), // 画像がない場合の代替
                      ),
                      const SizedBox(height: 4),
                      // アイテムの名前
                      Text(
                        itemDef.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      // アイテムの数量
                      Text(
                        'x${invItem.quantity}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
