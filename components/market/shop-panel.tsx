"use client"

/**
 * ショップパネルコンポーネント
 * アイテムの購入機能
 */

import type React from "react"
import { memo, useState, useCallback } from "react"
import { useInventory } from "@/hooks/use-inventory"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { SEEDS, FEED } from "@/data/game-data"
import type { BaseItem } from "@/types/game.types"

/**
 * 購入可能アイテムの行コンポーネント
 */
const ShopItemRow = memo(function ShopItemRow({
  item,
  money,
  onBuy,
}: {
  item: BaseItem
  money: number
  onBuy: (item: BaseItem, quantity: number) => boolean
}) {
  const [buyQuantity, setBuyQuantity] = useState(1)

  const buyPrice = item.buyPrice || 0
  const totalCost = buyPrice * buyQuantity
  const canAfford = money >= totalCost

  // 購入ハンドラ
  const handleBuy = useCallback(() => {
    const success = onBuy(item, buyQuantity)
    if (success) {
      setBuyQuantity(1)
    }
  }, [onBuy, item, buyQuantity])

  // 数量変更ハンドラ
  const handleQuantityChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const value = Math.max(1, Number.parseInt(e.target.value) || 1)
    setBuyQuantity(value)
  }, [])

  // 最大購入可能数
  // 所持金で購入できる最大個数を計算します（端数切り捨て）。
  const maxBuyable = Math.floor(money / buyPrice)

  // 最大購入ハンドラ
  const handleBuyMax = useCallback(() => {
    if (maxBuyable > 0) {
      setBuyQuantity(maxBuyable)
    }
  }, [maxBuyable])

  return (
    <div className="flex items-center gap-2 p-3 rounded-lg border bg-card hover:bg-muted/50 transition-colors">
      <span className="text-2xl">{item.icon}</span>
      <div className="flex-1 min-w-0">
        <p className="font-medium">{item.name}</p>
        <p className="text-xs text-muted-foreground">{item.description}</p>
        <p className="text-sm text-farm-gold font-medium mt-1">{buyPrice}G / 個</p>
      </div>

      <div className="flex items-center gap-2">
        <div className="flex flex-col items-end gap-1">
          <div className="flex items-center gap-1">
            <Input
              type="number"
              min={1}
              value={buyQuantity}
              onChange={handleQuantityChange}
              className="w-16 h-8 text-sm text-center"
            />
            <Button
              size="sm"
              variant="ghost"
              className="h-8 text-xs px-2"
              onClick={handleBuyMax}
              disabled={maxBuyable < 1}
            >
              最大
            </Button>
          </div>
          <span className="text-xs text-muted-foreground">合計: {totalCost.toLocaleString()}G</span>
        </div>
        <Button
          size="sm"
          className="h-8 bg-primary hover:bg-primary/80"
          onClick={handleBuy}
          disabled={!canAfford || buyQuantity < 1}
        >
          購入
        </Button>
      </div>
    </div>
  )
})

/**
 * ショップパネルコンポーネント
 */
export const ShopPanel = memo(function ShopPanel() {
  const { money, buyItem } = useInventory()

  // 購入可能な種のリスト
  const seedItems = Object.values(SEEDS)

  // 餌アイテム
  const feedItem = FEED

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="text-lg flex items-center gap-2">
              <span>🏪</span>
              <span>ショップ</span>
            </CardTitle>
            <CardDescription>種や餌を購入しよう</CardDescription>
          </div>
          <Badge className="bg-farm-gold text-foreground text-lg px-3 py-1">{money.toLocaleString()}G</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="seeds">
          <TabsList className="w-full bg-muted/50">
            <TabsTrigger value="seeds" className="flex-1 data-[state=active]:bg-card">
              🌱 種
            </TabsTrigger>
            <TabsTrigger value="supplies" className="flex-1 data-[state=active]:bg-card">
              🌿 消耗品
            </TabsTrigger>
          </TabsList>

          {/* 種タブ */}
          <TabsContent value="seeds" className="mt-4 space-y-2">
            {seedItems.map((seed) => (
              <ShopItemRow key={seed.id} item={seed} money={money} onBuy={buyItem} />
            ))}
          </TabsContent>

          {/* 消耗品タブ */}
          <TabsContent value="supplies" className="mt-4 space-y-2">
            <ShopItemRow item={feedItem} money={money} onBuy={buyItem} />
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
})
