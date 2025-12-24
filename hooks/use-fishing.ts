"use client"

/**
 * 釣りシステムのカスタムフック
 * 
 * タイマー処理（魚がかかるまでの待ち時間、逃げるまでの時間）を含む、
 * 少し複雑な非同期処理を扱っています。
 * useRefを使ってタイマーIDを管理している点に注目してください。
 */

import { useCallback, useEffect, useRef } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import { FISH } from "@/data/game-data"
import type { Fish } from "@/types/game.types"

/**
 * 釣りシステムを提供するカスタムフック
 */
export function useFishing() {
  const { state, dispatch } = useGame()
  const { addNotification } = useNotifications()

  // useRef: 再レンダリングを引き起こさずに値を保持できる箱のようなものです。
  // ここでは setTimeout の戻り値（タイマーID）を保存するために使っています。
  // useStateを使うとタイマーセットのたびに再描画されてしまいますが、useRefならされません。
  const biteTimerRef = useRef<NodeJS.Timeout | null>(null)
  const escapeTimerRef = useRef<NodeJS.Timeout | null>(null)

  /**
   * 現在の季節で釣れる魚を取得
   */
  const getAvailableFish = useCallback((): Fish[] => {
    return Object.values(FISH).filter((fish) => fish.seasons.includes(state.currentSeason))
  }, [state.currentSeason])

  /**
   * ランダムな魚を選択（レア度に応じた確率）
   */
  const selectRandomFish = useCallback((): Fish | null => {
    const availableFish = getAvailableFish()
    if (availableFish.length === 0) return null

    const random = Math.random()
    let cumulative = 0

    for (const fish of availableFish) {
      cumulative += fish.catchRate
      if (random <= cumulative) {
        return fish
      }
    }

    // デフォルトで最も一般的な魚を返す
    return availableFish[0]
  }, [getAvailableFish])

  /**
   * 釣りを開始
   */
  const startFishing = useCallback(() => {
    dispatch({ type: "START_FISHING" })
    addNotification("info", "釣りを始めました...")

    // 2-8秒後にランダムで魚がかかる
    const biteDelay = 2000 + Math.random() * 6000

    biteTimerRef.current = setTimeout(() => {
      const fish = selectRandomFish()
      if (fish) {
        dispatch({ type: "FISH_BITE", payload: { fish } })
        addNotification("warning", "魚がかかった！素早くクリック！")

        // 3秒以内にクリックしないと逃げる
        escapeTimerRef.current = setTimeout(() => {
          dispatch({ type: "STOP_FISHING" })
          addNotification("error", "魚に逃げられた...")
        }, 3000)
      }
    }, biteDelay)
  }, [dispatch, addNotification, selectRandomFish])

  /**
   * 魚を釣り上げる
   */
  const catchFish = useCallback(() => {
    if (!state.fishingState.hasBite || !state.fishingState.targetFish) return

    // 逃げるタイマーをクリア
    if (escapeTimerRef.current) {
      clearTimeout(escapeTimerRef.current)
    }

    const fish = state.fishingState.targetFish
    dispatch({ type: "CATCH_FISH" })
    addNotification("success", `${fish.name}を釣り上げた！`)
  }, [dispatch, addNotification, state.fishingState])

  /**
   * 釣りを中止
   */
  const stopFishing = useCallback(() => {
    if (biteTimerRef.current) clearTimeout(biteTimerRef.current)
    if (escapeTimerRef.current) clearTimeout(escapeTimerRef.current)

    dispatch({ type: "STOP_FISHING" })
  }, [dispatch])

  // クリーンアップ
  // useEffectのクリーンアップ関数
  // コンポーネントが画面から消える（アンマウントされる）時に実行されます。
  // 実行中のタイマーがあれば確実に停止し、メモリリークや予期せぬ動作を防ぎます。
  useEffect(() => {
    return () => {
      if (biteTimerRef.current) clearTimeout(biteTimerRef.current)
      if (escapeTimerRef.current) clearTimeout(escapeTimerRef.current)
    }
  }, [])

  return {
    fishingState: state.fishingState,
    startFishing,
    catchFish,
    stopFishing,
    availableFish: getAvailableFish(),
  }
}
