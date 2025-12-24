"use client"

/**
 * ナビゲーションコンポーネント
 * Next.jsのLinkコンポーネントを使ってページ間を移動します。
 */

import { memo } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import type { GameLocation } from "@/types/game.types"

interface NavItem {
  href: `/${string}`
  location: GameLocation
  label: string
  icon: string
}

// 各ナビゲーションアイテムのパスを定義
const NAV_ITEMS: NavItem[] = [
  { href: "/farm", location: "farm", label: "農場", icon: "🏡" },
  { href: "/forest", location: "forest", label: "森", icon: "🌲" },
  { href: "/lake", location: "lake", label: "湖", icon: "🎣" },
  { href: "/market", location: "market", label: "市場", icon: "🏪" },
  { href: "/achievements", location: "achievements", label: "実績", icon: "🏆" },
]

/**
 * ナビゲーションコンポーネント
 */
export const Navigation = memo(function Navigation() {
  // usePathnameフックで現在のURLパスを取得
  const pathname = usePathname()

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-card/95 backdrop-blur-sm border-t p-2 z-50">
      <div className="flex justify-around max-w-lg mx-auto">
        {NAV_ITEMS.map((item) => {
          // 現在のパスがアイテムのhrefで始まるかどうかで現在地を判定
          const isActive = pathname.startsWith(item.href)

          return (
            <Button
              key={item.location}
              variant="ghost"
              className={cn(
                "flex flex-col items-center gap-1 h-auto py-2 px-3 sm:px-4",
                isActive && "bg-primary/10 text-primary",
              )}
              asChild // ButtonをLinkのラッパーとして機能させる
            >
              <Link href={item.href} aria-label={`${item.label}に移動`} aria-current={isActive ? "page" : undefined}>
                <span className="text-xl sm:text-2xl">{item.icon}</span>
                <span className="text-xs">{item.label}</span>
              </Link>
            </Button>
          )
        })}
      </div>
    </nav>
  )
})
