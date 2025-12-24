import type { Metadata, Viewport } from "next"
import { Geist, Geist_Mono } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import React from "react"
import { GameProvider } from "@/contexts/game-context"
import { NotificationProvider } from "@/contexts/notification-context"
import { NotificationDisplay } from "@/components/ui/notification-display"
import { Navigation } from "@/components/ui/navigation"
import { AchievementWatcher } from "@/components/achievements/achievement-watcher"
import "./globals.css"

// フォントの設定
const _geist = Geist({ subsets: ["latin"] })
const _geistMono = Geist_Mono({ subsets: ["latin"] })

// SEO（検索エンジン最適化）やブラウザのタブ表示などで使われるメタデータ設定です。
// Next.jsがこのオブジェクトを読み取り、自動的に<head>タグ内に<title>や<meta>タグを生成します。
export const metadata: Metadata = {
  title: "ファームライフ - 農場シミュレーションゲーム",
  description: "野菜を育て、動物を飼い、釣りや狩りを楽しむ農場シミュレーションゲーム",
  generator: "v0.app",
  keywords: ["農場", "シミュレーション", "ゲーム", "React", "Next.js"],
  authors: [{ name: "v0" }],
  icons: {
    icon: [
      {
        url: "/icon-light-32x32.png",
        media: "(prefers-color-scheme: light)",
      },
      {
        url: "/icon-dark-32x32.png",
        media: "(prefers-color-scheme: dark)",
      },
      {
        url: "/icon.svg",
        type: "image/svg+xml",
      },
    ],
    apple: "/apple-icon.png",
  },
}

// ビューポートの設定
export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#f5f0e6" },
    { media: "(prefers-color-scheme: dark)", color: "#2d2a26" },
  ],
  width: "device-width",
  initialScale: 1,
}

/**
 * ルートレイアウトコンポーネント
 * React.StrictModeを使用して開発時の問題を検出
 */
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="ja">
      <body className={`font-sans antialiased`}>
        <React.StrictMode>
          <NotificationProvider>
            <GameProvider>
              <div className="relative flex min-h-screen flex-col">
                <main className="flex-1 pb-20">{children}</main>
                <Navigation />
                <NotificationDisplay />
                <AchievementWatcher />
              </div>
              <Analytics />
            </GameProvider>
          </NotificationProvider>
        </React.StrictMode>
      </body>
    </html>
  )
}
