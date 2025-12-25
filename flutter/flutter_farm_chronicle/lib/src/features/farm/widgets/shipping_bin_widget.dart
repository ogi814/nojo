// FlutterのUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// アイテム売却ダイアログをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/widgets/sell_item_dialog.dart';

// ShippingBinWidgetは、農場に設置される出荷箱のUIです。
// ConsumerWidgetを継承することで、RiverpodのProviderから状態を読み取ることができます。
class ShippingBinWidget extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const ShippingBinWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GestureDetectorを使って、出荷箱がタップされた時の動作を定義します。
    return GestureDetector(
      onTap: () {
        // 出荷箱がタップされたら、アイテム売却ダイアログを表示します。
        showDialog(
          context: context,
          builder: (context) => const SellItemDialog(),
        );
      },
      // 出荷箱の見た目を定義します。
      child: Image.asset(
        'assets/images/shipping_bin.png', // 後で作成する出荷箱の画像
        width: 80, // 幅
        height: 80, // 高さ
        errorBuilder: (context, error, stackTrace) => Container(
          // 画像が見つからない場合のエラー表示
          width: 80,
          height: 80,
          color: Colors.brown,
          child: const Center(
            child: Text(
              '出荷箱',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
