"use client"

/**
 * 釣りエリアコンポーネント
 * 釣りのゲームプレイを提供
 */

import { memo, useCallback, useRef, useEffect } from "react"
import { useFishing } from "@/hooks/use-fishing"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

/**
 * レア度に応じた色を取得
 */
function getRarityColor(rarity: string): string {
  switch (rarity) {
    case "common":
      return "bg-muted text-muted-foreground"
    case "uncommon":
      return "bg-farm-grass/20 text-farm-grass"
    case "rare":
      return "bg-farm-water/20 text-farm-water"
    case "legendary":
      return "bg-farm-gold/20 text-farm-gold"
    default:
      return "bg-muted text-muted-foreground"
  }
}

/**
 * レア度の日本語ラベル
 */
function getRarityLabel(rarity: string): string {
  const labels: Record<string, string> = {
    common: "普通",
    uncommon: "珍しい",
    rare: "レア",
    legendary: "伝説",
  }
  return labels[rarity] || rarity
}

/**
 * 釣りエリアコンポーネント
 */
export const FishingArea = memo(function FishingArea() {
  const { fishingState, startFishing, catchFish, stopFishing, availableFish } = useFishing()

  // useRefでアニメーション用の参照を保持
  // DOM要素に直接アクセスするためにuseRefを使用します。
  // Reactの状態（State）として管理すると、アニメーションのような頻繁な更新で再レンダリングが多発するため、
  // パフォーマンスへの影響を避けるためにrefを使って直接DOM操作を行うことがあります。
  const waterRef = useRef<HTMLDivElement>(null)
  const bobberRef = useRef<HTMLDivElement>(null)

  // 釣り開始ハンドラ
  const handleStartFishing = useCallback(() => {
    startFishing()
  }, [startFishing])

  // 魚を釣るハンドラ
  const handleCatchFish = useCallback(() => {
    catchFish()
  }, [catchFish])

  // 中止ハンドラ
  const handleStopFishing = useCallback(() => {
    stopFishing()
  }, [stopFishing])

  // 魚がかかった時のアニメーション効果（useEffect）
  // fishingState.hasBite が true になった瞬間にクラスを付与してアニメーションを開始します。
  useEffect(() => {
    if (fishingState.hasBite && bobberRef.current) {
      bobberRef.current.classList.add("animate-shake")

      // アニメーション終了後にクラスを削除
      const timer = setTimeout(() => {
        bobberRef.current?.classList.remove("animate-shake")
      }, 300)

      return () => clearTimeout(timer)
    }
  }, [fishingState.hasBite])

  return (
    <div className="space-y-4">
      {/* 釣りエリアカード */}
      <Card className="bg-card/80 backdrop-blur-sm overflow-hidden">
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <span>🎣</span>
            <span>湖</span>
          </CardTitle>
          <CardDescription>静かな湖で釣りを楽しもう</CardDescription>
        </CardHeader>
        <CardContent>
          {/* 釣り場のビジュアル */}
          <div
            ref={waterRef}
            className={cn(
              "relative h-48 rounded-lg overflow-hidden mb-4",
              "bg-gradient-to-b from-farm-water/30 to-farm-water/60",
            )}
          >
            {/* 水面のアニメーション */}
            <div className="absolute inset-0 bg-[url('/water-ripples.jpg')] opacity-20" />

            {/* 釣り中の表示 */}
            {fishingState.isFishing && (
              <div className="absolute inset-0 flex items-center justify-center">
                <div ref={bobberRef} className={cn("text-4xl", fishingState.hasBite ? "animate-bounce" : "")}>
                  {fishingState.hasBite ? "🐟" : "🎣"}
                </div>
              </div>
            )}

            {/* 待機中のメッセージ */}
            {!fishingState.isFishing && (
              <div className="absolute inset-0 flex items-center justify-center">
                <p className="text-muted-foreground text-sm">釣り竿を投げて始めよう</p>
              </div>
            )}

            {/* ステータス表示 */}
            {fishingState.isFishing && (
              <div className="absolute bottom-2 left-2 right-2">
                <Badge
                  className={cn(
                    "w-full justify-center",
                    fishingState.hasBite ? "bg-farm-gold text-foreground animate-pulse" : "bg-muted",
                  )}
                >
                  {fishingState.hasBite ? "今だ！クリック！" : "待っています..."}
                </Badge>
              </div>
            )}
          </div>

          {/* アクションボタン */}
          <div className="flex gap-2">
            {!fishingState.isFishing ? (
              <Button className="flex-1 bg-farm-water hover:bg-farm-water/80 text-white" onClick={handleStartFishing}>
                🎣 釣りを始める
              </Button>
            ) : (
              <>
                {fishingState.hasBite ? (
                  <Button
                    className="flex-1 bg-farm-gold hover:bg-farm-gold/80 text-foreground animate-pulse"
                    onClick={handleCatchFish}
                  >
                    釣り上げる！
                  </Button>
                ) : (
                  <Button variant="outline" className="flex-1 bg-transparent" onClick={handleStopFishing}>
                    やめる
                  </Button>
                )}
              </>
            )}
          </div>
        </CardContent>
      </Card>

      {/* 釣れる魚一覧 */}
      <Card className="bg-card/80 backdrop-blur-sm">
        <CardHeader className="pb-3">
          <CardTitle className="text-sm text-muted-foreground">この季節に釣れる魚</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-2">
            {availableFish.map((fish) => (
              <div
                key={fish.id}
                className={cn("flex items-center gap-2 p-2 rounded-lg border", getRarityColor(fish.rarity))}
              >
                <span className="text-xl">{fish.icon}</span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{fish.name}</p>
                  <p className="text-xs text-muted-foreground">{getRarityLabel(fish.rarity)}</p>
                </div>
                <span className="text-xs font-medium">{fish.sellPrice}G</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
})
