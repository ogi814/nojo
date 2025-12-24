"use client"
import { FarmField } from "@/components/farm/farm-field"
import { Barn } from "@/components/farm/barn"

/**
 * 農場ページ
 * 畑と動物小屋を表示するメインのゲーム画面です。
 */
export function FarmPage() {
  return (
    <div className="space-y-4">
      {/* 畑セクション */}
      <FarmField />

      {/* 動物小屋セクション */}
      <Barn />
    </div>
  )
}
