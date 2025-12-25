// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// インベントリの状態を管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';

// SeedSelectionDialogは、プレイヤーがインベントリから種を選択するためのダイアログです。
// ConsumerWidgetを継承することで、RiverpodのProviderからインベントリの状態を読み取ることができます。
class SeedSelectionDialog extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const SeedSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // インベントリの状態を監視し、現在プレイヤーが持っているアイテムのリストを取得します。
    final inventory = ref.watch(inventoryNotifierProvider);

    // インベントリ内のアイテム定義も取得します。
    // TODO: このallGameItemsはデータベースから取得するように変更する必要があります。
    // 現時点では静的なリストから取得します。
    final allItems = allGameItems;

    // インベントリにある種アイテムのみをフィルタリングします。
    final List<Item> availableSeeds = inventory
        .map((invItem) {
          // インベントリのアイテムコードに対応するアイテム定義を探します。
          final itemDef = allItems.firstWhere(
            (def) => def.code == invItem.itemCode,
            // 見つからない場合はnullを返します。
            orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc), // ダミー
          );
          // アイテムが種であり、かつ数量が1以上ある場合のみリストに含めます。
          return itemDef.type == ItemType.seed && invItem.quantity > 0 ? itemDef : null;
        })
        .whereType<Item>() // nullを除外します。
        .toList();

    return AlertDialog(
      title: const Text('植える種を選んでください'),
      content: SizedBox(
        width: double.maxFinite, // ダイアログの幅を最大にする
        child: availableSeeds.isEmpty
            ? const Text('インベントリに種がありません。')
            : ListView.builder(
                shrinkWrap: true, // コンテンツのサイズに合わせて高さを調整
                itemCount: availableSeeds.length,
                itemBuilder: (context, index) {
                  final seed = availableSeeds[index];
                  final quantity = ref.read(inventoryNotifierProvider.notifier).getItemQuantity(seed.code);
                  return ListTile(
                    leading: Image.asset(
                      'assets/images/item_${seed.code}.png', // 種の画像（後で作成）
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.grass), // 画像がない場合の代替
                    ),
                    title: Text('${seed.name} ($quantity)'),
                    subtitle: Text(seed.description),
                    onTap: () {
                      // 種が選択されたら、その種のコードを返してダイアログを閉じます。
                      Navigator.of(context).pop(seed.code);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // キャンセルされた場合はnullを返してダイアログを閉じます。
            Navigator.of(context).pop(null);
          },
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
