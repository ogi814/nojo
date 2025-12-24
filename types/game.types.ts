import type React from "react" // React型定義のインポート
/**
 * ゲームの型定義ファイル // このファイルの目的
 * TypeScriptの型安全性を確保するための全ての型を定義 // 型安全な開発のため
 */

// ===================================================== // セクション区切り
// 基本的な識別子とステータスの型 // ゲームの基本型
// =====================================================

/** 全てのアイテムに使用される一意のID型 // アイテム識別用 */
export type ItemId = string // 文字列型ID

/** 作物の成長段階を表す型 // 成長フェーズ管理 */
export type GrowthStage = "seed" | "sprout" | "growing" | "mature" | "harvestable" // 段階をリテラル型で定義

/** 動物の状態を表す型 // 動物のコンディション管理 */
export type AnimalStatus = "hungry" | "fed" | "happy" | "producing" // 状態をリテラル型で定義

/** ゲームの場所を表す型 // ロケーション管理 */
export type GameLocation = "farm" | "forest" | "lake" | "market" | "achievements" // 場所をリテラル型で定義

/** 季節を表す型 // 季節管理 */
export type Season = "spring" | "summer" | "autumn" | "winter" // 季節をリテラル型で定義

// ===================================================== // セクション区切り
// アイテム関連の型 // アイテム構造
// =====================================================

/** アイテムのカテゴリを表す型 // アイテム分類 */
export type ItemCategory = "crop" | "animal_product" | "fish" | "hunt" | "seed" | "tool" | "feed" // カテゴリをリテラル型で定義

/** 基本アイテムのインターフェース // アイテムの共通構造 */
export interface BaseItem {
  /** アイテムの一意のID // 識別子 */
  id: ItemId
  /** アイテムの名前（日本語） // 表示名 */
  name: string
  /** アイテムの説明 // 説明文 */
  description: string
  /** アイテムのカテゴリ // 分類 */
  category: ItemCategory
  /** 販売価格 // 売値 */
  sellPrice: number
  /** 購入価格（購入可能な場合） // 買値（任意） */
  buyPrice?: number
  /** アイコン用の絵文字 // UI用アイコン */
  icon: string
}

/** 種のインターフェース */
export interface Seed extends BaseItem {
  category: "seed"
  /** 育つまでの時間（ゲーム内秒） */
  growTime: number
  /** 収穫できる作物のID */
  harvestItemId: ItemId
  /** 適した季節 */
  seasons: Season[]
}

/** 作物のインターフェース */
export interface Crop extends BaseItem {
  category: "crop"
  /** 対応する種のID */
  seedId: ItemId
}

/** インベントリ内のアイテム */
export interface InventoryItem {
  /** アイテム情報 */
  item: BaseItem
  /** 所持数 */
  quantity: number
}

// =====================================================
// 農場関連の型
// =====================================================

/** 畑のマス目の状態 */
export interface FarmPlot {
  /** マスのID */
  id: ItemId
  /** 座標X */
  x: number
  /** 座標Y */
  y: number
  /** 植えられている種のID（空の場合はnull） */
  plantedSeedId: ItemId | null
  /** 現在の成長段階 */
  growthStage: GrowthStage
  /** 成長進捗（0-100%） */
  growthProgress: number
  /** 水やり済みかどうか */
  isWatered: boolean
  /** 植えた時刻（タイムスタンプ） */
  plantedAt: number | null
}

/** 動物のインターフェース */
export interface Animal {
  /** 動物のID */
  id: ItemId
  /** 動物の種類 */
  type: AnimalType
  /** 動物の名前 */
  name: string
  /** 現在の状態 */
  status: AnimalStatus
  /** 満腹度（0-100） */
  hunger: number
  /** 幸福度（0-100） */
  happiness: number
  /** 生産準備ができているか */
  canProduce: boolean
  /** 最後に餌をあげた時刻 */
  lastFedAt: number
  /** 最後に生産物を収穫した時刻 */
  lastProducedAt: number
  /** エサをあげた回数（収穫は3回、出荷は5回で可能） */
  feedCount: number
  /** 出荷可能かどうか（5回以上エサをあげた場合） */
  canShip: boolean
}

/** 動物の種類 */
export type AnimalType = "chicken" | "cow" | "sheep" | "pig"

/** 動物の種類ごとの設定 */
export interface AnimalConfig {
  /** 動物の種類 */
  type: AnimalType
  /** 名前 */
  name: string
  /** 購入価格 */
  price: number
  /** 生産物のアイテムID */
  produceItemId: ItemId
  /** 生産間隔（ゲーム内秒） */
  produceInterval: number
  /** 餌の消費間隔 */
  hungerInterval: number
  /** アイコン */
  icon: string
  /** 出荷価格（生産物より高い） */
  shipPrice: number
}

