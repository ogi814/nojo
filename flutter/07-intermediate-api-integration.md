# Flutter教科書 - 中級編 - 4. API連携 (農場たとえ話・増量版)

あなたの農場も発展し、外部の世界と情報をやり取りする必要が出てきました。例えば、「国の農業データベースにうちの農場の収穫量を報告する」「天気予報サービスから最新の予報を取得する」などです。この章では、外部のサービスと通信するための**API連携**について学びます。

---

## 4.1 APIとHTTP通信 ～外部との手紙のやり取り～

- **API (Application Programming Interface)**: 外部サービスとの**手紙の宛先と書き方のルール**です。「天気予報が欲しいなら、この住所(`URL`)に、この形式(`GET`)で手紙を送ってください」と決められています。
- **HTTP (HyperText Transfer Protocol)**: その手紙を届けるための**郵便システム**そのものです。
- **`http`パッケージ**: Flutterの世界で郵便システムを利用するための、あなたの農場の**郵便局**です。

### 郵便局(httpパッケージ)の設置
`pubspec.yaml`に`http`パッケージを追加し、`flutter pub get`で郵便局を開設します。

### 手紙の種類
- **`GET`リクエスト (情報くださいの手紙)**: 宛先を書いて「この情報をください」とだけ書く、最もシンプルな手紙です。天気予報やニュースの取得などに使います。
- **`POST`リクエスト (情報送りますの手紙)**: 宛先と共に、こちらが伝えたい情報（封筒の中身）を添えて送る手紙です。新しい家畜の情報をデータベースに登録したり、SNSに投稿したりする際に使います。

---

## 4.2 天気予報APIから情報を取得する (GETリクエスト)

例として、外部の天気予報サービス（API）から、明日の天気を取得してみましょう。

### 1. 手紙の準備と投函
郵便局(`http`パッケージ)を使って、指定された宛先(`URL`)へ「情報ください」の`GET`手紙を送ります。

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchWeatherForecast() async {
  // 宛先 (APIエンドポイント)
  final url = Uri.parse('https://api.weather-service.com/forecast');

  try {
    // 郵便局からGET手紙を送り、返事を待つ
    final response = await http.get(url);

    // 手紙が無事に届き、返事が返ってきたかチェック (ステータスコード200は成功)
    if (response.statusCode == 200) {
      // 返信の中身を処理する (次のステップへ)
      // ...
    } else {
      // 宛先不明、サーバーダウンなどで返事が来なかった場合
      throw Exception('天気予報の取得に失敗しました');
    }
  } catch (e) {
    // そもそも手紙を送る過程で問題が起きた場合 (インターネット接続なしなど)
    throw Exception('通信エラーが発生しました: $e');
  }
}
```

### 2. 返信(JSON)の解読と画面表示
外部サービスからの返信は、多くの場合**JSON (JavaScript Object Notation)** という、世界共通のデータ形式で書かれています。これは、構造化された、機械が読みやすい手紙の書き方です。

**返ってきたJSON形式の手紙:**
```json
{
  "date": "2025-12-24",
  "weather": "快晴",
  "temperature": 15.5
}
```

このままではただの文字列なので、Dartの世界で扱えるように**解読 (パース)** する必要があります。

```dart
// response.statusCode == 200 の中身
// 1. 手紙の中身(JSON文字列)を取り出す
final String jsonString = response.body;

// 2. JSON解読機(`jsonDecode`)で、Dartが理解できるMap形式に変換する
final Map<String, dynamic> data = jsonDecode(jsonString);

// 3. Mapから必要な情報を取り出す
final String weather = data['weather'];
return weather; // '快晴'という文字列を返す
```

### 3. `FutureProvider`との連携
この`fetchWeatherForecast`関数は、結果が未来に返ってくる`Future`です。これは、まさに**中級編1で学んだ`FutureProvider`**の出番です。

```dart
// 天気予報チャンネル
final weatherProvider = FutureProvider<String>((ref) async {
  return fetchWeatherForecast(); // 上で定義した関数を呼び出す
});

// UI側
class WeatherDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeather = ref.watch(weatherProvider);

    return asyncWeather.when(
      data: (weather) => Text('明日の天気: $weather', style: TextStyle(fontSize: 24)),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('エラー: $err'),
    );
  }
}
```
`FutureProvider`を使うことで、通信中（`loading`）、成功（`data`）、失敗（`error`）の状態管理を、Flutterが自動的に行ってくれます。

---

## 4.3 エラー処理の実装 ～手紙が届かなかった場合に備える～

郵便にはトラブルがつきものです。
- **宛先が存在しない (`404 Not Found`)**
- **相手の郵便受けがいっぱい (`500 Internal Server Error`)**
- **途中で手紙が紛失する (タイムアウト)**
- **そもそも道が寸断されている (インターネット接続なし)**

堅牢なアプリケーションを作るには、これらの**エラーケース**にきちんと備える必要があります。

`try-catch`ブロックは、こうした郵便事故に対応するための優れた仕組みです。

```dart
try {
  // まずは手紙を送ってみる
  final response = await http.get(url).timeout(const Duration(seconds: 10)); // 10秒待っても返事がなければ諦める
  
  if (response.statusCode == 200) {
    // 成功処理
  } else {
    // サーバー側の問題でエラーになった場合
    throw Exception('サーバーエラー: ${response.statusCode}');
  }
} on TimeoutException {
  // タイムアウトした場合
  throw Exception('通信がタイムアウトしました');
} catch (e) {
  // その他の通信エラー
  throw Exception('予期せぬ通信エラーが発生しました: $e');
}
```
`FutureProvider`は、これらの`throw`された`Exception`を自動的にキャッチし、`error`状態としてUIに通知してくれます。これにより、ユーザーに「現在、天気予報を取得できません。しばらくしてからお試しください」といった親切なメッセージを表示できます。

---

### まとめ

この章では、外部サービスとのAPI連携について、郵便システムに例えて学びました。

- **基本**: APIは「宛先と書き方のルール」、HTTPは「郵便システム」、`http`パッケージは「郵便局」であると理解しました。
- **GETリクエスト**: `http.get()`で「情報ください」の手紙を送り、返事を待つ方法を学びました。
- **JSONパース**: 世界共通のデータ形式`JSON`を、`jsonDecode`を使ってDartの世界の言葉に翻訳する方法を学びました。
- **`FutureProvider`連携**: 非同期通信の状態管理（成功、ローディング、エラー）を`FutureProvider`に任せることで、UIのコードを非常にシンプルに保てることを実感しました。
- **エラー処理**: `try-catch`を使い、様々な通信トラブルに備えることの重要性を学びました。

API連携は、あなたの農場（アプリ）を、単なる自己完結した存在から、外部の世界と繋がり、より豊かで価値あるものへと進化させるための重要な一歩です。
