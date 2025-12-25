// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Dartのタイマー機能を使うためにインポートします。
import 'dart:async';

// ゲーム内の季節を表す列挙型（enum）を定義します。
// 春、夏、秋、冬の4つの季節があります。
enum Season {
  spring, // 春
  summer, // 夏
  autumn, // 秋
  winter, // 冬
}

// ゲーム内の時間状態を保持する不変（immutable）なクラスです。
// このクラスのインスタンスが、現在のゲームの日付や時刻、季節を表します。
class GameTime {
  final int day; // 現在の日（1〜30）
  final int hour; // 現在の時（0〜23）
  final int minute; // 現在の分（0〜59）
  final Season season; // 現在の季節

  // コンストラクタ。GameTimeの新しいインスタンスを作成します。
  GameTime({
    required this.day,
    required this.hour,
    required this.minute,
    required this.season,
  });

  // 現在のGameTimeオブジェクトの値を基に、一部のプロパティだけを変更した
  // 新しいGameTimeオブジェクトを作成するための便利なメソッドです。
  // これにより、状態の変更を安全に行うことができます（不変性を保つため）。
  GameTime copyWith({
    int? day,
    int? hour,
    int? minute,
    Season? season,
  }) {
    return GameTime(
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      season: season ?? this.season,
    );
  }

  // GameTimeオブジェクトを文字列として表現するためのメソッドです。
  // デバッグやUI表示に便利です。
  @override
  String toString() {
    // 時と分を2桁表示にするためのフォーマット
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '${season.name} ${day}日目 ${formattedHour}:${formattedMinute}';
  }
}

// ゲーム時間を管理するStateNotifierクラスです。
// このクラスが、GameTimeの状態を保持し、時間の進行ロジックを管理します。
class GameTimeNotifier extends StateNotifier<GameTime> {
  // コンストラクタ。初期のゲーム時間を設定します。
  // 農場ゲームは通常、春の1日目、午前6時から始まります。
  GameTimeNotifier()
      : super(GameTime(day: 1, hour: 6, minute: 0, season: Season.spring)) {
    // Notifierが作成されたらすぐにタイマーを開始します。
    startTimer();
  }

  // ゲーム時間を自動で進めるためのタイマーです。
  Timer? _timer;

  // ゲーム時間を1分進めるメソッドです。
  void advanceTime() {
    // 現在のゲーム時間を取得します。
    GameTime currentTime = state;

    // 分を1進めます。
    int newMinute = currentTime.minute + 1;
    int newHour = currentTime.hour;
    int newDay = currentTime.day;
    Season newSeason = currentTime.season;

    // 分が60になったら、時間を1進めて分を0に戻します。
    if (newMinute >= 60) {
      newMinute = 0;
      newHour++;
    }

    // 時間が24になったら、日を1進めて時間を0に戻します。
    if (newHour >= 24) {
      newHour = 0;
      newDay++;
      // 日が変わったら、その日のイベントなどをトリガーするロジックをここに追加できます。
    }

    // 日が31になったら、季節を1進めて日を1に戻します。
    if (newDay >= 31) {
      newDay = 1;
      // 季節を次の季節に進めます。冬の次は春に戻ります。
      newSeason = Season.values[(newSeason.index + 1) % Season.values.length];
      // 季節が変わったら、その季節のイベントなどをトリガーするロジックをここに追加できます。
    }

    // 新しいゲーム時間で状態を更新します。
    // `state`プロパティに新しいGameTimeオブジェクトを代入することで、
    // このProviderを監視しているWidgetが自動的に再描画されます。
    state = currentTime.copyWith(
      day: newDay,
      hour: newHour,
      minute: newMinute,
      season: newSeason,
    );
  }

  // ゲーム時間を自動で進めるタイマーを開始するメソッドです。
  void startTimer() {
    _timer?.cancel(); // 既存のタイマーがあればキャンセルします。
    // 1秒ごとにゲーム時間を1分進めます。
    // ここでDurationの値を調整することで、ゲーム内の時間の流れの速さを変更できます。
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      advanceTime();
    });
  }

  // タイマーを停止するメソッドです。
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Notifierが破棄されるときにタイマーも停止するようにします。
  // これにより、アプリが閉じられたり、Notifierが不要になったりした際に、
  // 無駄なタイマーが残り続けるのを防ぎます。
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// GameTimeNotifierのインスタンスを提供するStateNotifierProviderです。
// これにより、アプリ内のどこからでも現在のゲーム時間とその操作ロジックにアクセスできます。
final gameTimeProvider = StateNotifierProvider<GameTimeNotifier, GameTime>((ref) {
  // GameTimeNotifierの新しいインスタンスを作成して返します。
  return GameTimeNotifier();
});
