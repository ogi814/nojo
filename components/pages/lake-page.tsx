"use client"

/**
 * 湖ページ（釣り）
 * 釣りエリアを表示する画面です。
 */

import { FishingArea } from "@/components/fishing/fishing-area"

export function LakePage() {
  return (
    <div className="space-y-4">
      <FishingArea />
    </div>
  )
}
