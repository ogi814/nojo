"use client"

/**
 * 動物管理のカスタムフック
 *
 * 動物の購入、餌やり、収穫、出荷などのロジックをまとめたフックです。
 */

import { useCallback, useMemo } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import { ANIMAL_CONFIGS, ANIMAL_PRODUCTS } from "@/data/game-data"
import type { ItemId, AnimalType } from "@/types/game.types"

/**
 * 動物の管理と操作を提供するカスタムフック
 */
export function useAnimals() {
  const { state, dispatch } = useGame()
  const { addNotification } = useNotifications()

  const animals = useMemo(() => state.animals, [state.animals])

  // 餌の所持数
  const feedCount = useMemo(() => {
    const feed = state.inventory.find((item) => item.item.id === "feed")
    return feed?.quantity || 0
  }, [state.inventory])

  /**
   * 動物を購入する関数
   */
  const buyAnimal = useCallback(
    (animalType: AnimalType, name: string) => {
      const config = ANIMAL_CONFIGS[animalType]

      if (state.money < config.price) {
        addNotification("error", "お金が足りません")
        return false
      }

      if (state.animals.length >= state.upgrades.barnCapacity) {
        addNotification("error", "動物小屋がいっぱいです")
        return false
      }

      dispatch({ type: "BUY_ANIMAL", payload: { animalType, name } })
      addNotification("success", `${name}がやってきました！`)
      return true
    },
    [dispatch, addNotification, state.money, state.animals.length, state.upgrades.barnCapacity],
  )

  /**
   * 餌をあげる関数
   */
  const feedAnimal = useCallback(
    (animalId: ItemId) => {
      if (feedCount < 1) {
        addNotification("error", "餌がありません")
        return
      }

      const animal = state.animals.find((a) => a.id === animalId)
      if (animal) {
        const newFeedCount = animal.feedCount + 1
        dispatch({ type: "FEED_ANIMAL", payload: { animalId } })
        if (newFeedCount === 3) {
          addNotification("success", `${animal.name}の収穫が可能になりました！`)
        } else if (newFeedCount === 5) {
          addNotification("success", `${animal.name}の出荷が可能になりました！`)
        } else {
          addNotification("info", `餌をあげました（${newFeedCount}/5）`)
        }
      }
    },
    [dispatch, addNotification, feedCount, state.animals],
  )

  /**
   * 生産物を収集する関数
   */
  const collectProduce = useCallback(
    (animalId: ItemId) => {
      const animal = state.animals.find((a) => a.id === animalId)
      if (!animal || animal.feedCount < 3) return

      const config = ANIMAL_CONFIGS[animal.type]
      const product = ANIMAL_PRODUCTS[config.produceItemId]

      dispatch({ type: "COLLECT_PRODUCE", payload: { animalId } })
      addNotification("success", `${product.name}を収集しました！`)
    },
    [dispatch, addNotification, state.animals],
  )

  /**
   * 動物を出荷する関数
   */
  const shipAnimal = useCallback(
    (animalId: ItemId) => {
      const animal = state.animals.find((a) => a.id === animalId)
      if (!animal || animal.feedCount < 5) return

      const config = ANIMAL_CONFIGS[animal.type]

      dispatch({ type: "SHIP_ANIMAL", payload: { animalId } })
      addNotification("success", `${animal.name}を${config.shipPrice}Gで出荷しました！`)
    },
    [dispatch, addNotification, state.animals],
  )

  // お腹を空かせている動物の数
  const hungryCount = useMemo(() => {
    return animals.filter((animal) => animal.status === "hungry").length
  }, [animals])

  // 生産物を収集できる動物の数
  const producingCount = useMemo(() => {
    return animals.filter((animal) => animal.feedCount >= 3).length
  }, [animals])

  const shippableCount = useMemo(() => {
    return animals.filter((animal) => animal.feedCount >= 5).length
  }, [animals])

  return {
    animals,
    feedCount,
    buyAnimal,
    feedAnimal,
    collectProduce,
    shipAnimal,
    hungryCount,
    producingCount,
    shippableCount,
  }
}
