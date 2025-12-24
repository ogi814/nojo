// app/market/page.tsx
import { InventoryPanel } from "@/components/market/inventory-panel";
import { ShopPanel } from "@/components/market/shop-panel";
import { StatsPanel } from "@/components/market/stats-panel";
import { UpgradePanel } from "@/components/upgrades/upgrade-panel";

/**
 * 市場ページ
 * @returns JSX.Element
 */
export default function MarketPage() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 p-4">
      <div className="lg:col-span-2">
        <InventoryPanel />
      </div>
      <div className="space-y-4">
        <ShopPanel />
        <UpgradePanel />
        <StatsPanel />
      </div>
    </div>
  );
}
