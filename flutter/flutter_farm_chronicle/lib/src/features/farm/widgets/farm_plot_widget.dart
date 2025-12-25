// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// データベースのFarmPlotテーブルから生成されたデータクラスをインポートします。
import 'package:flutter_farm_chronicle/src/core/database/app_database.dart';
// アイテム定義をインポートします。
import 'package:flutter_farm_chronicle/src/core/data/item_definitions.dart';
// 農場の区画を管理するNotifierをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/farm_notifier.dart';
// 種選択ダイアログをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/widgets/seed_selection_dialog.dart';

// FarmPlotWidgetは、農場マップ上の1つの区画（マス目）を表示するWidgetです。
// ConsumerWidgetを継承することで、RiverpodのProviderから状態を読み取ったり、アクションを呼び出したりできます。
class FarmPlotWidget extends ConsumerWidget {
  final FarmPlot plot; // このWidgetが表示する区画のデータ
  final int x; // 区画のX座標
  final int y; // 区画のY座標

  // コンストラクタ。表示する区画のデータと座標を受け取ります。
  const FarmPlotWidget({
    super.key,
    required this.plot,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 区画の現在の状態（例: 'empty_soil', 'tilled_soil'）に基づいて、表示する画像や色を決定します。
    String imagePath;
    Color overlayColor = Colors.transparent; // オーバーレイの色（水やりなど）

    // plot.cropCodeがnull（何も植えられていない）の場合、土の状態を表示します。
    if (plot.cropCode == null) {
      // plot.growthStageが0なら空の土、1なら耕された土と仮定します。
      // FarmPlotsテーブルのgrowthStageは、cropCodeがnullの場合、土の状態を表すために使われます。
      imagePath = plot.growthStage == 0
          ? 'assets/images/soil_empty.png' // 空の土の画像
          : 'assets/images/soil_tilled.png'; // 耕された土の画像
    } else {
      // 作物が植えられている場合、作物の成長段階に応じた画像を表示します。
      // アイテム定義から作物の情報を取得します。
      final cropDefinition = allGameItems.firstWhere(
        (item) => item.code == plot.cropCode,
        orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc),
      );

      // 成長段階に応じた画像パスを生成します。
      // 例: 'crop_turnip_stage0.png', 'crop_turnip_stage1.png'
      imagePath = 'assets/images/crop_${cropDefinition.code}_stage${plot.growthStage}.png';
    }

    // GestureDetectorを使って、区画がタップされた時の動作を定義します。
    return GestureDetector(
      onTap: () async {
        // FarmNotifierのインスタンスを取得します。
        final farmNotifier = ref.read(farmNotifierProvider.notifier);

        // 区画の状態に応じてアクションを分岐します。
        if (plot.cropCode == null) {
          // 作物が植えられていない場合
          if (plot.growthStage == 0) {
            // 空の土の場合、耕すアクションを実行します。
            await farmNotifier.tillPlot(x, y);
          } else if (plot.growthStage == 1) {
            // 耕された土の場合、種をまくダイアログを表示します。
            final selectedSeedCode = await showDialog<String?>(
              context: context,
              builder: (context) => const SeedSelectionDialog(),
            );

            // 種が選択された場合、種まきアクションを実行します。
            if (selectedSeedCode != null) {
              await farmNotifier.plantSeed(x, y, selectedSeedCode);
            }
          }
        } else {
          // 作物が植えられている場合
          // アイテム定義から作物の情報を取得します。
          final cropDefinition = allGameItems.firstWhere(
            (item) => item.code == plot.cropCode,
            orElse: () => Item(code: '', name: '', description: '', sellPrice: 0, type: ItemType.misc),
          );

          // 作物が完全に成長しているか確認します。
          if (plot.growthStage != null && cropDefinition.maxGrowthStage != null && plot.growthStage! >= cropDefinition.maxGrowthStage!) {
            // 収穫可能な場合、収穫アクションを実行します。
            await farmNotifier.harvestCrop(x, y);
          } else {
            // まだ成長途中または収穫できない場合、作物の情報などを表示します。
            print('作物が植えられた区画 ($x, $y) がタップされました。作物: ${plot.cropCode}, 成長段階: ${plot.growthStage}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${cropDefinition.name}はまだ成長途中です。')),
            );
          }
        }
      },
      // AspectRatioを使って、区画が常に正方形になるようにします。
      child: AspectRatio(
        aspectRatio: 1.0, // 幅と高さの比率を1:1に設定
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5), // 区画の境界線
            color: Colors.brown.shade300, // デフォルトの土の色
          ),
          child: Stack(
            children: [
              // 区画の画像（土の状態や作物）
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 画像が見つからない場合のエラーハンドリング
                    return Container(
                      color: Colors.red.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          'No Image\n($imagePath)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // オーバーレイ（水やり済み、病気など）
              Positioned.fill(
                child: Container(
                  color: overlayColor,
                ),
              ),
              // デバッグ用に座標を表示
              Align(
                alignment: Alignment.bottomRight,
                child: Text('($x,$y)', style: const TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}