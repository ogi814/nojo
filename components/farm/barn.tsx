"use client"

/**
 * 動物小屋コンポーネント
 * 飼っている動物の一覧と管理
 */

import type React from "react"
import { memo, useState, useCallback } from "react"
import { useAnimals } from "@/hooks/use-animals"
import { useGame } from "@/contexts/game-context"
import { AnimalCard } from "./animal-card"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { ANIMAL_CONFIGS } from "@/data/game-data"
import type { AnimalType } from "@/types/game.types"

/**
 * 動物小屋コンポーネント
 */
export const Barn = memo(function Barn() {
  const {
    animals,
    feedCount,
    feedAnimal,
    collectProduce,
    shipAnimal,
    buyAnimal,
    hungryCount,
    producingCount,
    shippableCount,
  } = useAnimals()
  const { state } = useGame()

  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [selectedType, setSelectedType] = useState<AnimalType | null>(null)
  const [animalName, setAnimalName] = useState("")

  const handleBuyAnimal = useCallback(() => {
    if (!selectedType || !animalName.trim()) return

    const success = buyAnimal(selectedType, animalName.trim())
    if (success) {
      setIsDialogOpen(false)
      setSelectedType(null)
      setAnimalName("")
    }
  }, [buyAnimal, selectedType, animalName])

  const handleNameChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setAnimalName(e.target.value)
  }, [])

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg flex items-center gap-2">
            <span>🏠</span>
            <span>動物小屋</span>
          </CardTitle>
          <div className="flex gap-2 items-center flex-wrap">
            {/* 状態バッジ */}
            {hungryCount > 0 && <Badge variant="destructive">空腹: {hungryCount}</Badge>}
            {producingCount > 0 && <Badge className="bg-farm-gold text-foreground">収穫: {producingCount}</Badge>}
            {shippableCount > 0 && <Badge className="bg-amber-500 text-white">出荷: {shippableCount}</Badge>}

            {/* 餌の所持数 */}
            <Badge variant="outline">🌾 餌: {feedCount}</Badge>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* 動物購入ダイアログ */}
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button
              variant="outline"
              className="w-full bg-transparent"
              disabled={animals.length >= state.upgrades.barnCapacity}
            >
              + 動物を購入 ({animals.length}/{state.upgrades.barnCapacity})
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>動物を購入</DialogTitle>
              <DialogDescription>新しい動物を農場に迎えましょう（エサ3回で収穫、5回で出荷可能）</DialogDescription>
            </DialogHeader>

            <div className="space-y-4 pt-4">
              {/* 動物タイプ選択 */}
              <div className="grid grid-cols-2 gap-2">
                {Object.values(ANIMAL_CONFIGS).map((config) => (
                  <Button
                    key={config.type}
                    variant={selectedType === config.type ? "default" : "outline"}
                    className="flex flex-col items-center gap-1 h-auto py-3"
                    onClick={() => setSelectedType(config.type)}
                    disabled={state.money < config.price}
                  >
                    <span className="text-2xl">{config.icon}</span>
                    <span className="text-sm">{config.name}</span>
                    <span className="text-xs text-muted-foreground">{config.price}G</span>
                    <span className="text-xs text-amber-600">出荷: {config.shipPrice}G</span>
                  </Button>
                ))}
              </div>

              {/* 名前入力 */}
              {selectedType && (
                <div className="space-y-2">
                  <Label htmlFor="animal-name">名前をつけてあげましょう</Label>
                  <Input
                    id="animal-name"
                    value={animalName}
                    onChange={handleNameChange}
                    placeholder="例: ピヨちゃん"
                    maxLength={10}
                  />
                </div>
              )}

              {/* 購入ボタン */}
              <Button className="w-full" onClick={handleBuyAnimal} disabled={!selectedType || !animalName.trim()}>
                購入する
              </Button>
            </div>
          </DialogContent>
        </Dialog>

        {/* 動物リスト */}
        <div className="grid gap-3">
          {animals.length > 0 ? (
            animals.map((animal) => (
              <AnimalCard
                key={animal.id}
                animal={animal}
                onFeed={feedAnimal}
                onCollect={collectProduce}
                onShip={shipAnimal}
                feedCount={feedCount}
              />
            ))
          ) : (
            <p className="text-center text-muted-foreground py-4">まだ動物がいません</p>
          )}
        </div>
      </CardContent>
    </Card>
  )
})
