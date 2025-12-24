"use client"

/**
 * 市場ページ
 * アイテムの売買や統計情報を確認できる画面です。
 * インベントリ、ショップ、統計パネルを配置しています。
 */

import { InventoryPanel } from "@/components/market/inventory-panel"
import { ShopPanel } from "@/components/market/shop-panel"
import { StatsPanel } from "@/components/market/stats-panel"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

export function MarketPage() {
  return (
    <div className="space-y-4">
      <Tabs defaultValue="shop">
        <TabsList className="w-full bg-muted/50">
          <TabsTrigger value="shop" className="flex-1 data-[state=active]:bg-card">
            🏪 ショップ
          </TabsTrigger>
          <TabsTrigger value="inventory" className="flex-1 data-[state=active]:bg-card">
            🎒 所持品
          </TabsTrigger>
          <TabsTrigger value="stats" className="flex-1 data-[state=active]:bg-card">
            📊 統計
          </TabsTrigger>
        </TabsList>

        <TabsContent value="shop" className="mt-4">
          <ShopPanel />
        </TabsContent>

        <TabsContent value="inventory" className="mt-4">
          <InventoryPanel />
        </TabsContent>

        <TabsContent value="stats" className="mt-4">
          <StatsPanel />
        </TabsContent>
      </Tabs>
    </div>
  )
}
