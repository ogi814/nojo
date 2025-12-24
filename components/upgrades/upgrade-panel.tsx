"use client"

import { useContext } from "react"
import { GameContext } from "@/contexts/game-context"
import { UPGRADE_COSTS } from "@/data/game-data"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { ArrowUpCircle } from "lucide-react"

function UpgradeItem({
  name,
  level,
  description,
  cost,
  onUpgrade,
  canAfford,
}: {
  name: string
  level: number
  description: string
  cost?: number
  onUpgrade: () => void
  canAfford: boolean
}) {
  const isMaxLevel = cost === undefined

  return (
    <div className="flex items-center gap-4 p-3 rounded-lg border bg-card">
      <div className="text-4xl">
        <ArrowUpCircle className="w-10 h-10" />
      </div>
      <div className="flex-1">
        <p className="font-bold">
          {name} <span className="text-sm text-muted-foreground">Lv.{level}</span>
        </p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      <Button onClick={onUpgrade} disabled={!canAfford || isMaxLevel} size="sm">
        {isMaxLevel ? "Max" : `${cost}G`}
      </Button>
    </div>
  )
}

export function UpgradePanel() {
  const { state, dispatch } = useContext(GameContext)
  const { money, upgrades } = state

  const handleUpgrade = (upgradeType: "fieldSize" | "barnCapacity") => {
    dispatch({ type: "UPGRADE_FARM", payload: { upgradeType } })
  }

  const fieldSizeLevel = upgrades.fieldSize - 3
  const fieldSizeCost = UPGRADE_COSTS.fieldSize[fieldSizeLevel]

  const barnCapacityLevel = upgrades.barnCapacity / 3 - 1
  const barnCapacityCost = UPGRADE_COSTS.barnCapacity[barnCapacityLevel]

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="text-lg flex items-center gap-2">
          <span>🛠️</span>
          <span>施設アップグレード</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <UpgradeItem
          name="畑の拡張"
          level={fieldSizeLevel + 1}
          description={`サイズが ${upgrades.fieldSize}x${upgrades.fieldSize} → ${upgrades.fieldSize + 1}x${
            upgrades.fieldSize + 1
          } になる`}
          cost={fieldSizeCost}
          onUpgrade={() => handleUpgrade("fieldSize")}
          canAfford={fieldSizeCost !== undefined && money >= fieldSizeCost}
        />
        <UpgradeItem
          name="動物小屋の拡張"
          level={barnCapacityLevel + 1}
          description={`収容数が ${upgrades.barnCapacity} → ${upgrades.barnCapacity + 3} になる`}
          cost={barnCapacityCost}
          onUpgrade={() => handleUpgrade("barnCapacity")}
          canAfford={barnCapacityCost !== undefined && money >= barnCapacityCost}
        />
      </CardContent>
    </Card>
  )
}
