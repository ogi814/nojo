"use client"

/**
 * 畑全体のコンポーネント
 * 複数の畑マスをグリッド表示
 */

import { memo, useMemo } from "react"
import { useFarm } from "@/hooks/use-farm"
import { FarmPlotComponent } from "./farm-plot"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

/**
 * 畑フィールドコンポーネント
 * 全ての畑マスを管理・表示
 */
export const FarmField = memo(function FarmField() {
  // カスタムフックから農場の状態と操作関数を取得
  const { farmPlots, availableSeeds, plantSeed, waterPlot, harvestCrop, harvestableCount, plantedCount } = useFarm()

  // グリッドサイズを計算（useMemoでメモ化）
  // 畑の総数から、正方形のグリッド（例: 9マスなら3x3）のサイズを計算します。
  // 畑の数（farmPlots.length）が変わらない限り、再計算せずに前回の結果を使います。
  const gridSize = useMemo(() => {
    return Math.sqrt(farmPlots.length)
  }, [farmPlots.length])

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg flex items-center gap-2">
            <span>🌾</span>
            <span>畑</span>
          </CardTitle>
          <div className="flex gap-2">
            {/* 条件付きレンダリング: 植えられている数が0より大きい場合 */}
            {plantedCount > 0 && (
              <Badge variant="secondary">
                植付: {plantedCount}/{farmPlots.length}
              </Badge>
            )}
            {/* 収穫可能な数がある場合 */}
            {harvestableCount > 0 && (
              <Badge className="bg-farm-gold text-foreground">収穫可能: {harvestableCount}</Badge>
            )}
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {/* CSSグリッドで畑マスを配置 */}
        <div
          className="grid gap-2"
          style={{
            gridTemplateColumns: `repeat(${gridSize}, 1fr)`,
          }}
        >
          {/* リストのレンダリング - keyにplot.idを使用 */}
          {farmPlots.map((plot) => (
            <FarmPlotComponent
              key={plot.id}
              plot={plot}
              availableSeeds={availableSeeds}
              onPlant={plantSeed}
              onWater={waterPlot}
              onHarvest={harvestCrop}
            />
          ))}
        </div>

        {/* 空のメッセージ */}
        {farmPlots.length === 0 && <p className="text-center text-muted-foreground py-8">畑がありません</p>}
      </CardContent>
    </Card>
  )
})
