/**
 * ゲームの静的データ定義
 * 種、作物、動物、魚、獲物などのマスターデータ
 */

import type {
  Seed,
  Crop,
  Fish,
  Hunt,
  AnimalConfig,
  BaseItem,
  GameState,
  FarmPlot,
  Achievement,
  Dish,
} from "@/types/game.types"

// =====================================================
// 種のデータ
// =====================================================

/**
 * 種のマスターデータ
 * Record<string, Seed>: キーが文字列、値がSeed型のオブジェクト
 * キー（tomato_seedなど）を使って、O(1)の計算量で高速にデータにアクセスできます。
 */
export const SEEDS: Record<string, Seed> = {
  tomato_seed: {
    id: "tomato_seed",
    name: "トマトの種",
    description: "赤くて美味しいトマトが育ちます",
    category: "seed",
    sellPrice: 10,
    buyPrice: 20,
    icon: "🌱",
    growTime: 30, // 30秒で成長（デモ用に短く）
    harvestItemId: "tomato",
    seasons: ["spring", "summer"],
  },
  carrot_seed: {
    id: "carrot_seed",
    name: "にんじんの種",
    description: "栄養満点のにんじんが育ちます",
    category: "seed",
    sellPrice: 8,
    buyPrice: 15,
    icon: "🌱",
    growTime: 25,
    harvestItemId: "carrot",
    seasons: ["spring", "autumn"],
  },
  corn_seed: {
    id: "corn_seed",
    name: "とうもろこしの種",
    description: "甘いとうもろこしが育ちます",
    category: "seed",
    sellPrice: 15,
    buyPrice: 30,
    icon: "🌱",
    growTime: 40,
    harvestItemId: "corn",
    seasons: ["summer"],
  },
  pumpkin_seed: {
    id: "pumpkin_seed",
    name: "かぼちゃの種",
    description: "大きなかぼちゃが育ちます",
    category: "seed",
    sellPrice: 20,
    buyPrice: 40,
    icon: "🌱",
    growTime: 50,
    harvestItemId: "pumpkin",
    seasons: ["autumn"],
  },
  cabbage_seed: {
    id: "cabbage_seed",
    name: "キャベツの種",
    description: "シャキシャキのキャベツが育ちます",
    category: "seed",
    sellPrice: 12,
    buyPrice: 25,
    icon: "🌱",
    growTime: 35,
    harvestItemId: "cabbage",
    seasons: ["spring", "winter"],
  },
}

// =====================================================
// 作物のデータ
// =====================================================

/** 作物のマスターデータ */
export const CROPS: Record<string, Crop> = {
  tomato: {
    id: "tomato",
    name: "トマト",
    description: "真っ赤に熟したトマト",
    category: "crop",
    sellPrice: 50,
    icon: "🍅",
    seedId: "tomato_seed",
  },
  carrot: {
    id: "carrot",
    name: "にんじん",
    description: "オレンジ色の甘いにんじん",
    category: "crop",
    sellPrice: 40,
    icon: "🥕",
    seedId: "carrot_seed",
  },
  corn: {
    id: "corn",
    name: "とうもろこし",
    description: "黄金色のとうもろこし",
    category: "crop",
    sellPrice: 80,
    icon: "🌽",
    seedId: "corn_seed",
  },
  pumpkin: {
    id: "pumpkin",
    name: "かぼちゃ",
    description: "大きくて甘いかぼちゃ",
    category: "crop",
    sellPrice: 120,
    icon: "🎃",
    seedId: "pumpkin_seed",
  },
  cabbage: {
    id: "cabbage",
    name: "キャベツ",
    description: "みずみずしいキャベツ",
    category: "crop",
    sellPrice: 60,
    icon: "🥬",
    seedId: "cabbage_seed",
  },
}

// =====================================================
// 動物のデータ
// =====================================================

/** 動物の設定データ */
export const ANIMAL_CONFIGS: Record<string, AnimalConfig> = {
  chicken: {
    type: "chicken",
    name: "ニワトリ",
    price: 100,
    produceItemId: "egg",
    produceInterval: 20, // 20秒ごと
    hungerInterval: 30,
    icon: "🐔",
    shipPrice: 80,
  },
  cow: {
    type: "cow",
    name: "ウシ",
    price: 500,
    produceItemId: "milk",
    produceInterval: 40,
    hungerInterval: 25,
    icon: "🐄",
    shipPrice: 250,
  },
  sheep: {
    type: "sheep",
    name: "ヒツジ",
    price: 300,
    produceItemId: "wool",
    produceInterval: 60,
    hungerInterval: 35,
    icon: "🐑",
    shipPrice: 180,
  },
  pig: {
    type: "pig",
    name: "ブタ",
    price: 400,
    produceItemId: "truffle",
    produceInterval: 80,
    hungerInterval: 20,
    icon: "🐷",
    shipPrice: 350,
  },
}

