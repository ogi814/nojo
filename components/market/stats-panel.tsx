"use client"

/**
 * 統計パネルコンポーネント
 * ゲームの統計情報を表示
 */

import { memo } from "react"
import { useGame } from "@/contexts/game-context"
import { useGameStats } from "@/hooks/use-debug-value"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ProgressBar } from "@/components/common/progress-bar"

/**
 * 統計パネルコンポーネント
 */
export const StatsPanel = memo(function StatsPanel() {
  const { state } = useGame()
  // useDebugValueを使用したカスタムフック（DevToolsでデバッグ情報表示）
  const stats = useGameStats()

  // プレイ時間のフォーマット
  // 秒数を「X時間Y分」または「Y分」の形式に変換するヘルパー関数です。
  const formatPlayTime = (seconds: number): string => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    return hours > 0 ? `${hours}時間${minutes}分` : `${minutes}分`
  }

  // 経験値進捗
  const expProgress = (state.experience / state.experienceToNextLevel) * 100

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg flex items-center gap-2">
          <span>📊</span>
          <span>統計情報</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* レベル情報 */}
        <div className="p-3 rounded-lg bg-muted/50">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm font-medium">農場レベル</span>
            <span className="text-2xl font-bold text-primary">Lv.{state.farmLevel}</span>
          </div>
          <div className="space-y-1">
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>経験値</span>
              <span>
                {state.experience} / {state.experienceToNextLevel}
              </span>
            </div>
            <ProgressBar value={expProgress} colorClass="bg-primary" heightClass="h-2" />
          </div>
        </div>

        {/* 統計グリッド */}
        <div className="grid grid-cols-2 gap-3">
          <StatCard icon="🌾" label="総収穫数" value={stats.totalHarvests} />
          <StatCard icon="💰" label="総売上" value={`${stats.totalSales.toLocaleString()}G`} />
          <StatCard icon="🐟" label="釣った魚" value={state.stats.totalFishCaught} />
          <StatCard icon="🦌" label="狩りの成果" value={state.stats.totalHunts} />
          <StatCard icon="🐄" label="飼育動物" value={stats.animalsCount} />
          <StatCard icon="📦" label="所持品" value={stats.inventoryCount} />
        </div>

        {/* プレイ時間 */}
        <div className="p-3 rounded-lg bg-muted/50 text-center">
          <span className="text-sm text-muted-foreground">プレイ時間: </span>
          <span className="font-medium">{formatPlayTime(state.stats.playTime)}</span>
        </div>
      </CardContent>
    </Card>
  )
})

/**
 * 統計カードコンポーネント
 */
const StatCard = memo(function StatCard({
  icon,
  label,
  value,
}: {
  icon: string
  label: string
  value: string | number
}) {
  return (
    <div className="p-3 rounded-lg border bg-card text-center">
      <span className="text-xl">{icon}</span>
      <p className="text-xs text-muted-foreground mt-1">{label}</p>
      <p className="font-bold text-lg">{value}</p>
    </div>
  )
})
