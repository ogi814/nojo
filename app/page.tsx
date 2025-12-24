"use client"
// "use client" は、このコンポーネントがブラウザ側（クライアントサイド）で実行されることを宣言しています。
// フック（useStateやuseEffectなど）やイベントハンドラ（onClickなど）を使う場合に必要です。

/**
 * メインページコンポーネント
 * アプリケーションのエントリーポイント
 * Context Providerでラップしてゲーム状態を提供
 */

import { Suspense, lazy } from "react"
import { GameProvider } from "@/contexts/game-context"
import { NotificationProvider } from "@/contexts/notification-context"
import { GameHeader } from "@/components/ui/game-header"
import { Navigation } from "@/components/ui/navigation"
import { NotificationDisplay } from "@/components/ui/notification-display"
import { useGame } from "@/contexts/game-context"

// React.lazyを使って、コンポーネントを動的に読み込み（インポート）します。
// これにより、最初にすべてのコードを読み込むのではなく、必要になったタイミングでファイルを読み込むため、
// アプリの初期表示速度（パフォーマンス）が向上します。これを「コード分割」と呼びます。
const FarmPage = lazy(() => import("@/components/pages/farm-page").then((mod) => ({ default: mod.FarmPage })))
const ForestPage = lazy(() => import("@/components/pages/forest-page").then((mod) => ({ default: mod.ForestPage })))
const LakePage = lazy(() => import("@/components/pages/lake-page").then((mod) => ({ default: mod.LakePage })))
const MarketPage = lazy(() => import("@/components/pages/market-page").then((mod) => ({ default: mod.MarketPage })))

/**
 * ローディングフォールバック
 * コンポーネントの読み込み中に表示される待機画面です。
 * Suspenseコンポーネントのfallbackプロパティとして渡されます。
 */
function LoadingFallback() {
  return (
    <div className="flex items-center justify-center py-12">
      <div className="text-center">
        {/* animate-bounce-slow は globals.css で定義されたカスタムアニメーションです */}
        <div className="text-4xl animate-bounce-slow mb-2">🌾</div>
        <p className="text-muted-foreground">読み込み中...</p>
      </div>
    </div>
  )
}

/**
 * メインコンテンツ
 * 現在の場所に応じたページを表示
 */
function MainContent() {
  // useGameカスタムフックを使って、Contextからゲームの状態（state）を取得します。
  const { state } = useGame()

  return (
    <main className="min-h-screen bg-background pb-20">
      <div className="max-w-2xl mx-auto p-4 space-y-4">
        {/* ヘッダー */}
        <GameHeader />

        {/* Suspenseコンポーネント: 子コンポーネント（ここでは各ページ）が読み込まれるまでの間、
            fallbackプロパティに指定したLoadingFallbackを表示します。
            Reactの非同期読み込みを簡単に扱える機能です。 */}
        <Suspense fallback={<LoadingFallback />}>
          {/* 条件付きレンダリング: state.currentLocation（現在の場所）の値に応じて、
              該当するページコンポーネントだけを表示します。
              && 演算子は、左側がtrueの場合のみ右側を描画します。 */}
          {state.currentLocation === "farm" && <FarmPage />}
          {state.currentLocation === "forest" && <ForestPage />}
          {state.currentLocation === "lake" && <LakePage />}
          {state.currentLocation === "market" && <MarketPage />}
        </Suspense>
      </div>

      {/* ナビゲーション */}
      <Navigation />

      {/* 通知表示 */}
      <NotificationDisplay />
    </main>
  )
}

/**
 * ルートページコンポーネント
 * Context Providerでアプリ全体をラップ
 */
export default function HomePage() {
  return (
    // Context Providerを使用してグローバル状態を提供
    <GameProvider>
      <NotificationProvider>
        <MainContent />
      </NotificationProvider>
    </GameProvider>
  )
}
