"use client"

import { useAchievementWatcher } from "@/hooks/use-achievement-watcher"

/**
 * 実績ウォッチャーコンポーネント
 * useAchievementWatcherフックを呼び出すためだけのクライアントコンポーネント
 */
export function AchievementWatcher() {
  useAchievementWatcher()
  return null // このコンポーネントはUIを描画しない
}
