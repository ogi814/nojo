// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// GoRouter（画面遷移）を使うために必要なパッケージをインポートします。
import 'package:go_router/go_router.dart';
// プレイヤーの状態を管理するProviderをインポートします。所持金の増減のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。アイテムの追加・削除のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';

// ShopScreenは、アイテムの購入と売却を行う画面です。
// ConsumerWidgetを継承することで、RiverpodのProviderから必要な状態を読み取ることができます。
class ShopScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイヤーの現在の所持金を監視します。
    final playerMoney = ref.watch(playerStateProvider.select((state) => state.money));
    // インベントリの状態を監視します。
    final inventory = ref.watch(inventoryNotifierProvider);
    // インベントリNotifierのインスタンスを取得します。
    final inventoryNotifier = ref.read(inventoryNotifierProvider.notifier);
    // プレイヤーの状態Notifierのインスタンスを取得します。
    final playerStateNotifier = ref.read(playerStateProvider.notifier);

    // 店で販売するアイテムのリストを定義します。
    // TODO: 今後、店ごとに販売アイテムを管理するシステムを実装します。
    // 現時点では、すべての種を販売アイテムとします。
    final List<Item> itemsForSale = allGameItems
        .where((item) => item.type == ItemType.seed)
        .toList();

    return DefaultTabController(
      length: 2, // 「購入」と「売却」の2つのタブ
      child: Scaffold(
        appBar: AppBar(
          title: const Text('商店'), // 画面のタイトル
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // 戻るボタン
            onPressed: () => context.pop(), // 前の画面に戻る
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '購入'), // 購入タブ
              Tab(text: '売却'), // 売却タブ
            ],
          ),
        ),
        body: Column(
          children: [
            // プレイヤーの所持金表示
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '所持金: $playerMoney G',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            // タブの内容
            Expanded(
              child: TabBarView(
                children: [
                  // --- 購入タブの内容 ---
                  _buildBuyTab(context, ref, itemsForSale, playerMoney, playerStateNotifier, inventoryNotifier),
                  // --- 売却タブの内容 ---
                  _buildSellTab(context, ref, inventory, allItems, playerStateNotifier, inventoryNotifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 購入タブのUIを構築するヘルパーメソッド
  Widget _buildBuyTab(
    BuildContext context,
    WidgetRef ref,
    List<Item> itemsForSale,
    int playerMoney,
    PlayerStateNotifier playerStateNotifier,
    InventoryNotifier inventoryNotifier,
  ) {
    return ListView.builder(
      itemCount: itemsForSale.length,
      itemBuilder: (context, index) {
        final item = itemsForSale[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.asset(
              'assets/images/item_${item.code}.png', // アイテムの画像
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
            ),
            title: Text(item.name),
            subtitle: Text('価格: ${item.sellPrice} G'), // 種のsellPriceをbuyPriceとして利用
            trailing: ElevatedButton(
              onPressed: playerMoney >= item.sellPrice
                  ? () async {
                      // 所持金が足りている場合のみ購入可能
                      playerStateNotifier.deductMoney(item.sellPrice); // お金を減らす
                      await inventoryNotifier.addItem(item.code); // アイテムを追加
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name}を購入しました！')),
                      );
                    }
                  : null, // 所持金が足りなければボタンを無効化
              child: const Text('購入'),
            ),
          ),
        );
      },
    );
  }

  // 売却タブのUIを構築するヘルパーメソッド
  Widget _buildSellTab(
    BuildContext context,
    WidgetRef ref,
    List<InventoryItem> inventory,
    List<Item> allItems,
    PlayerStateNotifier playerStateNotifier,
    InventoryNotifier inventoryNotifier,
  ) {
    // 売却可能なアイテム（インベントリにある作物など）をフィルタリング
    final List<Map<String, dynamic>> sellableItems = inventory
        .map((invItem) {
          final itemDef = allItems.firstWhere(
            (def) => def.code == invItem.itemCode,
            orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc),
          );
          // 売却可能なアイテム（作物など）かつ、数量が1以上あるもの
          if (itemDef.type == ItemType.crop && invItem.quantity > 0) {
            return {'itemDef': itemDef, 'quantity': invItem.quantity};
          }
          return null;
        })
        .whereType<Map<String, dynamic>>() // nullを除外
        .toList();

    if (sellableItems.isEmpty) {
      return const Center(child: Text('売却できるアイテムがありません。'));
    }

    return ListView.builder(
      itemCount: sellableItems.length,
      itemBuilder: (context, index) {
        final item = sellableItems[index]['itemDef'] as Item;
        final quantity = sellableItems[index]['quantity'] as int;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.asset(
              'assets/images/item_${item.code}.png', // アイテムの画像
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
            ),
            title: Text('${item.name} (x$quantity)'),
            subtitle: Text('売却価格: ${item.sellPrice} G'),
            trailing: ElevatedButton(
              onPressed: () async {
                playerStateNotifier.addMoney(item.sellPrice); // お金を増やす
                await inventoryNotifier.removeItem(item.code); // アイテムを減らす
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name}を売却しました！')),
                );
              },
              child: const Text('売却'),
            ),
          ),
        );
      },
    );
  }
}
