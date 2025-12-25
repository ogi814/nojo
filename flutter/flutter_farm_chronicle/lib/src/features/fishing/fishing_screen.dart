// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// GoRouter（画面遷移）を使うために必要なパッケージをインポートします。
import 'package:go_router/go_router.dart';
// プレイヤーの状態を管理するProviderをインポートします。スタミナ消費のため。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// インベントリの状態を管理するProviderをインポートします。アイテム追加のため。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_notifier.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// ゲーム時間Notifierをインポートします。釣りに時間がかかるため。
import 'package:flutter_farm_chronicle/src/core/providers/game_time_provider.dart';
// Dartの乱数生成器をインポートします。
import 'dart:math';

// FishingScreenは、釣りを行う画面です。
// ConsumerWidgetを継承することで、RiverpodのProviderから必要な状態を読み取ることができます。
class FishingScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const FishingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイヤーの現在のスタミナを監視します。
    final playerStamina = ref.watch(playerStateProvider.select((state) => state.stamina));
    // プレイヤーの状態Notifierのインスタンスを取得します。
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    // インベントリNotifierのインスタンスを取得します。
    final inventoryNotifier = ref.read(inventoryNotifierProvider.notifier);
    // ゲーム時間Notifierのインスタンスを取得します。
    final gameTimeNotifier = ref.read(gameTimeProvider.notifier);

    // 釣りアクションに必要なスタミナと時間を定義します。
    const double staminaCost = 10.0;
    const int timeCostMinutes = 60; // 1時間の釣り

    // 釣れる可能性のある魚のリストを定義します。
    final List<String> possibleFish = ['small_fish', 'medium_fish', 'big_fish'];
    final Random random = Random(); // 乱数生成器

    return Scaffold(
      appBar: AppBar(
        title: const Text('釣り場'), // 画面のタイトル
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 戻るボタン
          onPressed: () => context.pop(), // 前の画面に戻る
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // プレイヤーのスタミナ表示
            Text(
              'スタミナ: ${playerStamina.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // 釣りを始めるボタン
            ElevatedButton.icon(
              icon: const Icon(Icons.phishing),
              label: Text('釣りを始める (${staminaCost.toStringAsFixed(0)}スタミナ消費, ${timeCostMinutes}分経過)'),
              onPressed: playerStamina >= staminaCost
                  ? () async {
                      // スタミナを消費
                      playerStateNotifier.deductStamina(staminaCost);
                      // ゲーム時間を進める
                      for (int i = 0; i < timeCostMinutes; i++) {
                        gameTimeNotifier.advanceTime();
                      }

                      // ランダムに魚を釣る
                      String foundMessage = '何も釣れなかった...';
                      if (random.nextDouble() < 0.7) { // 70%の確率で何か釣れる
                        final String caughtFishCode = possibleFish[random.nextInt(possibleFish.length)];
                        await inventoryNotifier.addItem(caughtFishCode);
                        final itemDef = allGameItems.firstWhere((def) => def.code == caughtFishCode);
                        foundMessage = '${itemDef.name}を釣った！';
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(foundMessage)),
                      );
                    }
                  : null, // スタミナが足りなければボタンを無効化
            ),
            const SizedBox(height: 20),
            const Text('静かな水辺で、大物を狙おう。'),
          ],
        ),
      ),
    );
  }
}
