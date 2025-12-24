"use client"

/**
 * useTransitionを使用した非優先更新のカスタムフック
 * React 18の並行機能を活用
 */

import { useTransition, useCallback } from "react"
import { useGame } from "@/contexts/game-context"
import type { GameAction } from "@/types/game.types"

/**
 * useTransitionを使用した非優先更新のカスタムフック
 * 
 * React 18の並行レンダリング機能（Concurrent Features）の一つです。
 * 重い処理を「急ぎではない（non-urgent）」としてマークすることで、
 * ユーザーのキー入力やクリックなどの重要な操作をブロックせずに、裏側で処理を実行できます。
 */
export function useTransitionAction() {
  // isPending: トランジション（裏での処理）が進行中かどうか
  // startTransition: 優先度の低い更新をラップするための関数
  const [isPending, startTransition] = useTransition()
  const { dispatch } = useGame()

  /**
   * 非優先でアクションを実行
   * UIの更新は優先され、状態更新は後回しになる
   */
  const dispatchWithTransition = useCallback(
    (action: GameAction) => {
      startTransition(() => {
        dispatch(action)
      })
    },
    [dispatch],
  )

  return {
    isPending, // トランジション中かどうか
    dispatchWithTransition,
  }
}

/**
 * useDeferredValueの使用例
 * 
 * useTransitionの値バージョンです。
 * 値の変更を遅らせることで、例えば検索ボックスで一文字打つごとに
 * 重いフィルタリング処理が走って画面が固まるのを防ぎます。
 * 入力が落ち着くまでフィルタリング結果の更新を後回しにします。
 */
import { useDeferredValue } from "react"

export function useDeferredSearch(searchTerm: string) {
  // 入力値の遅延バージョンを取得
  // UIは即座に更新されるが、フィルタリング処理は遅延実行される
  const deferredSearchTerm = useDeferredValue(searchTerm)

  const { state } = useGame()

  // 遅延された検索語でインベントリをフィルタリング
  const filteredInventory = state.inventory.filter((item) =>
    item.item.name.toLowerCase().includes(deferredSearchTerm.toLowerCase()),
  )

  return {
    deferredSearchTerm,
    filteredInventory,
    isStale: searchTerm !== deferredSearchTerm, // 遅延中かどうか
  }
}
