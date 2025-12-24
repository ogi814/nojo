"use client"

/**
 * プログレスバーコンポーネント
 * 成長進捗や空腹度などの表示に使用
 */

import { memo } from "react"
import { cn } from "@/lib/utils"

interface ProgressBarProps {
  /** 進捗値（0-100） */
  value: number
  /** 最大値（デフォルト100） */
  max?: number
  /** バーの色クラス */
  colorClass?: string
  /** 高さクラス */
  heightClass?: string
  /** ラベルを表示するか */
  showLabel?: boolean
  /** 追加のクラス名 */
  className?: string
}

/**
 * プログレスバーコンポーネント
 * 
 * React.memo: コンポーネントをメモ化します。
 * props（value, maxなど）が変わらない限り、再レンダリングされなくなります。
 * プログレスバーのように頻繁に値が変わるコンポーネントの親が再レンダリングされた時、
 * 自身は再レンダリングをスキップしてパフォーマンスを向上させる効果があります。
 */
export const ProgressBar = memo(function ProgressBar({
  value,
  max = 100,
  colorClass = "bg-primary",
  heightClass = "h-2",
  showLabel = false,
  className,
}: ProgressBarProps) {
  // 進捗率を計算（0-100の範囲に制限）
  // Math.min/max を使って、0未満や100超えの異常値を防ぎます。
  const percentage = Math.min(Math.max((value / max) * 100, 0), 100)

  return (
    <div className={cn("w-full", className)}>
      {/* 条件付きレンダリング: ラベルが必要な場合のみ表示 */}
      {showLabel && (
        <div className="flex justify-between text-xs text-muted-foreground mb-1">
          <span>進捗</span>
          <span>{Math.round(percentage)}%</span>
        </div>
      )}

      {/* プログレスバー本体 */}
      <div className={cn("w-full bg-muted rounded-full overflow-hidden", heightClass)}>
        <div
          className={cn("h-full transition-all duration-300 ease-out rounded-full", colorClass)}
          style={{ width: `${percentage}%` }}
          role="progressbar"
          aria-valuenow={value}
          aria-valuemin={0}
          aria-valuemax={max}
        />
      </div>
    </div>
  )
})
