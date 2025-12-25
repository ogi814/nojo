// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// GoRouter（画面遷移）を使うために必要なパッケージをインポートします。
import 'package:go_router/go_router.dart';
// 動物の状態を管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/features/animal_farm/animal_notifier.dart';
// データベースのAnimalsテーブルから生成されたデータクラスをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// プレイヤーの状態を管理するProviderをインポートします。所持金のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。餌の確認のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';

// AnimalFarmScreenは、動物の飼育を行う画面です。
// ConsumerWidgetを継承することで、RiverpodのProviderから必要な状態を読み取ることができます。
class AnimalFarmScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const AnimalFarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 飼育している動物のリストを監視します。
    final animals = ref.watch(animalNotifierProvider);
    // プレイヤーの所持金を監視します。
    final playerMoney = ref.watch(playerStateProvider.select((state) => state.money));
    // インベントリの状態を監視します。
    final inventory = ref.watch(inventoryNotifierProvider);

    // AnimalNotifierのインスタンスを取得します。
    final animalNotifier = ref.read(animalNotifierProvider.notifier);
    // インベントリNotifierのインスタンスを取得します。
    final inventoryNotifier = ref.read(inventoryNotifierProvider.notifier);

    // 動物の餌を持っているか確認します。
    final hasAnimalFeed = inventoryNotifier.hasItem('animal_feed');

    return Scaffold(
      appBar: AppBar(
        title: const Text('動物小屋'), // 画面のタイトル
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 戻るボタン
          onPressed: () => context.pop(), // 前の画面に戻る
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
          // 動物購入ボタン
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle),
              label: const Text('新しい動物を購入する'),
              onPressed: () {
                // 動物購入ダイアログを表示します。
                _showBuyAnimalDialog(context, ref);
              },
            ),
          ),
          // 飼育している動物の一覧
          Expanded(
            child: animals.isEmpty
                ? const Center(
                    child: Text(
                      'まだ動物を飼っていません。',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final animalType = allAnimalTypes.firstWhere((type) => type.code == animal.typeCode);
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/animal_${animal.typeCode}.png', // 動物の画像
                            width: 48,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 48),
                          ),
                          title: Text('${animal.name} (${animalType.name})'),
                          subtitle: Text('なかよし度: ${animal.friendship}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 餌やりボタン
                              IconButton(
                                icon: const Icon(Icons.restaurant),
                                onPressed: hasAnimalFeed
                                    ? () async {
                                        await animalNotifier.feedAnimal(animal.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${animal.name}に餌をやりました！')),
                                        );
                                      }
                                    : null, // 餌がなければ無効化
                              ),
                              // なでるボタン
                              IconButton(
                                icon: const Icon(Icons.favorite),
                                onPressed: () async {
                                  await animalNotifier.petAnimal(animal.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${animal.name}をなでました！')),
                                  );
                                },
                              ),
                              // 生産物収集ボタン
                              IconButton(
                                icon: const Icon(Icons.egg), // 生産物に応じたアイコンに後で変更
                                onPressed: () async {
                                  await animalNotifier.collectProduct(animal.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${animal.name}から${allGameItems.firstWhere((item) => item.code == animalType.productCode).name}を収集しました！')),
                                  );
                                },
                              ),
                            ],
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

  // 動物購入ダイアログを表示するメソッド
  void _showBuyAnimalDialog(BuildContext context, WidgetRef ref) {
    final playerMoney = ref.read(playerStateProvider.select((state) => state.money));
    final animalNotifier = ref.read(animalNotifierProvider.notifier);
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('動物を購入する'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 動物の種類選択
              ...allAnimalTypes.map((animalType) {
                final canAfford = playerMoney >= animalType.buyPrice;
                return ListTile(
                  leading: Image.asset(
                    'assets/images/animal_${animalType.code}.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets),
                  ),
                  title: Text('${animalType.name} (${animalType.buyPrice} G)'),
                  trailing: ElevatedButton(
                    onPressed: canAfford
                        ? () async {
                            // 名前入力ダイアログを表示
                            final String? animalName = await _showAnimalNameDialog(context, nameController);
                            if (animalName != null && animalName.isNotEmpty) {
                              await animalNotifier.addAnimal(animalType.code, animalName);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${animalName}を購入しました！')),
                              );
                              Navigator.of(context).pop(); // 購入ダイアログを閉じる
                            }
                          }
                        : null,
                    child: const Text('購入'),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text('現在の所持金: $playerMoney G'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  // 動物の名前入力ダイアログを表示するメソッド
  Future<String?> _showAnimalNameDialog(BuildContext context, TextEditingController controller) {
    controller.clear(); // 前回の入力をクリア
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('動物の名前を入力'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '名前'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('決定'),
            ),
          ],
        );
      },
    );
  }
}
