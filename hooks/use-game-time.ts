"use client"

/**
 * ゲーム時間管理のカスタムフック
 * useEffect, useRef, useCallbackを組み合わせて使用
 */

import { useEffect, useRef, useCallback } from "react"
import { useGame } from "@/contexts/game-context"

/**
 * ゲーム内時間を管理するカスタムフック
 * 実時間の10秒 = ゲーム内の1時間として進行
 */
export function useGameTime() {
  const { state, dispatch } = useGame()

  // useRefでインターバルIDを保持
  const intervalRef = useRef<NodeJS.Timeout | null>(null)

  // 時間を進めるコールバック（useCallbackでメモ化）
  const advanceTime = useCallback(() => {
    dispatch({ type: "ADVANCE_TIME" })
  }, [dispatch])

  // useEffectで時間の自動進行を設定
  // useEffectで時間の自動進行を設定
  useEffect(() => {
    // ゲーム設定の速度（gameSpeed）に応じて、時間を進める間隔を計算します
    const interval = 10000 / state.settings.gameSpeed // 基本10秒ごと

    // setIntervalで定期的（intervalミリ秒ごと）にadvanceTimeを実行します
    intervalRef.current = setInterval(advanceTime, interval)

    // クリーンアップ関数:
    // ゲーム速度が変わった時やコンポーネントが消える時に、
    // 古いタイマーをクリアして多重起動を防ぎます。
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
      }
    }
  }, [advanceTime, state.settings.gameSpeed])

  return {
    currentDay: state.currentDay,
    currentHour: state.currentHour,
    currentSeason: state.currentSeason,
  }
}