// =====================================================
// 狩り・釣り関連の型
// =====================================================

/** 釣りの魚のインターフェース */
export interface Fish extends BaseItem {
  category: "fish"
  /** 釣れる確率（0-1） */
  catchRate: number
  /** レア度 */
  rarity: "common" | "uncommon" | "rare" | "legendary"
  /** 釣れる季節 */
  seasons: Season[]
}

/** 狩りの獲物のインターフェース */
export interface Hunt extends BaseItem {
  category: "hunt"
  /** 遭遇確率（0-1） */
  encounterRate: number
  /** 捕獲難易度（1-10） */
  difficulty: number
  /** 出現する季節 */
  seasons: Season[]
}

/** 釣りの状態 */
export interface FishingState {
  /** 釣り中かどうか */
  isFishing: boolean
  /** 魚がかかったかどうか */
  hasBite: boolean
  /** 現在狙っている魚 */
  targetFish: Fish | null
  /** 釣り開始時刻 */
  startedAt: number | null
}

/** 狩りの状態 */
export interface HuntingState {
  /** 狩り中かどうか */
  isHunting: boolean
  /** 現在遭遇している獲物 */
  currentPrey: Hunt | null
  /** 追跡進捗（0-100） */
  trackingProgress: number
}

// =====================================================
// ゲーム全体の状態の型
// =====================================================

/** プレイヤーの統計情報 */
export interface PlayerStats {
  /** 総収穫数 */
  totalHarvests: number
  /** 総販売額 */
  totalSales: number
  /** 総釣り数 */
  totalFishCaught: number
  /** 総狩猟数 */
  totalHunts: number
  /** 総料理数 */
  totalCooks: number
  /** プレイ時間（秒） */
  playTime: number
}

/** 農場のアップグレード状態 */
export interface FarmUpgrades {
  /** 畑のサイズ（縦横のマス数） */
  fieldSize: number
  /** 動物小屋の最大数 */
  barnCapacity: number
  /** 倉庫の最大容量 */
  storageCapacity: number
  /** 自動水やりシステムの有無 */
  hasAutoWater: boolean
  /** 自動餌やりシステムの有無 */
  hasAutoFeed: boolean
}

/** ゲーム設定 */
export interface GameSettings {
  /** サウンドの有効/無効 */
  soundEnabled: boolean
  /** ゲーム速度（1-3） */
  gameSpeed: number
  /** 通知の有効/無効 */
  notificationsEnabled: boolean
  /** 自動保存の有効/無効 */
  autoSaveEnabled: boolean
}

/** ゲームの全体状態 */
export interface GameState {
  /** 現在のお金 */
  money: number
  /** 農場レベル */
  farmLevel: number
  /** 経験値 */
  experience: number
  /** 次のレベルに必要な経験値 */
  experienceToNextLevel: number
  /** 現在の季節 */
  currentSeason: Season
  /** ゲーム内日数 */
  currentDay: number
  /** ゲーム内時刻（0-24） */
  currentHour: number
  /** インベントリ */
  inventory: InventoryItem[]
  /** 畑のマス目 */
  farmPlots: FarmPlot[]
  /** 飼っている動物 */
  animals: Animal[]
  /** 釣りの状態 */
  fishingState: FishingState
  /** 狩りの状態 */
  huntingState: HuntingState
  /** プレイヤー統計 */
  stats: PlayerStats
  /** 農場アップグレード */
  upgrades: FarmUpgrades
  /** ゲーム設定 */
  settings: GameSettings
  /** 現在の場所 */
  currentLocation: GameLocation
  /** 最後の保存時刻 */
  lastSavedAt: number
}

// =====================================================
// アクション関連の型（useReducer用）
// =====================================================

