"use client"

/**
 * 狩りエリアコンポーネント
 * 狩りのゲームプレイを提供
 */

import { memo, useCallback, useEffect, useRef, useState } from "react"
import { useHunting } from "@/hooks/use-hunting"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { ProgressBar } from "@/components/common/progress-bar"
import { cn } from "@/lib/utils"

/**
 * 難易度に応じた色を取得
 */
function getDifficultyColor(difficulty: number): string {
  if (difficulty <= 3) return "text-farm-grass"
  if (difficulty <= 6) return "text-farm-gold"
  return "text-destructive"
}

/**
 * 難易度のラベル
 */
function getDifficultyLabel(difficulty: number): string {
  if (difficulty <= 3) return "簡単"
  if (difficulty <= 6) return "普通"
  if (difficulty <= 8) return "難しい"
  return "極難"
}

/**
 * 狩りエリアコンポーネント
 */
export const HuntingArea = memo(function HuntingArea() {
  const { huntingState, startHunting, trackPrey, stopHunting, availablePrey } = useHunting()

  // クリック連打防止用の状態
  // 追跡ボタンの連打を防ぐためのフラグとタイマーIDを管理します。
  const [isTracking, setIsTracking] = useState(false)
  const trackingTimeoutRef = useRef<NodeJS.Timeout | null>(null)

  // 狩り開始ハンドラ
  const handleStartHunting = useCallback(() => {
    startHunting()
  }, [startHunting])

  // 追跡ハンドラ（連打対策付き）
  // 連続クリックによる過剰な処理を防ぐため、一度クリックしたら300ms間クリックできないように制御しています。
  const handleTrack = useCallback(() => {
    if (isTracking) return

    setIsTracking(true)
    trackPrey()

    // 300ms後に再度クリック可能にする
    trackingTimeoutRef.current = setTimeout(() => {
      setIsTracking(false)
    }, 300)
  }, [trackPrey, isTracking])

  // 中止ハンドラ
  const handleStopHunting = useCallback(() => {
    stopHunting()
  }, [stopHunting])

  // クリーンアップ
  useEffect(() => {
    return () => {
      if (trackingTimeoutRef.current) {
        clearTimeout(trackingTimeoutRef.current)
      }
    }
  }, [])

  return (
    <div className="space-y-4">
      {/* 狩りエリアカード */}
      <Card className="bg-card/80 backdrop-blur-sm overflow-hidden">
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <span>🌲</span>
            <span>森</span>
          </CardTitle>
          <CardDescription>森の中で獲物を追いかけよう</CardDescription>
        </CardHeader>
        <CardContent>
          {/* 森のビジュアル */}
          <div
            className={cn(
              "relative h-48 rounded-lg overflow-hidden mb-4",
              "bg-gradient-to-b from-farm-grass/30 to-farm-grass/50",
            )}
          >
            {/* 木々の背景 */}
            <div className="absolute inset-0 flex items-end justify-around px-4 pb-4">
              <span className="text-4xl">🌲</span>
              <span className="text-5xl">🌳</span>
              <span className="text-4xl">🌲</span>
              <span className="text-5xl">🌳</span>
              <span className="text-4xl">🌲</span>
            </div>

            {/* 獲物との遭遇 */}
            {huntingState.currentPrey && (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/20">
                <span className="text-6xl animate-bounce-slow">{huntingState.currentPrey.icon}</span>
                <p className="text-white font-bold mt-2">{huntingState.currentPrey.name}</p>
              </div>
            )}

            {/* 探索中 */}
            {huntingState.isHunting && !huntingState.currentPrey && (
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-center">
                  <span className="text-4xl animate-bounce">👀</span>
                  <p className="text-foreground/80 text-sm mt-2">獲物を探しています...</p>
                </div>
              </div>
            )}

            {/* 待機中 */}
            {!huntingState.isHunting && (
              <div className="absolute inset-0 flex items-center justify-center">
                <p className="text-muted-foreground text-sm">森に入って狩りを始めよう</p>
              </div>
            )}
          </div>

          {/* 追跡プログレス */}
          {huntingState.currentPrey && (
            <div className="mb-4">
              <div className="flex justify-between text-sm mb-1">
                <span>追跡進捗</span>
                <span className="font-medium">{huntingState.trackingProgress}%</span>
              </div>
              <ProgressBar
                value={huntingState.trackingProgress}
                colorClass={huntingState.trackingProgress >= 100 ? "bg-farm-gold" : "bg-primary"}
                heightClass="h-3"
              />
            </div>
          )}

          {/* アクションボタン */}
          <div className="flex gap-2">
            {!huntingState.isHunting ? (
              <Button className="flex-1 bg-farm-grass hover:bg-farm-grass/80 text-white" onClick={handleStartHunting}>
                🌲 森に入る
              </Button>
            ) : (
              <>
                {huntingState.currentPrey ? (
                  <Button
                    className={cn(
                      "flex-1",
                      huntingState.trackingProgress >= 100
                        ? "bg-farm-gold hover:bg-farm-gold/80 text-foreground"
                        : "bg-primary hover:bg-primary/80",
                    )}
                    onClick={handleTrack}
                    disabled={isTracking}
                  >
                    {huntingState.trackingProgress >= 100 ? "捕まえる！" : "追跡する！"}
                  </Button>
                ) : (
                  <Button
                    variant="outline"
                    className="flex-1 bg-transparent"
                    onClick={handleStopHunting}
                    disabled={false}
                  >
                    森を出る
                  </Button>
                )}
                {huntingState.currentPrey && (
                  <Button variant="outline" className="bg-transparent" onClick={handleStopHunting}>
                    諦める
                  </Button>
                )}
              </>
            )}
          </div>
        </CardContent>
      </Card>

      {/* 出会える獲物一覧 */}
      <Card className="bg-card/80 backdrop-blur-sm">
        <CardHeader className="pb-3">
          <CardTitle className="text-sm text-muted-foreground">この季節に出会える獲物</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-2">
            {availablePrey.map((prey) => (
              <div key={prey.id} className="flex items-center gap-2 p-2 rounded-lg border bg-card">
                <span className="text-xl">{prey.icon}</span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{prey.name}</p>
                  <p className={cn("text-xs", getDifficultyColor(prey.difficulty))}>
                    {getDifficultyLabel(prey.difficulty)}
                  </p>
                </div>
                <span className="text-xs font-medium">{prey.sellPrice}G</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
})
