"use client"

/**
 * ゲームヘッダーコンポーネント
 * 所持金、レベル、時間などの情報を表示
 */

import { memo } from "react"
import { useGame } from "@/contexts/game-context"
import { useGameTime } from "@/hooks/use-game-time"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { ProgressBar } from "@/components/common/progress-bar"

/**
 * 季節を日本語に変換
 */
function getSeasonLabel(season: string): string {
  const labels: Record<string, string> = {
    spring: "春",
    summer: "夏",
    autumn: "秋",
    winter: "冬",
  }
  return labels[season] || season
}

/**
 * 季節の絵文字を取得
 */
function getSeasonEmoji(season: string): string {
  const emojis: Record<string, string> = {
    spring: "🌸",
    summer: "☀️",
    autumn: "🍂",
    winter: "❄️",
  }
  return emojis[season] || "🌿"
}

/**
 * ゲームヘッダーコンポーネント
 */
export const GameHeader = memo(function GameHeader() {
  const { state } = useGame()
  const { currentDay, currentHour, currentSeason } = useGameTime()

  // 経験値の進捗率
  const expProgress = (state.experience / state.experienceToNextLevel) * 100

  return (
    <Card className="bg-card/90 backdrop-blur-sm p-3 sm:p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        {/* 農場名とレベル */}
        <div className="flex items-center gap-3">
          <div>
            <h1 className="text-lg sm:text-xl font-bold text-foreground">ファームライフ</h1>
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="text-xs">
                Lv.{state.farmLevel}
              </Badge>
              <div className="w-20">
                <ProgressBar value={expProgress} colorClass="bg-primary" heightClass="h-1" />
              </div>
            </div>
          </div>
        </div>

        {/* 時間と季節 */}
        <div className="flex items-center gap-2 text-sm">
          <span>{getSeasonEmoji(currentSeason)}</span>
          <span className="font-medium">{getSeasonLabel(currentSeason)}</span>
          <span className="text-muted-foreground">
            {currentDay}日目 {currentHour}:00
          </span>
        </div>

        {/* 所持金 */}
        <div className="flex items-center gap-2">
          <span className="text-xl">💰</span>
          <span className="text-lg font-bold text-farm-gold">{state.money.toLocaleString()}G</span>
        </div>
      </div>
    </Card>
  )
})
