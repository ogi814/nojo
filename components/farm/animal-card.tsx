"use client"

/**
 * 動物カードコンポーネント
 * 個々の動物の状態表示と操作（アニメーション付き）
 */

import { memo, useCallback } from "react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { ProgressBar } from "@/components/common/progress-bar"
import { ANIMAL_CONFIGS } from "@/data/game-data"
import type { Animal, ItemId } from "@/types/game.types"

interface AnimalCardProps {
  /** 動物データ */
  animal: Animal
  /** 餌をあげる関数 */
  onFeed: (animalId: ItemId) => void
  /** 生産物を収集する関数 */
  onCollect: (animalId: ItemId) => void
  /** 動物を出荷する関数 */
  onShip: (animalId: ItemId) => void
  /** 餌の所持数 */
  feedCount: number
}

/**
 * 動物カードコンポーネント（アニメーション付き）
 */
export const AnimalCard = memo(function AnimalCard({ animal, onFeed, onCollect, onShip, feedCount }: AnimalCardProps) {
  const config = ANIMAL_CONFIGS[animal.type]

  const handleFeed = useCallback(() => {
    onFeed(animal.id)
  }, [onFeed, animal.id])

  const handleCollect = useCallback(() => {
    onCollect(animal.id)
  }, [onCollect, animal.id])

  const handleShip = useCallback(() => {
    onShip(animal.id)
  }, [onShip, animal.id])

  // 状態に応じた背景色
  const statusColors = {
    hungry: "bg-destructive/10 border-destructive",
    fed: "bg-card border-border",
    happy: "bg-farm-grass/10 border-farm-grass",
    producing: "bg-farm-gold/10 border-farm-gold",
  }

  const canHarvest = animal.feedCount >= 3
  const canShip = animal.feedCount >= 5

  return (
    <div
      className={cn(
        "rounded-lg border-2 p-3 transition-all duration-200",
        statusColors[animal.status],
        canHarvest && "animate-pulse-glow",
      )}
    >
      {/* 動物のヘッダー */}
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <span
            className={cn(
              "text-2xl inline-block",
              // ウシとブタはゆっくり左右に動く
              (animal.type === "cow" || animal.type === "pig") && "animate-bounce-slow",
              // ニワトリは小刻みに動く
              animal.type === "chicken" && "animate-peck",
              // ヒツジはふわふわ動く
              animal.type === "sheep" && "animate-float",
            )}
          >
            {config.icon}
          </span>
          <div>
            <p className="font-medium text-sm">{animal.name}</p>
            <p className="text-xs text-muted-foreground">{config.name}</p>
          </div>
        </div>

        {/* 状態バッジ */}
        <div className="flex flex-col items-end gap-1">
          <span
            className={cn(
              "text-xs px-2 py-0.5 rounded-full",
              animal.status === "hungry" && "bg-destructive/20 text-destructive",
              animal.status === "fed" && "bg-muted text-muted-foreground",
              animal.status === "happy" && "bg-farm-grass/20 text-farm-grass",
              animal.status === "producing" && "bg-farm-gold/20 text-farm-gold",
            )}
          >
            {animal.status === "hungry" && "お腹空いた"}
            {animal.status === "fed" && "満足"}
            {animal.status === "happy" && "ご機嫌"}
            {animal.status === "producing" && "収集可能"}
          </span>
          <span className="text-xs text-muted-foreground">エサ: {animal.feedCount}/5</span>
        </div>
      </div>

      <div className="mb-2">
        <div className="flex justify-between text-xs text-muted-foreground mb-1">
          <span>育成進捗</span>
          <span>
            {animal.feedCount < 3
              ? "収穫まであと" + (3 - animal.feedCount) + "回"
              : animal.feedCount < 5
                ? "出荷まであと" + (5 - animal.feedCount) + "回"
                : "出荷可能！"}
          </span>
        </div>
        <ProgressBar
          value={(animal.feedCount / 5) * 100}
          colorClass={animal.feedCount >= 5 ? "bg-amber-500" : animal.feedCount >= 3 ? "bg-farm-gold" : "bg-primary"}
          heightClass="h-1.5"
        />
      </div>

      {/* 満腹度バー */}
      <div className="mb-2">
        <div className="flex justify-between text-xs text-muted-foreground mb-1">
          <span>満腹度</span>
          <span>{Math.round(animal.hunger)}%</span>
        </div>
        <ProgressBar
          value={animal.hunger}
          colorClass={animal.hunger < 30 ? "bg-destructive" : animal.hunger > 70 ? "bg-farm-grass" : "bg-primary"}
          heightClass="h-1.5"
        />
      </div>

      {/* アクションボタン */}
      <div className="flex gap-2 flex-wrap">
        {/* 餌やりボタン */}
        <Button
          size="sm"
          variant="outline"
          className="flex-1 text-xs bg-transparent"
          onClick={handleFeed}
          disabled={feedCount < 1}
          aria-label={`${animal.name}に餌をあげる`}
        >
          🌾 餌をあげる
        </Button>

        {canHarvest && !canShip && (
          <Button
            size="sm"
            className="flex-1 text-xs bg-farm-gold hover:bg-farm-gold/80 text-foreground"
            onClick={handleCollect}
            aria-label={`${animal.name}から収集する`}
          >
            収穫する
          </Button>
        )}

        {canShip && (
          <>
            <Button
              size="sm"
              className="flex-1 text-xs bg-farm-gold hover:bg-farm-gold/80 text-foreground"
              onClick={handleCollect}
              aria-label={`${animal.name}から収集する`}
            >
              収穫
            </Button>
            <Button
              size="sm"
              className="flex-1 text-xs bg-amber-500 hover:bg-amber-600 text-white"
              onClick={handleShip}
              aria-label={`${animal.name}を出荷する`}
            >
              出荷 ({config.shipPrice}G)
            </Button>
          </>
        )}
      </div>
    </div>
  )
})
