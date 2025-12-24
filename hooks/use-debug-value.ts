"use client"

/**
 * useDebugValueの使用例を示すカスタムフック
 * 
 * React DevTools（ブラウザ拡張機能）でコンポーネントを検査した際に、
 * このフックの状態を分かりやすく表示するための機能です。
 * 開発者向けの機能であり、アプリの動作自体には影響しません。
 */

import { useDebugValue, useMemo } from "react"
import { useGame } from "@/contexts/game-context"

/**
 * ゲームの統計情報を提供し、DevToolsにデバッグ情報を表示するフック
 */
export function useGameStats() {
  const { state } = useGame()

  // 統計情報を計算
  const stats = useMemo(
    () => ({
      money: state.money,
      level: state.farmLevel,
      totalHarvests: state.stats.totalHarvests,
      totalSales: state.stats.totalSales,
      animalsCount: state.animals.length,
      inventoryCount: state.inventory.reduce((sum, item) => sum + item.quantity, 0),
    }),
    [state],
  )

  // useDebugValue: カスタムフックのデバッグ情報をDevToolsに表示します。
  // 第1引数: 表示したい値
  // 第2引数: 表示用のフォーマット関数（オプショナル。計算が重い場合に使います）
  useDebugValue(stats, (s) => `Level ${s.level} | Money: ${s.money}G | Harvests: ${s.totalHarvests}`)

  return stats
}
