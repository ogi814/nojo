"use client"

/**
 * インベントリパネルコンポーネント
 * 所持アイテムの一覧表示と販売機能
 */

import type React from "react"
import { memo, useState, useCallback, useMemo, useDeferredValue } from "react"
import { useInventory } from "@/hooks/use-inventory"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import type { ItemCategory, InventoryItem } from "@/types/game.types"

/**
 * カテゴリのラベルと絵文字
 */
const CATEGORY_INFO: Record<ItemCategory | "all", { label: string; emoji: string }> = {
  all: { label: "すべて", emoji: "📦" },
  crop: { label: "作物", emoji: "🌾" },
  animal_product: { label: "畜産物", emoji: "🥚" },
  fish: { label: "魚", emoji: "🐟" },
  hunt: { label: "獲物", emoji: "🦌" },
  seed: { label: "種", emoji: "🌱" },
  tool: { label: "道具", emoji: "🔧" },
  feed: { label: "餌", emoji: "🌿" },
}

/**
 * インベントリアイテムの行コンポーネント
 */
const InventoryItemRow = memo(function InventoryItemRow({
  item,
  onSell,
}: {
  item: InventoryItem
  onSell: (itemId: string, quantity: number) => void
}) {
  const [sellQuantity, setSellQuantity] = useState(1)

  // 販売ハンドラ
  const handleSell = useCallback(() => {
    onSell(item.item.id, sellQuantity)
    setSellQuantity(1)
  }, [onSell, item.item.id, sellQuantity])

  // 数量変更ハンドラ（制御コンポーネント）
  const handleQuantityChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = Math.min(Math.max(1, Number.parseInt(e.target.value) || 1), item.quantity)
      setSellQuantity(value)
    },
    [item.quantity],
  )

  // 全て売るハンドラ
  const handleSellAll = useCallback(() => {
    onSell(item.item.id, item.quantity)
  }, [onSell, item.item.id, item.quantity])

  return (
    <div className="flex items-center gap-2 p-2 rounded-lg border bg-card hover:bg-muted/50 transition-colors">
      {/* アイテム情報 */}
      <span className="text-xl">{item.item.icon}</span>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium truncate">{item.item.name}</p>
        <p className="text-xs text-muted-foreground">
          {item.item.sellPrice}G / 個 × {item.quantity}
        </p>
      </div>

      {/* 販売コントロール */}
      <div className="flex items-center gap-1">
        <Input
          type="number"
          min={1}
          max={item.quantity}
          value={sellQuantity}
          onChange={handleQuantityChange}
          className="w-14 h-7 text-xs text-center"
        />
        <Button size="sm" variant="outline" className="h-7 text-xs px-2 bg-transparent" onClick={handleSell}>
          売る
        </Button>
        {item.quantity > 1 && (
          <Button
            size="sm"
            variant="secondary"
            className="h-7 text-xs px-2 bg-transparent border"
            onClick={handleSellAll}
          >
            全部
          </Button>
        )}
      </div>
    </div>
  )
})

/**
 * インベントリパネルコンポーネント
 */
export const InventoryPanel = memo(function InventoryPanel() {
  const { inventory, money, totalItems, sellItem, getItemsByCategory } = useInventory()

  // 検索フィルター（useState）
  const [searchTerm, setSearchTerm] = useState("")
  // useDeferredValueで検索の遅延処理（React 18の機能）
  // ユーザーの入力に合わせてsearchTermは即座に更新されますが、
  // deferredSearchTermの更新は少し遅延されます。
  // これにより、重いフィルタリング処理の頻度を下げ、UIの応答性を保ちます。
  const deferredSearchTerm = useDeferredValue(searchTerm)

  // カテゴリフィルター
  const [selectedCategory, setSelectedCategory] = useState<ItemCategory | "all">("all")

  // フィルタリングされたアイテム（useMemo）
  const filteredItems = useMemo(() => {
    let items = selectedCategory === "all" ? inventory : getItemsByCategory(selectedCategory)

    // 検索フィルター
    if (deferredSearchTerm) {
      items = items.filter((item) => item.item.name.toLowerCase().includes(deferredSearchTerm.toLowerCase()))
    }

    return items
  }, [inventory, selectedCategory, deferredSearchTerm, getItemsByCategory])

  // 検索中かどうか（遅延表示）
  // 入力値と遅延値が異なる間は「検索・処理中」とみなせます。
  const isSearching = searchTerm !== deferredSearchTerm

  // 検索入力ハンドラ
  const handleSearchChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value)
  }, [])

  // カテゴリ変更ハンドラ
  const handleCategoryChange = useCallback((value: string) => {
    setSelectedCategory(value as ItemCategory | "all")
  }, [])

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg flex items-center gap-2">
            <span>🎒</span>
            <span>インベントリ</span>
          </CardTitle>
          <div className="flex items-center gap-2">
            <Badge variant="outline">{totalItems}個</Badge>
            <Badge className="bg-farm-gold text-foreground">{money.toLocaleString()}G</Badge>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* 検索バー（非制御コンポーネントの例としてref版も可能だがここは制御版） */}
        <div className="relative">
          <Input
            type="text"
            placeholder="アイテムを検索..."
            value={searchTerm}
            onChange={handleSearchChange}
            className="pr-8"
          />
          {/* 検索中インジケーター */}
          {isSearching && (
            <div className="absolute right-2 top-1/2 -translate-y-1/2">
              <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
            </div>
          )}
        </div>

        {/* カテゴリタブ */}
        <Tabs value={selectedCategory} onValueChange={handleCategoryChange}>
          <TabsList className="w-full flex-wrap h-auto gap-1 bg-muted/50">
            {Object.entries(CATEGORY_INFO).map(([key, info]) => {
              const count = key === "all" ? inventory.length : getItemsByCategory(key as ItemCategory).length
              if (count === 0 && key !== "all") return null
              return (
                <TabsTrigger key={key} value={key} className="text-xs px-2 py-1 data-[state=active]:bg-card">
                  {info.emoji} {info.label}
                  {count > 0 && <span className="ml-1 text-muted-foreground">({count})</span>}
                </TabsTrigger>
              )
            })}
          </TabsList>

          <TabsContent value={selectedCategory} className="mt-4">
            {/* アイテムリスト */}
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {filteredItems.length > 0 ? (
                filteredItems.map((item) => <InventoryItemRow key={item.item.id} item={item} onSell={sellItem} />)
              ) : (
                <p className="text-center text-muted-foreground py-8">
                  {searchTerm ? "検索結果がありません" : "アイテムがありません"}
                </p>
              )}
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
})