/** ゲームアクションの種類 */
export type GameAction =
  // 農場関連
  | { type: "PLANT_SEED"; payload: { plotId: ItemId; seedId: ItemId } }
  | { type: "WATER_PLOT"; payload: { plotId: ItemId } }
  | { type: "HARVEST_CROP"; payload: { plotId: ItemId } }
  | { type: "UPDATE_GROWTH" }
  // 動物関連
  | { type: "BUY_ANIMAL"; payload: { animalType: AnimalType; name: string } }
  | { type: "FEED_ANIMAL"; payload: { animalId: ItemId } }
  | { type: "COLLECT_PRODUCE"; payload: { animalId: ItemId } }
  | { type: "UPDATE_ANIMALS" }
  | { type: "SHIP_ANIMAL"; payload: { animalId: ItemId } }
  // 釣り関連
  | { type: "START_FISHING" }
  | { type: "CATCH_FISH" }
  | { type: "STOP_FISHING" }
  | { type: "FISH_BITE"; payload: { fish: Fish } }
  // 狩り関連
  | { type: "START_HUNTING" }
  | { type: "TRACK_PREY" }
  | { type: "CATCH_PREY" }
  | { type: "STOP_HUNTING" }
  | { type: "ENCOUNTER_PREY"; payload: { prey: Hunt } }
  // 実績関連
  | { type: "UNLOCK_ACHIEVEMENT"; payload: { achievementId: string } }
  // 料理関連
  | { type: "COOK_DISH"; payload: { dishId: ItemId } }
  // インベントリ・市場関連
  | { type: "ADD_ITEM"; payload: { item: BaseItem; quantity: number } }
  | { type: "REMOVE_ITEM"; payload: { itemId: ItemId; quantity: number } }
  | { type: "SELL_ITEM"; payload: { itemId: ItemId; quantity: number } }
  | { type: "BUY_ITEM"; payload: { item: BaseItem; quantity: number } }
  // 場所移動
  | { type: "CHANGE_LOCATION"; payload: { location: GameLocation } }
  // 時間・ゲーム進行
  | { type: "ADVANCE_TIME" }
  | { type: "CHANGE_SEASON"; payload: { season: Season } }
  | { type: "ADD_EXPERIENCE"; payload: { amount: number } }
  | { type: "LEVEL_UP" }
  // アップグレード
  | { type: "UPGRADE_FARM"; payload: { upgradeType: keyof FarmUpgrades } }
  // 設定
  | { type: "UPDATE_SETTINGS"; payload: Partial<GameSettings> }
  // セーブ・ロード
  | { type: "SAVE_GAME" }
  | { type: "LOAD_GAME"; payload: { state: GameState } }
  | { type: "RESET_GAME" }

// =====================================================
// コンテキスト関連の型
// =====================================================

/** ゲームコンテキストの値の型 */
export interface GameContextType {
  /** 現在のゲーム状態 */
  state: GameState
  /** アクションをディスパッチする関数 */
  dispatch: React.Dispatch<GameAction>
}

/** 通知の種類 */
export type NotificationType = "success" | "info" | "warning" | "error"

/** 通知データ */
export interface Notification {
  /** 通知ID */
  id: string
  /** 通知タイプ */
  type: NotificationType
  /** メッセージ */
  message: string
  /** 作成時刻 */
  createdAt: number
}

/** 通知コンテキストの型 */
export interface NotificationContextType {
  /** 通知リスト */
  notifications: Notification[]
  /** 通知を追加 */
  addNotification: (type: NotificationType, message: string) => void
  /** 通知を削除 */
  removeNotification: (id: string) => void
}

// =====================================================
// コンポーネントProps関連の型
// =====================================================

/** 子要素を受け取るPropsの基本型 */
export interface ChildrenProps {
  children: React.ReactNode
}

/** クラス名を受け取るPropsの基本型 */
export interface ClassNameProps {
  className?: string
}

/** 畑コンポーネントのProps */
export interface FarmPlotProps {
  plot: FarmPlot
  onPlant: (plotId: ItemId, seedId: ItemId) => void
  onWater: (plotId: ItemId) => void
  onHarvest: (plotId: ItemId) => void
}

/** 動物コンポーネントのProps */
export interface AnimalProps {
  animal: Animal
  onFeed: (animalId: ItemId) => void
  onCollect: (animalId: ItemId) => void
}

/** インベントリアイテムコンポーネントのProps */
export interface InventoryItemProps {
  item: InventoryItem
  onSell?: (itemId: ItemId, quantity: number) => void
  onUse?: (itemId: ItemId) => void
}

// =====================================================
// ジェネリック型（学習用）
// =====================================================

/** リストコンポーネント用のジェネリックProps */
export interface ListProps<T> {
  /** 表示するアイテムの配列 */
  items: T[]
  /** 各アイテムをレンダリングする関数 */
  renderItem: (item: T, index: number) => React.ReactNode
  /** アイテムからキーを取得する関数 */
  keyExtractor: (item: T) => string
  /** 空の場合に表示するコンポーネント */
  emptyComponent?: React.ReactNode
}

/** レンダープロップパターン用の型 */
export interface DataProviderProps<T> {
  /** データ取得関数 */
  fetchData: () => Promise<T>
  /** レンダリング関数 */
  render: (data: T | null, loading: boolean, error: Error | null) => React.ReactNode
}

/** HOC用の基本Props型 */
export interface WithLoadingProps {
  isLoading: boolean
}

/** 外部ストア同期用の型（useSyncExternalStore用） */
export interface ExternalStore<T> {
  getSnapshot: () => T
  subscribe: (callback: () => void) => () => void
}
