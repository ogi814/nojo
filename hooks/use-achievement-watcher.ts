"use client"

import { useEffect, useRef } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import { ACHIEVEMENTS } from "@/data/game-data"

export function useAchievementWatcher() {
  const { state } = useGame()
  const { addNotification } = useNotifications()
  const prevUnlockedRef = useRef<Record<string, number>>({})

  useEffect(() => {
    const currentUnlocked = state.unlockedAchievements ?? {}
    const prevUnlocked = prevUnlockedRef.current

    // 新しく解除された実績を探す
    Object.keys(currentUnlocked).forEach((id) => {
      if (!prevUnlocked[id]) {
        const achievement = ACHIEVEMENTS[id]
        if (achievement) {
          addNotification("success", `実績解除: ${achievement.name}`)
        }
      }
    })

    // 現在の解除済み実績を次の比較のために保存
    prevUnlockedRef.current = currentUnlocked
  }, [state.unlockedAchievements, addNotification])
}