/** 動物の生産物 */
export const ANIMAL_PRODUCTS: Record<string, BaseItem> = {
  egg: {
    id: "egg",
    name: "たまご",
    description: "新鮮なたまご",
    category: "animal_product",
    sellPrice: 30,
    icon: "🥚",
  },
  milk: {
    id: "milk",
    name: "ミルク",
    description: "新鮮な牛乳",
    category: "animal_product",
    sellPrice: 80,
    icon: "🥛",
  },
  wool: {
    id: "wool",
    name: "羊毛",
    description: "ふわふわの羊毛",
    category: "animal_product",
    sellPrice: 100,
    icon: "🧶",
  },
  truffle: {
    id: "truffle",
    name: "トリュフ",
    description: "希少なトリュフ",
    category: "animal_product",
    sellPrice: 200,
    icon: "🍄",
  },
}

/** 動物の餌 */
export const FEED: BaseItem = {
  id: "feed",
  name: "動物のエサ",
  description: "動物に与えるエサ",
  category: "feed",
  sellPrice: 5,
  buyPrice: 10,
  icon: "🌾",
}

// =====================================================
// 魚のデータ
// =====================================================

/** 魚のマスターデータ */
export const FISH: Record<string, Fish> = {
  carp: {
    id: "carp",
    name: "コイ",
    description: "淡水に住む一般的な魚",
    category: "fish",
    sellPrice: 40,
    icon: "🐟",
    catchRate: 0.4,
    rarity: "common",
    seasons: ["spring", "summer", "autumn"],
  },
  trout: {
    id: "trout",
    name: "マス",
    description: "川に住む美味しい魚",
    category: "fish",
    sellPrice: 80,
    icon: "🐟",
    catchRate: 0.25,
    rarity: "uncommon",
    seasons: ["spring", "autumn"],
  },
  salmon: {
    id: "salmon",
    name: "サケ",
    description: "秋に川を上るサケ",
    category: "fish",
    sellPrice: 150,
    icon: "🐠",
    catchRate: 0.15,
    rarity: "rare",
    seasons: ["autumn"],
  },
  golden_fish: {
    id: "golden_fish",
    name: "金の魚",
    description: "伝説の黄金の魚",
    category: "fish",
    sellPrice: 500,
    icon: "✨",
    catchRate: 0.02,
    rarity: "legendary",
    seasons: ["spring", "summer", "autumn", "winter"],
  },
  catfish: {
    id: "catfish",
    name: "ナマズ",
    description: "夜行性の大きな魚",
    category: "fish",
    sellPrice: 100,
    icon: "🐡",
    catchRate: 0.2,
    rarity: "uncommon",
    seasons: ["summer"],
  },
}

// =====================================================
// 狩りの獲物のデータ
// =====================================================

/** 獲物のマスターデータ */
export const HUNTS: Record<string, Hunt> = {
  rabbit: {
    id: "rabbit",
    name: "ウサギ",
    description: "素早いウサギ",
    category: "hunt",
    sellPrice: 60,
    icon: "🐰",
    encounterRate: 0.35,
    difficulty: 3,
    seasons: ["spring", "summer", "autumn"],
  },
  deer: {
    id: "deer",
    name: "シカ",
    description: "森に住む鹿",
    category: "hunt",
    sellPrice: 200,
    icon: "🦌",
    encounterRate: 0.15,
    difficulty: 6,
    seasons: ["autumn", "winter"],
  },
  boar: {
    id: "boar",
    name: "イノシシ",
    description: "力強いイノシシ",
    category: "hunt",
    sellPrice: 250,
    icon: "🐗",
    encounterRate: 0.1,
    difficulty: 8,
    seasons: ["autumn", "winter"],
  },
  fox: {
    id: "fox",
    name: "キツネ",
    description: "賢いキツネ",
    category: "hunt",
    sellPrice: 150,
    icon: "🦊",
    encounterRate: 0.2,
    difficulty: 5,
    seasons: ["winter", "spring"],
  },
  bear: {
    id: "bear",
    name: "クマ",
    description: "巨大なクマ",
    category: "hunt",
    sellPrice: 500,
    icon: "🐻",
    encounterRate: 0.05,
    difficulty: 10,
    seasons: ["autumn"],
  },
}

// =====================================================
// 実績のデータ
// =====================================================

