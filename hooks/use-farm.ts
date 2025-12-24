"use client"

/**
 * 農場操作のカスタムフック
 * 
 * 畑の状態管理、種まき、水やり、収穫などの機能を提供します。
 * ゲームのメイン機能の一つです。
 */

import { useCallback, useMemo } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import { SEEDS, CROPS } from "@/data/game-data"
import type { ItemId } from "@/types/game.types"

/**
 * 農場の操作と状態を提供するカスタムフック
 */
export function useFarm() {
  const { state, dispatch } = useGame()
  const { addNotification } = useNotifications()

  // 畑の状態（useMemoでメモ化）
  const farmPlots = useMemo(() => state.farmPlots, [state.farmPlots])

  // インベントリから種（category === "seed"）だけをフィルタリングします。
  // useMemoを使うことで、インベントリが変わらない限りフィルタリング処理を再実行しません。
  const availableSeeds = useMemo(() => {
    return state.inventory.filter((item) => item.item.category === "seed")
  }, [state.inventory])

  /**
   * 種を植える関数（useCallbackでメモ化）
   */
  const plantSeed = useCallback(
    (plotId: ItemId, seedId: ItemId) => {
      const seed = SEEDS[seedId]
      if (!seed) return

      dispatch({ type: "PLANT_SEED", payload: { plotId, seedId } })
      addNotification("success", `${seed.name}を植えました！`)
    },
    [dispatch, addNotification],
  )

  /**
   * 水やりをする関数
   */
  const waterPlot = useCallback(
    (plotId: ItemId) => {
      dispatch({ type: "WATER_PLOT", payload: { plotId } })
      addNotification("info", "水をあげました")
    },
    [dispatch, addNotification],
  )

  /**
   * 作物を収穫する関数
   */
  const harvestCrop = useCallback(
    (plotId: ItemId) => {
      const plot = state.farmPlots.find((p) => p.id === plotId)
      if (!plot || !plot.plantedSeedId) return

      const seed = SEEDS[plot.plantedSeedId]
      const crop = CROPS[seed.harvestItemId]

      dispatch({ type: "HARVEST_CROP", payload: { plotId } })
      addNotification("success", `${crop.name}を収穫しました！`)
    },
    [dispatch, addNotification, state.farmPlots],
  )

  // 収穫可能な作物の数を計算
  // これもuseMemoで計算コストを抑えます（畑の数が多い場合に有効）
  const harvestableCount = useMemo(() => {
    return farmPlots.filter((plot) => plot.growthStage === "harvestable").length
  }, [farmPlots])

  // 植えられている作物の数
  const plantedCount = useMemo(() => {
    return farmPlots.filter((plot) => plot.plantedSeedId !== null).length
  }, [farmPlots])

  return {
    farmPlots,
    availableSeeds,
    plantSeed,
    waterPlot,
    harvestCrop,
    harvestableCount,
    plantedCount,
  }
}
