// Riverpodの状態管理に必要なパッケージをインポートします。
import 'package:flutter_riverpod/flutter_riverpod.dart';

// プレイヤーの現在の状態（所持金、スタミナなど）を保持する不変（immutable）なクラスです。
// このクラスのインスタンスが、プレイヤーの現在の状況を表します。
class PlayerState {
  final int money; // プレイヤーの所持金
  final double stamina; // プレイヤーの現在のスタミナ（最大100.0）

  // コンストラクタ。PlayerStateの新しいインスタンスを作成します。
  PlayerState({
    required this.money,
    required this.stamina,
  });

  // 現在のPlayerStateオブジェクトの値を基に、一部のプロパティだけを変更した
  // 新しいPlayerStateオブジェクトを作成するための便利なメソッドです。
  // これにより、状態の変更を安全に行うことができます（不変性を保つため）。
  PlayerState copyWith({
    int? money,
    double? stamina,
  }) {
    return PlayerState(
      money: money ?? this.money,
      stamina: stamina ?? this.stamina,
    );
  }

  // PlayerStateオブジェクトを文字列として表現するためのメソッドです。
  // デバッグやUI表示に便利です。
  @override
  String toString() {
    return '所持金: $money G, スタミナ: ${stamina.toStringAsFixed(1)}';
  }
}

// プレイヤーの状態を管理するStateNotifierクラスです。
// このクラスが、PlayerStateの状態を保持し、所持金の増減やスタミナの管理ロジックを扱います。
class PlayerStateNotifier extends StateNotifier<PlayerState> {
  // コンストラクタ。初期のプレイヤー状態を設定します。
  // ゲーム開始時は所持金0、スタミナ満タン（100.0）です。
  PlayerStateNotifier() : super(PlayerState(money: 0, stamina: 100.0));

  // 所持金を増やすメソッドです。
  void addMoney(int amount) {
    // 現在の所持金に指定された金額を加算し、新しい状態として更新します。
    state = state.copyWith(money: state.money + amount);
  }

  // 所持金を減らすメソッドです。
  void deductMoney(int amount) {
    // 現在の所持金から指定された金額を減算します。
    // 所持金がマイナスにならないように、0を下回る場合は0に設定します。
    state = state.copyWith(money: (state.money - amount).clamp(0, double.infinity).toInt());
  }

  // スタミナを減らすメソッドです。
  void deductStamina(double amount) {
    // 現在のスタミナから指定された量を減算します。
    // スタミナが0を下回らないように、0にクランプします。
    state = state.copyWith(stamina: (state.stamina - amount).clamp(0.0, 100.0));
  }

  // スタミナを回復するメソッドです。
  void restoreStamina(double amount) {
    // 現在のスタミナに指定された量を加算します。
    // スタミナが最大値（100.0）を超えないように、100.0にクランプします。
    state = state.copyWith(stamina: (state.stamina + amount).clamp(0.0, 100.0));
  }

  // スタミナを最大値まで回復するメソッドです（例: 睡眠後）。
  void resetStamina() {
    state = state.copyWith(stamina: 100.0);
  }
}

// PlayerStateNotifierのインスタンスを提供するStateNotifierProviderです。
// これにより、アプリ内のどこからでもプレイヤーの現在の状態とその操作ロジックにアクセスできます。
final playerStateProvider = StateNotifierProvider<PlayerStateNotifier, PlayerState>((ref) {
  // PlayerStateNotifierの新しいインスタンスを作成して返します。
  return PlayerStateNotifier();
});
