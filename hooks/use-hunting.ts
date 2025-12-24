"use client"

/**
 * 狩りシステムのカスタムフック
 * 釣りシステムと同様に、タイマーを使ったイベント処理を含みます。
 */

import { useCallback, useEffect, useRef } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import { HUNTS } from "@/data/game-data"
import type { Hunt } from "@/types/game.types"

/**
 * 狩りシステムを提供するカスタムフック
 */
export function useHunting() {
  const { state, dispatch } = useGame()
  const { addNotification } = useNotifications()

  const encounterTimerRef = useRef<NodeJS.Timeout | null>(null)

  /**
   * 現在の季節で出会える獲物を取得
   */
  const getAvailablePrey = useCallback((): Hunt[] => {
    return Object.values(HUNTS).filter((hunt) => hunt.seasons.includes(state.currentSeason))
  }, [state.currentSeason])

  /**
   * ランダムな獲物を選択
   */
  const selectRandomPrey = useCallback((): Hunt | null => {
    const availablePrey = getAvailablePrey()
    if (availablePrey.length === 0) return null

    const random = Math.random()
    let cumulative = 0

    for (const prey of availablePrey) {
      cumulative += prey.encounterRate
      if (random <= cumulative) {
        return prey
      }
    }

    return availablePrey[0]
  }, [getAvailablePrey])

  /**
   * 狩りを開始
   */
  const startHunting = useCallback(() => {
    dispatch({ type: "START_HUNTING" })
    addNotification("info", "森に入りました...")

    // 3-10秒後にランダムなタイミングで獲物と遭遇します
    const encounterDelay = 3000 + Math.random() * 7000

    encounterTimerRef.current = setTimeout(() => {
      const prey = selectRandomPrey()
      if (prey) {
        dispatch({ type: "ENCOUNTER_PREY", payload: { prey } })
        addNotification("warning", `${prey.name}を発見！追跡を開始してください！`)
      }
    }, encounterDelay)
  }, [dispatch, addNotification, selectRandomPrey])

  /**
   * 獲物を追跡（クリックで進捗を進める）
   */
  const trackPrey = useCallback(() => {
    if (!state.huntingState.currentPrey) return

    dispatch({ type: "TRACK_PREY" })

    if (state.huntingState.trackingProgress >= 90) {
      // 次のトラックで100%になる
      const prey = state.huntingState.currentPrey
      dispatch({ type: "CATCH_PREY" })
      addNotification("success", `${prey.name}を捕まえた！`)
    }
  }, [dispatch, addNotification, state.huntingState])

  /**
   * 狩りを中止
   */
  const stopHunting = useCallback(() => {
    if (encounterTimerRef.current) clearTimeout(encounterTimerRef.current)
    dispatch({ type: "STOP_HUNTING" })
  }, [dispatch])

  // クリーンアップ
  useEffect(() => {
    return () => {
      if (encounterTimerRef.current) clearTimeout(encounterTimerRef.current)
    }
  }, [])

  return {
    huntingState: state.huntingState,
    startHunting,
    trackPrey,
    stopHunting,
    availablePrey: getAvailablePrey(),
  }
}
