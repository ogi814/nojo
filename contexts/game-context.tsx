"use client" // Next.jsのクライアントコンポーネント指定

/**
 * ゲームコンテキスト
 *
 * Context（コンテキスト）APIを使用して、ゲームの状態（所持金、アイテム、経験値など）を
 * アプリケーション全体で共有するための仕組みです。
 *
 * 通常、Reactでは親から子へprops（プロパティ）でデータを渡しますが、
 * アプリ全体で使うデータの場合、バケツリレーのように渡すのは大変です。
 * Contextを使うと、どこからでもデータにアクセスできるようになります。
 */
import { createContext, useContext, useReducer, useEffect, useMemo, useRef, type ReactNode } from "react" // Reactの各種フック・型をインポート
import type { GameState, GameContextType } from "@/types/game.types" // ゲーム状態・コンテキスト型をインポート
import { createInitialGameState } from "@/data/game-data" // 初期ゲームデータ生成関数をインポート
import { gameReducer } from "./game-reducer" // ゲーム状態更新用Reducerをインポート

// ===================================================== // セクション区切り
// コンテキストの作成 // Context生成処理
// =====================================================

/**
 * Contextオブジェクトを作成
 * 初期値はundefinedに設定しています。
 * これは、Providerでのラップ忘れを検知するためです（useGameフック参照）。
 */
export const GameContext = createContext<GameContextType | undefined>(undefined) // Context生成、型指定

// デバッグ用の名前を設定 // React DevToolsで識別しやすくする
GameContext.displayName = "GameContext" // displayNameプロパティ設定

// ===================================================== // セクション区切り
// ローカルストレージのキー // 保存データのキー名
// =====================================================
const STORAGE_KEY = "farm-game-save" // ゲームデータ保存用キー

// ===================================================== // セクション区切り
// プロバイダーコンポーネント // ContextのProvider定義
// =====================================================

interface GameProviderProps {
  // Providerのprops型定義
  children: ReactNode // 子要素（ReactNode型）
}

/**
 * ゲームプロバイダーコンポーネント // Context.Providerの実装
 * useReducerでゲーム状態を管理し、Context経由で子コンポーネントに提供 // 状態管理と配布
 */
export function GameProvider({ children }: GameProviderProps) {
  // Provider本体
  // useReducerを使用して複雑なゲーム状態を管理 // 状態とdispatch取得
  const [state, dispatch] = useReducer(gameReducer, null, () => {
    // 初期化関数付きuseReducer
    // 初期化時にローカルストレージから読み込みを試みる（遅延初期化） // 永続化データの復元
    if (typeof window !== "undefined") {
      // SSR対策
      try {
        const saved = localStorage.getItem(STORAGE_KEY) // 保存データ取得
        if (saved) {
          const parsed = JSON.parse(saved)
          console.log("[v0] Loaded game from localStorage")
          return parsed
        }
      } catch (e) {
        console.error("[v0] Failed to load saved game:", e)
      }
    }
    return createInitialGameState()
  })

  // useRefを使用してインターバルIDを保持（レンダリング間で値を永続化）
  const gameLoopRef = useRef<NodeJS.Timeout | null>(null)
  const autoSaveRef = useRef<NodeJS.Timeout | null>(null)

  // =====================================================
  // ゲームループの設定（useEffect）
  // =====================================================

  useEffect(() => {
    // ゲームループ: 1秒（1000ミリ秒）ごとに実行されるタイマー処理です。
    // setIntervalを使って定期的にアクション（UPDATE_GROWTH, UPDATE_ANIMALS）を発行（dispatch）します。
    // これにより、作物の成長や動物の状態変化が自動的に進みます。
    gameLoopRef.current = setInterval(() => {
      dispatch({ type: "UPDATE_GROWTH" })
      dispatch({ type: "UPDATE_ANIMALS" })
    }, 1000)

    // クリーンアップ関数でインターバルをクリア
    return () => {
      if (gameLoopRef.current) {
        clearInterval(gameLoopRef.current)
      }
    }
  }, []) // 空の依存配列で初回のみ実行

  // =====================================================
  // 自動保存の設定（useEffect）
  // =====================================================

  useEffect(() => {
    if (!state.settings.autoSaveEnabled) return

    // 30秒ごとに自動保存
    autoSaveRef.current = setInterval(() => {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
        console.log("[v0] Auto-saved game")
      } catch (e) {
        console.error("[v0] Failed to auto-save:", e)
      }
    }, 30000)

    return () => {
      if (autoSaveRef.current) {
        clearInterval(autoSaveRef.current)
      }
    }
  }, [state.settings.autoSaveEnabled, state])

  // =====================================================
  // コンテキスト値のメモ化（useMemo）
  // =====================================================

  // useMemoで値をメモ化し、不要な再レンダリングを防ぐ
  const contextValue = useMemo<GameContextType>(
    () => ({
      state,
      dispatch,
    }),
    [state],
  )

  return <GameContext.Provider value={contextValue}>{children}</GameContext.Provider>
}

// =====================================================
// カスタムフック: useGame
// =====================================================

/**
 * ゲームコンテキストを使用するカスタムフック
 * コンテキストの存在チェックを行い、型安全に値を取得
 */
/**
 * useGame カスタムフック
 *
 * コンポーネントからGameContextを簡単に使うための関数です。
 * useContextを直接使う代わりにこれを呼ぶことで、以下のメリットがあります：
 * 1. Providerで囲まれていない場合のエラーチェックを自動化できる
 * 2. 型定義（GameContextType）が適用済みなので、補完が効きやすい
 */
export function useGame(): GameContextType {
  const context = useContext(GameContext)

  if (context === undefined) {
    throw new Error("useGame must be used within a GameProvider")
  }

  return context
}

// =====================================================
// カスタムフック: useGameState（セレクター付き）
// =====================================================

/**
 * ゲーム状態の一部のみを取得するカスタムフック
 * セレクター関数を使用して必要な部分のみを取得
 */
export function useGameState<T>(selector: (state: GameState) => T): T {
  const { state } = useGame()
  // useMemoでセレクター結果をメモ化
  return useMemo(() => selector(state), [state, selector])
}
