/**
 * ゲーム状態管理のReducer // このファイルの目的
 * useReducerフックで使用する複雑な状態更新ロジックを定義 // 状態更新の中心
 */

import type { GameState, GameAction, InventoryItem, FarmPlot, Animal } from "@/types/game.types" // 型定義をインポート
import {
  SEEDS, // 種データ
  CROPS, // 作物データ
  ANIMAL_CONFIGS, // 動物設定
  ANIMAL_PRODUCTS, // 動物産物
  DISHES,
  UPGRADE_COSTS,
  EXPERIENCE_TABLE, // 経験値テーブル
  createInitialGameState, // 初期状態生成関数
  createInitialPlots,
} from "@/data/game-data" // ゲームデータをインポート

/**
 * ゲームのメインReducer関数
 *
 * Reducer（リデューサー）とは、「現在の状態(state)」と「アクション(action)」を受け取り、
 * 「新しい状態」を返す関数のことです。
 *
 * ルール:
 * 1. 直接stateを変更（破壊的変更）してはいけません。必ず新しいオブジェクトを作って返します。
 *    （例: state.money = 100 はNG。 return { ...state, money: 100 } はOK）
 * 2. 同じ入力（stateとaction）なら、必ず同じ結果を返す純粋関数であるべきです。
 *
 * @param state 現在のゲーム状態
 * @param action 実行するアクション（typeとpayloadを持つオブジェクト）
 * @returns 更新された新しいゲーム状態
 */
