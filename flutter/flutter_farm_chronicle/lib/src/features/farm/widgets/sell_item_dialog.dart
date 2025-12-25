// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// プレイヤーの状態を管理するProviderをインポートします。所持金の増減のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。アイテムの追加・削除のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';

// SellItemDialogは、プレイヤーがインベントリからアイテムを売却するためのダイアログです。
// ConsumerWidgetを継承することで、RiverpodのProviderから必要な状態を読み取ることができます。
class SellItemDialog extends ConsumerStatefulWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const SellItemDialog({super.key});

  @override
  ConsumerState<SellItemDialog> createState() => _SellItemDialogState();
}

class _SellItemDialogState extends ConsumerState<SellItemDialog> {
  String? _selectedItemCode; // 選択中のアイテムコード
  int _quantityToSell = 1; // 売却する数量

  @override
  Widget build(BuildContext context) {
    // インベントリの状態を監視します。
    final inventory = ref.watch(inventoryNotifierProvider);
    // インベントリNotifierのインスタンスを取得します。
    final inventoryNotifier = ref.read(inventoryNotifierProvider.notifier);
    // プレイヤーの状態Notifierのインスタンスを取得します。
    final playerStateNotifier = ref.read(playerStateProvider.notifier);

    // すべてのアイテム定義を取得します。
    final allItems = allGameItems;

    // 売却可能なアイテム（インベントリにある作物や料理など）をフィルタリングします。
    final List<Map<String, dynamic>> sellableItems = inventory
        .map((invItem) {
          final itemDef = allItems.firstWhere(
            (def) => def.code == invItem.itemCode,
            orElse: () => Item(code: '', name: '不明なアイテム', description: '', sellPrice: 0, type: ItemType.misc),
          );
          // 種や土の状態は売却できないと仮定します。
          if ((itemDef.type == ItemType.crop || itemDef.type == ItemType.dish || itemDef.type == ItemType.animalProduct || itemDef.type == ItemType.fish || itemDef.type == ItemType.material) && invItem.quantity > 0) {
            return {'itemDef': itemDef, 'quantity': invItem.quantity};
          }
          return null;
        })
        .whereType<Map<String, dynamic>>() // nullを除外します。
        .toList();

    // 選択中のアイテムの定義と数量を取得します。
    final selectedItem = _selectedItemCode != null
        ? sellableItems.firstWhere(
            (item) => (item['itemDef'] as Item).code == _selectedItemCode,
            orElse: () => {'itemDef': null, 'quantity': 0},
          )
        : null;
    final selectedItemDef = selectedItem?['itemDef'] as Item?;
    final maxQuantity = selectedItem?['quantity'] as int? ?? 0;
    final currentSellPrice = selectedItemDef != null ? selectedItemDef.sellPrice * _quantityToSell : 0;

    return AlertDialog(
      title: const Text('アイテムを売却する'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 売却アイテム選択ドロップダウン
            DropdownButtonFormField<String>(
              value: _selectedItemCode,
              hint: const Text('アイテムを選択'),
              items: sellableItems.map((item) {
                final itemDef = item['itemDef'] as Item;
                final quantity = item['quantity'] as int;
                return DropdownMenuItem(
                  value: itemDef.code,
                  child: Text('${itemDef.name} (x$quantity)'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItemCode = value;
                  _quantityToSell = 1; // アイテム選択時に数量をリセット
                });
              },
            ),
            if (_selectedItemCode != null) ...[
              const SizedBox(height: 16),
              // 売却数量スライダー
              Text('売却数量: $_quantityToSell (合計: $currentSellPrice G)'),
              Slider(
                value: _quantityToSell.toDouble(),
                min: 1,
                max: maxQuantity.toDouble(),
                divisions: maxQuantity > 1 ? maxQuantity - 1 : 1,
                label: _quantityToSell.toString(),
                onChanged: (value) {
                  setState(() {
                    _quantityToSell = value.toInt();
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // キャンセル
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _selectedItemCode != null && _quantityToSell > 0
              ? () async {
                  if (selectedItemDef != null) {
                    // アイテムをインベントリから削除
                    await inventoryNotifier.removeItem(_selectedItemCode!, amount: _quantityToSell);
                    // 所持金を増やす
                    playerStateNotifier.addMoney(currentSellPrice);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${selectedItemDef.name}を$_quantityToSell個売却し、$currentSellPrice Gを得ました！')),
                    );
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  }
                }
              : null, // アイテムが選択されていないか数量が0の場合は無効化
          child: const Text('売却'),
        ),
      ],
    );
  }
}