/** 実績のマスターデータ */
export const ACHIEVEMENTS: Record<string, Achievement> = {
  first_harvest: {
    id: "first_harvest",
    name: "はじめの一歩",
    description: "初めて作物を収穫する。",
    icon: "🎉",
    condition: (stats) => stats.totalHarvests >= 1,
    isSecret: false,
  },
  farm_tycoon: {
    id: "farm_tycoon",
    name: "農場タイクーン",
    description: "所持金が10,000Gを超える。",
    icon: "💰",
    condition: (_, state) => state.money >= 10000,
    isSecret: false,
  },
  master_angler: {
    id: "master_angler",
    name: "釣り名人",
    description: "魚を合計50匹釣り上げる。",
    icon: "🏆",
    condition: (stats) => stats.totalFishCaught >= 50,
    isSecret: false,
  },
  legendary_catch: {
    id: "legendary_catch",
    name: "伝説の目撃者",
    description: "伝説の魚を釣り上げる。",
    icon: "✨",
    condition: (_, state) => state.inventory.some((item) => item.item.id === "golden_fish"),
    isSecret: true,
  },
  master_chef: {
    id: "master_chef",
    name: "マスターシェフ",
    description: "料理を10回行う。",
    icon: "🧑‍🍳",
    condition: (stats) => stats.totalCooks >= 10,
    isSecret: false,
  },
}

// =====================================================
// 料理のデータ
// =====================================================

/** 料理のマスターデータ */
export const DISHES: Record<string, Dish> = {
  grilled_fish: {
    id: "grilled_fish",
    name: "焼き魚",
    description: "シンプルで美味しい魚の塩焼き。",
    category: "dish",
    sellPrice: 100,
    icon: "🔥",
    energy: 50,
    ingredients: [{ itemId: "carp", quantity: 1 }],
  },
  salad: {
    id: "salad",
    name: "サラダ",
    description: "新鮮な野菜のサラダ。",
    category: "dish",
    sellPrice: 150,
    icon: "🥗",
    energy: 30,
    ingredients: [
      { itemId: "tomato", quantity: 2 },
      { itemId: "cabbage", quantity: 1 },
    ],
  },
}

// =====================================================
// アップグレードのコストデータ
// =====================================================

/** 農場アップグレードのコスト */
export const UPGRADE_COSTS = {
  fieldSize: [500, 1000, 2000, 5000, 10000], // レベルごとのコスト
  barnCapacity: [300, 600, 1200, 2500, 5000],
  storageCapacity: [200, 400, 800, 1600, 3200],
  hasAutoWater: [1000],
  hasAutoFeed: [1500],
}

/** レベルアップに必要な経験値 */
export const EXPERIENCE_TABLE = [0, 100, 250, 500, 1000, 2000, 4000, 8000, 16000, 32000]

// =====================================================
// 初期状態の生成関数
// =====================================================

/**
 * 初期の畑マス目を生成する関数
 * @param size 畑のサイズ（縦横のマス数）
 * @returns 畑マス目の配列
 *
 * for文の二重ループを使って、縦 x 横 のグリッド状のデータを生成しています。
 */
export const createInitialPlots = (size: number): FarmPlot[] => {
  const plots: FarmPlot[] = []
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      plots.push({
        id: `plot_${x}_${y}`,
        x,
        y,
        plantedSeedId: null,
        growthStage: "seed",
        growthProgress: 0,
        isWatered: false,
        plantedAt: null,
      })
    }
  }
  return plots
}

/**
 * ゲームの初期状態を生成する関数
 * @returns 初期のGameState
 */
export const createInitialGameState = (): GameState => ({
  money: 500,
  farmLevel: 1,
  experience: 0,
  experienceToNextLevel: EXPERIENCE_TABLE[1],
  currentSeason: "spring",
  currentDay: 1,
  currentHour: 6,
  inventory: [
    // 初期アイテム
    { item: SEEDS.tomato_seed, quantity: 5 },
    { item: SEEDS.carrot_seed, quantity: 3 },
    { item: FEED, quantity: 10 },
  ],
  farmPlots: createInitialPlots(3), // 3x3の畑
  animals: [],
  fishingState: {
    isFishing: false,
    hasBite: false,
    targetFish: null,
    startedAt: null,
  },
  huntingState: {
    isHunting: false,
    currentPrey: null,
    trackingProgress: 0,
  },
  stats: {
    totalHarvests: 0,
    totalSales: 0,
    totalFishCaught: 0,
    totalHunts: 0,
    playTime: 0,
  },
  upgrades: {
    fieldSize: 3,
    barnCapacity: 3,
    storageCapacity: 50,
    hasAutoWater: false,
    hasAutoFeed: false,
  },
  settings: {
    soundEnabled: true,
    gameSpeed: 1,
    notificationsEnabled: true,
    autoSaveEnabled: true,
  },
  currentLocation: "farm",
  lastSavedAt: Date.now(),
})

/**
 * 全アイテムを取得するヘルパー関数
 * @returns 全アイテムの配列
 */
export const getAllItems = (): BaseItem[] => [
  ...Object.values(SEEDS),
  ...Object.values(CROPS),
  ...Object.values(ANIMAL_PRODUCTS),
  ...Object.values(FISH),
  ...Object.values(HUNTS),
  ...Object.values(DISHES),
  FEED,
]

/**
 * IDからアイテムを取得するヘルパー関数
 * @param itemId アイテムID
 * @returns アイテム情報またはundefined
 */
export const getItemById = (itemId: string): BaseItem | undefined => {
  return getAllItems().find((item) => item.id === itemId)
}