export const gameReducer = (state: GameState, action: GameAction): GameState => {
  // Reducer関数定義
  switch (
    action.type // アクションタイプで分岐
  ) {
    // ===================================================== // セクション区切り
    // 農場関連のアクション // 農場操作
    // =====================================================

    /**
     * 種を植えるアクション
     * type: "PLANT_SEED"
     * payload: { plotId: string, seedId: string }
     */
    case "PLANT_SEED": {
      const { plotId, seedId } = action.payload // アクションから畑IDと種ID取得
      const seed = SEEDS[seedId] // 種データ取得

      // 種がインベントリにあるか確認 // 所持数チェック
      const seedInInventory = state.inventory.find((item) => item.item.id === seedId) // インベントリ検索
      if (!seedInInventory || seedInInventory.quantity < 1) {
        // 種がない場合
        return state // 種がない場合は何もしない
      }

      // 畑を更新 // 対象畑の状態変更
      const updatedPlots = state.farmPlots.map((plot) => {
        // 畑リストを更新
        if (plot.id === plotId && plot.plantedSeedId === null) {
          // 対象畑かつ未植え
          return {
            ...plot, // 既存データ維持
            plantedSeedId: seedId, // 種IDセット
            growthStage: "seed" as const, // 成長段階を「種」に
            growthProgress: 0,
            plantedAt: Date.now(),
          }
        }
        return plot
      })

      // インベントリから種を減らす
      const updatedInventory = state.inventory
        .map((item) => {
          if (item.item.id === seedId) {
            return { ...item, quantity: item.quantity - 1 }
          }
          return item
        })
        .filter((item) => item.quantity > 0)

      // 最後に、更新された新しいstateオブジェクトを返します。
      // ...state で現在のstateのコピーを作成し、変更したい部分だけ上書きします。
      return {
        ...state,
        farmPlots: updatedPlots,
        inventory: updatedInventory,
      }
    }

    /**
     * 水やりアクション
     * 指定された畑マスに水を与える
     */
    case "WATER_PLOT": {
      const { plotId } = action.payload

      const updatedPlots = state.farmPlots.map((plot) => {
        if (plot.id === plotId && plot.plantedSeedId !== null) {
          return { ...plot, isWatered: true }
        }
        return plot
      })

      return { ...state, farmPlots: updatedPlots }
    }

    /**
     * 収穫アクション
     * 成熟した作物を収穫してインベントリに追加
     */
    case "HARVEST_CROP": {
      const { plotId } = action.payload

      const plot = state.farmPlots.find((p) => p.id === plotId)
      if (!plot || plot.growthStage !== "harvestable" || !plot.plantedSeedId) {
        return state
      }

      const seed = SEEDS[plot.plantedSeedId]
      const harvestedCrop = CROPS[seed.harvestItemId]

      // 畑をリセット
      const updatedPlots = state.farmPlots.map((p) => {
        if (p.id === plotId) {
          return {
            ...p,
            plantedSeedId: null,
            growthStage: "seed" as const,
            growthProgress: 0,
            isWatered: false,
            plantedAt: null,
          }
        }
        return p
      })

      // インベントリに追加
      const updatedInventory = addToInventory(state.inventory, harvestedCrop, 1)

      return {
        ...state,
        farmPlots: updatedPlots,
        inventory: updatedInventory,
        stats: {
          ...state.stats,
          totalHarvests: state.stats.totalHarvests + 1,
        },
        experience: state.experience + 10, // 収穫で経験値獲得
      }
    }

    /**
     * 成長更新アクション
     * ゲームループで定期的に呼ばれ、作物の成長を進める
     */
    case "UPDATE_GROWTH": {
      const now = Date.now()

      const updatedPlots = state.farmPlots.map((plot) => {
        if (!plot.plantedSeedId || !plot.plantedAt) return plot

        const seed = SEEDS[plot.plantedSeedId]
        // 水やり済みの場合は2倍速で成長
        const growthMultiplier = plot.isWatered ? 2 : 1
        const elapsedSeconds = ((now - plot.plantedAt) / 1000) * growthMultiplier * state.settings.gameSpeed
        const progress = Math.min((elapsedSeconds / seed.growTime) * 100, 100)

        // 成長段階を決定
        let growthStage: FarmPlot["growthStage"] = "seed"
        if (progress >= 100) growthStage = "harvestable"
        else if (progress >= 75) growthStage = "mature"
        else if (progress >= 50) growthStage = "growing"
        else if (progress >= 25) growthStage = "sprout"

        return {
          ...plot,
          growthProgress: progress,
          growthStage,
        }
      })

      return { ...state, farmPlots: updatedPlots }
    }

    // =====================================================
    // 動物関連のアクション
    // =====================================================

    /**
     * 動物購入アクション
     */
    case "BUY_ANIMAL": {
      const { animalType, name } = action.payload
      const config = ANIMAL_CONFIGS[animalType]

      // お金が足りるか確認
      if (state.money < config.price) return state

      // 動物小屋の容量確認
      if (state.animals.length >= state.upgrades.barnCapacity) return state

      const newAnimal: Animal = {
        id: `animal_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        type: animalType,
        name,
        status: "fed",
        hunger: 100,
        happiness: 100,
        canProduce: false,
        lastFedAt: Date.now(),
        lastProducedAt: Date.now(),
        feedCount: 0,
        canShip: false,
      }

      return {
        ...state,
        money: state.money - config.price,
        animals: [...state.animals, newAnimal],
      }
    }

    /**
     * 餌やりアクション
     */
    case "FEED_ANIMAL": {
      const { animalId } = action.payload

      // 餌がインベントリにあるか確認
      const feedInInventory = state.inventory.find((item) => item.item.id === "feed")
      if (!feedInInventory || feedInInventory.quantity < 1) return state

      const updatedAnimals = state.animals.map((animal) => {
        if (animal.id === animalId) {
          const newFeedCount = animal.feedCount + 1
          const canProduce = newFeedCount >= 3
          const canShip = newFeedCount >= 5
          return {
            ...animal,
            hunger: 100,
            status: "fed" as const,
            lastFedAt: Date.now(),
            feedCount: newFeedCount,
            canProduce,
            canShip,
          }
        }
        return animal
      })

      const updatedInventory = state.inventory
        .map((item) => {
          if (item.item.id === "feed") {
            return { ...item, quantity: item.quantity - 1 }
          }
          return item
        })
        .filter((item) => item.quantity > 0)

      return {
        ...state,
        animals: updatedAnimals,
        inventory: updatedInventory,
      }
    }

    /**
     * 生産物収集アクション
     */
    case "COLLECT_PRODUCE": {
      const { animalId } = action.payload

      const animal = state.animals.find((a) => a.id === animalId)
      if (!animal || animal.feedCount < 3) return state

      const config = ANIMAL_CONFIGS[animal.type]
      const product = ANIMAL_PRODUCTS[config.produceItemId]

      const updatedAnimals = state.animals.map((a) => {
        if (a.id === animalId) {
          return {
            ...a,
            canProduce: false,
            lastProducedAt: Date.now(),
            feedCount: 0,
            canShip: false,
          }
        }
        return a
      })

      const updatedInventory = addToInventory(state.inventory, product, 1)

      return {
        ...state,
        animals: updatedAnimals,
        inventory: updatedInventory,
        experience: state.experience + 5,
      }
    }

    /**
     * 動物出荷アクション
     * エサを5回以上あげた動物を出荷して高値で売る
     */
    case "SHIP_ANIMAL": {
      const { animalId } = action.payload

      const animal = state.animals.find((a) => a.id === animalId)
      // エサ5回以上で出荷可能
      if (!animal || animal.feedCount < 5) return state

      const config = ANIMAL_CONFIGS[animal.type]

      // 動物を配列から削除
      const updatedAnimals = state.animals.filter((a) => a.id !== animalId)

      return {
        ...state,
        animals: updatedAnimals,
        money: state.money + config.shipPrice,
        experience: state.experience + 15,
        stats: {
          ...state.stats,
          totalSales: state.stats.totalSales + config.shipPrice,
        },
      }
    }

    /**
     * 動物状態更新アクション
     */
    case "UPDATE_ANIMALS": {
      const now = Date.now()

      const updatedAnimals = state.animals.map((animal) => {
        const config = ANIMAL_CONFIGS[animal.type]

        // 空腹度の減少
        const timeSinceFed = (now - animal.lastFedAt) / 1000
        const hungerDecay = (timeSinceFed / config.hungerInterval) * 100
        const newHunger = Math.max(0, 100 - hungerDecay)

        const canProduce = animal.feedCount >= 3
        const canShip = animal.feedCount >= 5

        // 状態の決定
        let status: Animal["status"] = "fed"
        if (newHunger < 30) status = "hungry"
        else if (canProduce) status = "producing"
        else if (newHunger > 70) status = "happy"

        return {
          ...animal,
          hunger: newHunger,
          status,
          canProduce,
          canShip,
          happiness: Math.min(100, newHunger),
        }
      })

      return { ...state, animals: updatedAnimals }
    }

    // =====================================================
    // 釣り関連のアクション
    // =====================================================

    case "START_FISHING": {
      return {
        ...state,
        fishingState: {
          isFishing: true,
          hasBite: false,
          targetFish: null,
          startedAt: Date.now(),
        },
      }
    }

    case "FISH_BITE": {
      const { fish } = action.payload
      return {
        ...state,
        fishingState: {
          ...state.fishingState,
          hasBite: true,
          targetFish: fish,
        },
      }
    }

    case "CATCH_FISH": {
      if (!state.fishingState.hasBite || !state.fishingState.targetFish) {
        return state
      }

      const updatedInventory = addToInventory(state.inventory, state.fishingState.targetFish, 1)

      return {
        ...state,
        inventory: updatedInventory,
        fishingState: {
          isFishing: false,
          hasBite: false,
          targetFish: null,
          startedAt: null,
        },
        stats: {
          ...state.stats,
          totalFishCaught: state.stats.totalFishCaught + 1,
        },
        experience: state.experience + 15,
      }
    }

    case "STOP_FISHING": {
      return {
        ...state,
        fishingState: {
          isFishing: false,
          hasBite: false,
          targetFish: null,
          startedAt: null,
        },
      }
    }

    // =====================================================
    // 狩り関連のアクション
    // =====================================================

    case "START_HUNTING": {
      return {
        ...state,
        huntingState: {
          isHunting: true,
          currentPrey: null,
          trackingProgress: 0,
        },
      }
    }

    case "ENCOUNTER_PREY": {
      const { prey } = action.payload
      return {
        ...state,
        huntingState: {
          ...state.huntingState,
          currentPrey: prey,
          trackingProgress: 0,
        },
      }
    }

    case "TRACK_PREY": {
      if (!state.huntingState.currentPrey) return state

      const newProgress = Math.min(state.huntingState.trackingProgress + 10, 100)
      return {
        ...state,
        huntingState: {
          ...state.huntingState,
          trackingProgress: newProgress,
        },
      }
    }

    case "CATCH_PREY": {
      if (!state.huntingState.currentPrey || state.huntingState.trackingProgress < 100) {
        return state
      }

      const updatedInventory = addToInventory(state.inventory, state.huntingState.currentPrey, 1)

      return {
        ...state,
        inventory: updatedInventory,
        huntingState: {
          isHunting: false,
          currentPrey: null,
          trackingProgress: 0,
        },
        stats: {
          ...state.stats,
          totalHunts: state.stats.totalHunts + 1,
        },
        experience: state.experience + 20,
      }
    }

    case "STOP_HUNTING": {
      return {
        ...state,
        huntingState: {
          isHunting: false,
          currentPrey: null,
          trackingProgress: 0,
        },
      }
    }

    // =====================================================
    // 料理関連のアクション
    // =====================================================
    case "COOK_DISH": {
      const { dishId } = action.payload
      const dish = DISHES[dishId]
      if (!dish) return state // 料理が存在しない

      // 材料が足りるかチェック
      const hasAllIngredients = dish.ingredients.every((ingredient) => {
        const itemInInventory = state.inventory.find((i) => i.item.id === ingredient.itemId)
        return itemInInventory && itemInInventory.quantity >= ingredient.quantity
      })

      if (!hasAllIngredients) {
        // 材料が足りない場合は何もしない
        return state
      }

      // 材料を消費
      let inventoryAfterCooking = [...state.inventory]
      dish.ingredients.forEach((ingredient) => {
        inventoryAfterCooking = inventoryAfterCooking
          .map((item) => {
            if (item.item.id === ingredient.itemId) {
              return { ...item, quantity: item.quantity - ingredient.quantity }
            }
            return item
          })
          .filter((item) => item.quantity > 0)
      })

      // 料理をインベントリに追加
      const finalInventory = addToInventory(inventoryAfterCooking, dish, 1)

      return {
        ...state,
        inventory: finalInventory,
        experience: state.experience + 25, // 料理で経験値獲得
      }
    }

    // =====================================================
    // インベントリ・市場関連のアクション
    // =====================================================

    case "ADD_ITEM": {
      const { item, quantity } = action.payload
      const updatedInventory = addToInventory(state.inventory, item, quantity)
      return { ...state, inventory: updatedInventory }
    }

    case "REMOVE_ITEM": {
      const { itemId, quantity } = action.payload
      const updatedInventory = state.inventory
        .map((invItem) => {
          if (invItem.item.id === itemId) {
            return { ...invItem, quantity: invItem.quantity - quantity }
          }
          return invItem
        })
        .filter((item) => item.quantity > 0)

      return { ...state, inventory: updatedInventory }
    }

    case "SELL_ITEM": {
      const { itemId, quantity } = action.payload
      const invItem = state.inventory.find((i) => i.item.id === itemId)
      if (!invItem || invItem.quantity < quantity) return state

      const totalPrice = invItem.item.sellPrice * quantity

      const updatedInventory = state.inventory
        .map((item) => {
          if (item.item.id === itemId) {
            return { ...item, quantity: item.quantity - quantity }
          }
          return item
        })
        .filter((item) => item.quantity > 0)

      return {
        ...state,
        money: state.money + totalPrice,
        inventory: updatedInventory,
        stats: {
          ...state.stats,
          totalSales: state.stats.totalSales + totalPrice,
        },
      }
    }

    case "BUY_ITEM": {
      const { item, quantity } = action.payload
      if (!item.buyPrice) return state

      const totalCost = item.buyPrice * quantity
      if (state.money < totalCost) return state

      const updatedInventory = addToInventory(state.inventory, item, quantity)

      return {
        ...state,
        money: state.money - totalCost,
        inventory: updatedInventory,
      }
    }

    // =====================================================
    // 場所・時間・経験値関連のアクション
    // =====================================================

    case "CHANGE_LOCATION": {
      const { location } = action.payload
      return { ...state, currentLocation: location }
    }

    case "ADVANCE_TIME": {
      let newHour = state.currentHour + 1
      let newDay = state.currentDay
      let newSeason = state.currentSeason

      if (newHour >= 24) {
        newHour = 0
        newDay += 1
      }

      // 30日で季節が変わる
      if (newDay > 30) {
        newDay = 1
        const seasons: GameState["currentSeason"][] = ["spring", "summer", "autumn", "winter"]
        const currentIndex = seasons.indexOf(state.currentSeason)
        newSeason = seasons[(currentIndex + 1) % 4]
      }

      return {
        ...state,
        currentHour: newHour,
        currentDay: newDay,
        currentSeason: newSeason,
        stats: {
          ...state.stats,
          playTime: state.stats.playTime + 1,
        },
      }
    }

    case "ADD_EXPERIENCE": {
      const { amount } = action.payload
      let newExp = state.experience + amount
      let newLevel = state.farmLevel
      let newExpToNext = state.experienceToNextLevel

      // レベルアップ判定
      while (newExp >= newExpToNext && newLevel < EXPERIENCE_TABLE.length - 1) {
        newExp -= newExpToNext
        newLevel += 1
        newExpToNext = EXPERIENCE_TABLE[newLevel] || newExpToNext * 2
      }

      return {
        ...state,
        experience: newExp,
        farmLevel: newLevel,
        experienceToNextLevel: newExpToNext,
      }
    }

    case "LEVEL_UP": {
      const nextLevel = state.farmLevel + 1
      if (nextLevel >= EXPERIENCE_TABLE.length) return state

      return {
        ...state,
        farmLevel: nextLevel,
        experienceToNextLevel: EXPERIENCE_TABLE[nextLevel] || state.experienceToNextLevel * 2,
        experience: 0,
      }
    }

    // =====================================================
    // アップグレード関連のアクション
    // =====================================================

    case "UPGRADE_FARM": {
      const { upgradeType } = action.payload
      const currentUpgrades = state.upgrades

      switch (upgradeType) {
        case "fieldSize": {
          const currentSize = currentUpgrades.fieldSize
          const nextSize = currentSize + 1
          const cost = UPGRADE_COSTS.fieldSize[currentSize - 3] // 3x3がレベル0と仮定

          if (!cost || state.money < cost) return state

          const newPlots = createInitialPlots(nextSize)

          return {
            ...state,
            money: state.money - cost,
            farmPlots: newPlots,
            upgrades: {
              ...currentUpgrades,
              fieldSize: nextSize,
            },
          }
        }
        case "barnCapacity": {
          const currentCapacity = currentUpgrades.barnCapacity
          const nextCapacity = currentCapacity + 3
          const cost = UPGRADE_COSTS.barnCapacity[currentCapacity / 3 - 1] // 3がレベル0と仮定

          if (!cost || state.money < cost) return state

          return {
            ...state,
            money: state.money - cost,
            upgrades: {
              ...currentUpgrades,
              barnCapacity: nextCapacity,
            },
          }
        }
        default:
          return state
      }
    }

    // =====================================================
    // 設定関連のアクション
    // =====================================================

    case "UPDATE_SETTINGS": {
      return {
        ...state,
        settings: { ...state.settings, ...action.payload },
      }
    }

    // =====================================================
    // セーブ・ロード関連のアクション
    // =====================================================

    case "SAVE_GAME": {
      return { ...state, lastSavedAt: Date.now() }
    }

    case "LOAD_GAME": {
      return action.payload.state
    }

    case "RESET_GAME": {
      return createInitialGameState()
    }

    default:
      return state
  }
}

// =====================================================
// ヘルパー関数
// =====================================================

/**
 * インベントリにアイテムを追加するヘルパー関数
 * 既存のアイテムがあれば数量を増やし、なければ新規追加
 */
function addToInventory(inventory: InventoryItem[], item: any, quantity: number): InventoryItem[] {
  const existingIndex = inventory.findIndex((invItem) => invItem.item.id === item.id)

  if (existingIndex >= 0) {
    return inventory.map((invItem, index) => {
      if (index === existingIndex) {
        return { ...invItem, quantity: invItem.quantity + quantity }
      }
      return invItem
    })
  }

  return [...inventory, { item, quantity }]
}
