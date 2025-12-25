// GoRouterパッケージを利用するために必要な部品をインポートします。
import 'package:go_router/go_router.dart';
// 作成した農場画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/farm/farm_screen.dart';
// 作成したインベントリ画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/inventory/inventory_screen.dart';
// 作成した店画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/shop/shop_screen.dart';
// 作成した調理画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/cooking/cooking_screen.dart';
// 作成した森の探索画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/exploration/forest_screen.dart';
// 作成した釣り画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/fishing/fishing_screen.dart';
// 作成した動物小屋画面のファイルをインポートします。
import 'package:flutter_farm_chronicle/src/features/animal_farm/animal_farm_screen.dart';

// GoRouterの設定を保持するインスタンスを作成します。
// これが、我々の農場アプリのすべての「道」と「住所」が書かれた、中央管理の地図になります。
final router = GoRouter(
  // アプリが最初に表示する画面のパス（住所）を指定します。
  initialLocation: '/farm',

  // `routes`プロパティに、アプリ内のすべての画面へのルート（道）をリスト形式で定義していきます。
  routes: [
    // GoRouteは、一つの画面へのルート情報を定義します。
    GoRoute(
      // path: この画面の住所。
      path: '/farm',
      // builder: この住所にアクセスが来た時に、どの画面(Widget)を表示するかを定義します。
      // ここで、先ほど作成したFarmScreenを表示するように設定します。
      builder: (context, state) => const FarmScreen(),
    ),
    // インベントリ画面へのルートを定義します。
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    // 店画面へのルートを定義します。
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    // 調理画面へのルートを定義します。
    GoRoute(
      path: '/cooking',
      builder: (context, state) => const CookingScreen(),
    ),
    // 森の探索画面へのルートを定義します。
    GoRoute(
      path: '/forest',
      builder: (context, state) => const ForestScreen(),
    ),
    // 釣り画面へのルートを定義します。
    GoRoute(
      path: '/fishing',
      builder: (context, state) => const FishingScreen(),
    ),
    // 動物小屋画面へのルートを定義します。
    GoRoute(
      path: '/animal_farm',
      builder: (context, state) => const AnimalFarmScreen(),
    ),
    // TODO: 今後、マップ画面('/map')などのルートをここに追加していきます。
  ],
);
