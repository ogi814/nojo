// Flutterの基本的なUI部品を使うために必要なパッケージをインポートします。
import 'package:flutter/material.dart';
// Riverpod（状態管理）を使うために必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 先ほど作成したGoRouterの設定ファイルをインポートします。
import 'package:flutter_farm_chronicle/src/core/router/app_router.dart';
// ゲームの初期化処理を管理するProviderをインポートします。
import 'package:flutter_farm_chronicle/src/core/providers/game_initializer_provider.dart';

// アプリケーションが起動する一番最初の入口です。
void main() {
  // ProviderScopeでアプリ全体を囲むことで、
  // アプリ内のどこからでもRiverpodのProvider（金庫番など）にアクセスできるようになります。
  runApp(const ProviderScope(child: MyApp()));
}

// MyAppは、我々のアプリの最も大外の骨格となるWidgetです。
class MyApp extends ConsumerWidget {
  // コンストラクタ。`super.key`はお作法のようなものです。
  const MyApp({super.key});

  // `build`メソッドが、このWidgetがどのような見た目を持つかを定義します。
  // `ConsumerWidget`なので、`WidgetRef`（トランシーバー）が使えます。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // gameInitializerProviderを監視し、ゲームの初期化状態を取得します。
    // 初期化が完了するまではローディング画面を表示します。
    final initializationState = ref.watch(gameInitializerProvider);

    // initializationStateの状態に応じて表示を切り替えます。
    return initializationState.when(
      // 初期化処理がまだ進行中の場合
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // ローディングインジケーターを表示
          ),
        ),
      ),
      // 初期化処理でエラーが発生した場合
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('エラーが発生しました: $err'), // エラーメッセージを表示
          ),
        ),
      ),
      // 初期化処理が正常に完了した場合
      data: (data) {
        // MaterialApp.routerを使い、GoRouterと連携したアプリケーションを構築します。
        return MaterialApp.router(
          // routerConfigに、先ほど作成したルーターのインスタンスを渡します。
          // これにより、アプリ全体の画面遷移がGoRouterによって管理されるようになります。
          routerConfig: router,
          
          // アプリのタイトル。OSのタスクスイッチャーなどで表示されます。
          title: 'Flutter Farm Chronicle',
          
          // アプリ全体のテーマ（デザインの統一感）を設定します。
          theme: ThemeData(
            // プライマリーカラー（アプリの基調となる色）を緑に設定します。
            primarySwatch: Colors.green,
            // 全体のフォントファミリーを指定します。
            // TODO: 今後、GoogleFontsなどを使って、ゲームらしいドット絵フォントを導入します。
            fontFamily: 'DotGothic16',
          ),
          
          // デバッグ時に表示される右上の「DEBUG」バナーを非表示にします。
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
