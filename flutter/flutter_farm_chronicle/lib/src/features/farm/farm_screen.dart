// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ゲーム時間システムを管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/core/providers/game_time_provider.dart';
// プレイヤーの状態を管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/features/player/player_state_provider.dart';
// 農場の区画を管理するNotifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/farm_notifier.dart';
// 農場の各区画を表示するWidgetをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/widgets/farm_plot_widget.dart';

// FarmScreenは、ゲームのメイン画面となるWidgetです。
// ConsumerWidgetを継承することで、RiverpodのProvider（金庫番や放送局など）から
// ゲームの状態を読み取ったり、更新したりできるようになります。
class FarmScreen extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const FarmScreen({super.key});

  // `build`メソッドが、このWidgetがどのような見た目を持つかを定義します。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // gameTimeProviderを監視し、現在のゲーム時間を取得します。
    // gameTimeProviderの状態が更新されると、このWidgetは自動的に再描画されます。
    final gameTime = ref.watch(gameTimeProvider);
    // playerStateProviderを監視し、現在のプレイヤーの状態（所持金、スタミナ）を取得します。
    // playerStateProviderの状態が更新されると、このWidgetは自動的に再描画されます。
    final playerState = ref.watch(playerStateProvider);
    // farmNotifierProviderを監視し、農場のすべての区画データを取得します。
    // 農場の区画データが更新されると、このWidgetは自動的に再描画されます。
    final farmPlots = ref.watch(farmNotifierProvider);

    // Scaffoldは、アプリの基本的な骨格（屋根、壁、床など）を提供するWidgetです。
    // ここでは、AppBar（画面上部のバー）はなしで、body（本体）だけを使います。
    return Scaffold(
      // AppBarは、画面上部に表示されるバーです。
      appBar: AppBar(
        title: const Text('フラッター農場物語'), // アプリのタイトル
        actions: [
          // インベントリ画面へ遷移するためのアイコンボタン
          IconButton(
            icon: const Icon(Icons.backpack), // リュックサックのアイコン
            onPressed: () {
              // GoRouterを使ってインベントリ画面へ遷移します。
              context.go('/inventory');
            },
          ),
        ],
      ),
      // bodyプロパティに、画面の主要なコンテンツを配置します。
      // Stackを使うことで、複数のWidgetを重ねて表示できます。
      // これは、農場の背景の上に、プレイヤーキャラクターやUI要素を配置するのに便利です。
      body: Stack(
        children: [
          // 1. 農場の背景画像
          // Image.assetを使って、プロジェクト内の画像ファイルを表示します。
          // BoxFit.coverを指定することで、画像が画面全体を覆うように拡大・縮小されます。
          Positioned.fill( // 画面全体に広がるように配置
            child: Image.asset(
              'assets/images/farm_background.png', // 後で作成する背景画像のパス
              fit: BoxFit.cover, // 画面いっぱいに表示
            ),
          ),

          // 2. 農場のグリッド表示
          // Centerでグリッドを画面中央に配置します。
          Center(
            child: AspectRatio(
              aspectRatio: farmGridSizeX / farmGridSizeY, // グリッドの縦横比を設定
              child: GridView.builder(
                // GridView.builderは、大量のアイテムを効率的に表示するためのWidgetです。
                // ここでは、農場の区画をグリッド状に表示します。
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: farmGridSizeX, // 横方向の区画数
                  childAspectRatio: 1.0, // 各区画の縦横比を1:1（正方形）に設定
                  crossAxisSpacing: 2.0, // 区画間の横方向のスペース
                  mainAxisSpacing: 2.0, // 区画間の縦方向のスペース
                ),
                itemCount: farmPlots.length, // 表示する区画の総数
                itemBuilder: (context, index) {
                  // farmPlotsリストから現在の区画データを取得します。
                  final plot = farmPlots[index];
                  // FarmPlotWidgetを使って、各区画を表示します。
                  return FarmPlotWidget(
                    plot: plot,
                    x: plot.x,
                    y: plot.y,
                  );
                },
              ),
            ),
          ),

          // 3. プレイヤーキャラクター
          // 仮のプレイヤーキャラクターとして、シンプルな画像を配置します。
          // Alignを使って、画面の下中央に配置します。
          Align(
            alignment: Alignment.bottomCenter, // 画面の下中央に配置
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0), // 少し上にずらす
              child: Image.asset(
                'assets/images/player_sprite.png', // 後で作成するプレイヤー画像のパス
                width: 64, // 幅
                height: 64, // 高さ
              ),
            ),
          ),

          // 4. 出荷箱
          // 画面の右下に固定で配置します。
          Align(
            alignment: Alignment.bottomRight, // 画面の右下に配置
            child: Padding(
              padding: const EdgeInsets.all(16.0), // 周囲にパディング
              child: ShippingBinWidget(), // 出荷箱Widget
            ),
          ),

          // 5. UI要素（ゲーム時間、プレイヤー情報など）
          // 画面上部にゲーム時間とプレイヤー情報を表示します。
          Align(
            alignment: Alignment.topCenter, // 画面の上中央に配置
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0), // 少し下にずらす
              child: Column(
                mainAxisSize: MainAxisSize.min, // Columnのサイズを内容に合わせる
                children: [
                  Text(
                    gameTime.toString(), // gameTimeProviderから取得した時間を表示
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white, // 文字色を白に
                          backgroundColor: Colors.black54, // 背景を半透明の黒に
                        ),
                  ),
                  const SizedBox(height: 8), // 少しスペースを空ける
                  Text(
                    playerState.toString(), // playerStateProviderから取得したプレイヤー情報を表示
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white, // 文字色を白に
                          backgroundColor: Colors.black54, // 背景を半透明の黒に
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 所持金とスタミナを操作するための仮のFloatingActionButtonです。
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // 下に寄せる
        children: [
          FloatingActionButton(
            heroTag: 'add_money',
            onPressed: () {
              // playerStateProviderのNotifier（プレイヤー情報管理の専門家）を呼び出し、
              // addMoneyメソッドを実行して所持金を100G増やします。
              ref.read(playerStateProvider.notifier).addMoney(100);
            },
            child: const Icon(Icons.attach_money), // お金アイコン
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'deduct_stamina',
            onPressed: () {
              // playerStateProviderのNotifierを呼び出し、
              // deductStaminaメソッドを実行してスタミナを10.0減らします。
              ref.read(playerStateProvider.notifier).deductStamina(10.0);
            },
            child: const Icon(Icons.directions_run), // 走るアイコン（スタミナ消費）
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'add_seed',
            onPressed: () {
              // インベントリNotifierを呼び出し、カブの種を10個追加します。
              ref.read(inventoryNotifierProvider.notifier).addItem('turnip_seed', amount: 10);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('カブの種を10個手に入れました！')),
              );
            },
            child: const Icon(Icons.grass), // 草のアイコン（種）
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'open_shop',
            onPressed: () {
              // GoRouterを使って店画面へ遷移します。
              context.go('/shop');
            },
            child: const Icon(Icons.store), // 店のアイコン
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'open_cooking',
            onPressed: () {
              // GoRouterを使って調理画面へ遷移します。
              context.go('/cooking');
            },
            child: const Icon(Icons.kitchen), // キッチンアイコン
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'open_forest',
            onPressed: () {
              // GoRouterを使って森の探索画面へ遷移します。
              context.go('/forest');
            },
            child: const Icon(Icons.forest), // 森のアイコン
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'open_fishing',
            onPressed: () {
              // GoRouterを使って釣り画面へ遷移します。
              context.go('/fishing');
            },
            child: const Icon(Icons.phishing), // 釣りのアイコン
          ),
          const SizedBox(height: 10), // ボタン間のスペース
          FloatingActionButton(
            heroTag: 'open_animal_farm',
            onPressed: () {
              // GoRouterを使って動物小屋画面へ遷移します。
              context.go('/animal_farm');
            },
            child: const Icon(Icons.pets), // ペットのアイコン
          ),
        ],
      ),
    );
  }
}
