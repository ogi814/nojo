"use client"

/**
 * 畑のマス目コンポーネント
 * 種まき、水やり、収穫を行う基本ユニット
 */

import { memo, useCallback, useState } from "react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { ProgressBar } from "@/components/common/progress-bar"
import { SEEDS } from "@/data/game-data"
import type { FarmPlot as FarmPlotType, InventoryItem, ItemId } from "@/types/game.types"

interface FarmPlotProps {
  /** 畑マスのデータ */
  plot: FarmPlotType
  /** 植えられる種のリスト */
  availableSeeds: InventoryItem[]
  /** 種を植える関数 */
  onPlant: (plotId: ItemId, seedId: ItemId) => void
  /** 水やりをする関数 */
  onWater: (plotId: ItemId) => void
  /** 収穫する関数 */
  onHarvest: (plotId: ItemId) => void
}

/**
 * 成長段階に応じた絵文字を取得
 */
function getGrowthEmoji(stage: FarmPlotType["growthStage"], seedId: string | null): string {
  if (!seedId) return ""

  switch (stage) {
    case "seed":
      return "🌱"
    case "sprout":
      return "🌿"
    case "growing":
      return "🪴"
    case "mature":
      return "🌳"
    case "harvestable":
      // 収穫物のアイコンを表示
      const seed = SEEDS[seedId]
      if (seed) {
        switch (seed.harvestItemId) {
          case "tomato":
            return "🍅"
          case "carrot":
            return "🥕"
          case "corn":
            return "🌽"
          case "pumpkin":
            return "🎃"
          case "cabbage":
            return "🥬"
          default:
            return "🌾"
        }
      }
      return "🌾"
    default:
      return ""
  }
}

/**
 * 畑マスコンポーネント
 * memoでメモ化して不要な再レンダリングを防止
 */
export const FarmPlotComponent = memo(function FarmPlotComponent({
  plot,
  availableSeeds,
  onPlant,
  onWater,
  onHarvest,
}: FarmPlotProps) {
  // ポップオーバーの開閉状態（useState）
  // 種選択メニューの表示を制御します。
  const [isOpen, setIsOpen] = useState(false)

  // 種を植えるハンドラ（useCallback）
  const handlePlant = useCallback(
    (seedId: ItemId) => {
      onPlant(plot.id, seedId)
      setIsOpen(false)
    },
    [onPlant, plot.id],
  )

  // 水やりハンドラ
  const handleWater = useCallback(() => {
    onWater(plot.id)
  }, [onWater, plot.id])

  // 収穫ハンドラ
  const handleHarvest = useCallback(() => {
    onHarvest(plot.id)
  }, [onHarvest, plot.id])

  // 空のマスかどうか
  const isEmpty = plot.plantedSeedId === null

  // 収穫可能かどうか
  const canHarvest = plot.growthStage === "harvestable"

  return (
    <div
      className={cn(
        "relative aspect-square rounded-lg border-2 transition-all duration-200",
        "flex flex-col items-center justify-center",
        // 条件付きクラス: 空き地かどうかで背景色などを切り替え
        isEmpty ? "bg-farm-soil border-farm-wood hover:bg-farm-soil/80" : "bg-farm-grass/30 border-farm-grass",
        // 収穫可能な時は光るアニメーション（animate-pulse-glow）を追加
        canHarvest && "animate-pulse-glow border-farm-gold",
        // 水やり済みなら青い枠線を追加
        plot.isWatered && !isEmpty && "ring-2 ring-farm-water ring-offset-1",
      )}
    >
      {/* 条件付きレンダリング: 空のマスの場合 */}
      {isEmpty ? (
        <Popover open={isOpen} onOpenChange={setIsOpen}>
          <PopoverTrigger asChild>
            <Button variant="ghost" className="w-full h-full text-2xl hover:bg-farm-grass/20" aria-label="種を植える">
              +
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-48 p-2">
            <div className="space-y-1">
              <p className="text-sm font-medium mb-2">種を選択</p>
              {/* フラグメントを使用 */}
              <>
                {availableSeeds.length > 0 ? (
                  availableSeeds.map((seedItem) => (
                    <Button
                      key={seedItem.item.id}
                      variant="ghost"
                      className="w-full justify-start text-sm"
                      onClick={() => handlePlant(seedItem.item.id)}
                    >
                      {seedItem.item.icon} {seedItem.item.name} x{seedItem.quantity}
                    </Button>
                  ))
                ) : (
                  <p className="text-sm text-muted-foreground">種がありません</p>
                )}
              </>
            </div>
          </PopoverContent>
        </Popover>
      ) : (
        /* 作物が植えられている場合 */
        <div className="flex flex-col items-center gap-1 p-1 w-full">
          {/* 成長段階の絵文字 */}
          <span className="text-2xl sm:text-3xl animate-bounce-slow">
            {getGrowthEmoji(plot.growthStage, plot.plantedSeedId)}
          </span>

          {/* 成長プログレスバー */}
          <ProgressBar
            value={plot.growthProgress}
            colorClass={canHarvest ? "bg-farm-gold" : "bg-farm-grass"}
            heightClass="h-1"
            className="w-full px-1"
          />

          {/* アクションボタン */}
          <div className="flex gap-1 mt-1">
            {/* 水やりボタン（三項演算子で条件付きレンダリング） */}
            {!plot.isWatered && !canHarvest ? (
              <Button
                size="sm"
                variant="outline"
                className="h-6 text-xs px-2 bg-transparent"
                onClick={handleWater}
                aria-label="水やり"
              >
                💧
              </Button>
            ) : null}

            {/* 収穫ボタン */}
            {canHarvest && (
              <Button
                size="sm"
                className="h-6 text-xs px-2 bg-farm-gold hover:bg-farm-gold/80 text-foreground"
                onClick={handleHarvest}
                aria-label="収穫"
              >
                収穫
              </Button>
            )}
          </div>
        </div>
      )}
    </div>
  )
})
