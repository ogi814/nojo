"use client"

/**
 * インベントリ管理のカスタムフック
 */

import { useCallback, useMemo } from "react"
import { useGame } from "@/contexts/game-context"
import { useNotifications } from "@/contexts/notification-context"
import type { ItemId, BaseItem } from "@/types/game.types"

/**
 * インベントリの管理と操作を提供するカスタムフック
 */
export function useInventory() {
  const { state, dispatch } = useGame()
  const { addNotification } = useNotifications()

  // インベントリ（メモ化）
  const inventory = useMemo(() => state.inventory, [state.inventory])

  // 所持金
  const money = useMemo(() => state.money, [state.money])

  // アイテム総数の計算
  // reduceメソッド: 配列の各要素を累積して一つの値にします。
  // ここでは各アイテムの quantity（個数）を合計しています。初期値は 0 です。
  const totalItems = useMemo(() => {
    return inventory.reduce((sum, item) => sum + item.quantity, 0)
  }, [inventory])

  /**
   * アイテムを販売する関数
   */
  const sellItem = useCallback(
    (itemId: ItemId, quantity: number) => {
      const invItem = inventory.find((i) => i.item.id === itemId)
      if (!invItem || invItem.quantity < quantity) {
        addNotification("error", "アイテムが不足しています")
        return false
      }

      const totalPrice = invItem.item.sellPrice * quantity
      dispatch({ type: "SELL_ITEM", payload: { itemId, quantity } })
      addNotification("success", `${invItem.item.name}を${quantity}個売却！ +${totalPrice}G`)
      return true
    },
    [dispatch, addNotification, inventory],
  )

  /**
   * アイテムを購入する関数
   */
  const buyItem = useCallback(
    (item: BaseItem, quantity: number) => {
      if (!item.buyPrice) {
        addNotification("error", "このアイテムは購入できません")
        return false
      }

      const totalCost = item.buyPrice * quantity
      if (money < totalCost) {
        addNotification("error", "お金が足りません")
        return false
      }

      dispatch({ type: "BUY_ITEM", payload: { item, quantity } })
      addNotification("success", `${item.name}を${quantity}個購入！ -${totalCost}G`)
      return true
    },
    [dispatch, addNotification, money],
  )

  /**
   * カテゴリでフィルタリングしたアイテムを取得
   */
  const getItemsByCategory = useCallback(
    (category: BaseItem["category"]) => {
      return inventory.filter((item) => item.item.category === category)
    },
    [inventory],
  )

  return {
    inventory,
    money,
    totalItems,
    sellItem,
    buyItem,
    getItemsByCategory,
  }
}
