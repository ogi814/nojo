"use client"

import { useContext, useMemo } from "react"
import { GameContext } from "@/contexts/game-context"
import { DISHES } from "@/data/game-data"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import type { Dish } from "@/types/game.types"

/**
 * 個々のレシピを表示するカード
 */
function RecipeCard({ dish, onCook, canCook }: { dish: Dish; onCook: () => void; canCook: boolean }) {
  return (
    <div className="flex items-center gap-4 p-3 rounded-lg border bg-card">
      <div className="text-4xl">{dish.icon}</div>
      <div className="flex-1">
        <p className="font-bold">{dish.name}</p>
        <div className="text-xs text-muted-foreground space-y-1 mt-1">
          {dish.ingredients.map((ing) => (
            <p key={ing.itemId}>
              - {ing.itemId} x {ing.quantity}
            </p>
          ))}
        </div>
      </div>
      <Button onClick={onCook} disabled={!canCook} size="sm">
        {canCook ? "作る" : "材料不足"}
      </Button>
    </div>
  )
}

/**
 * 料理ステーションコンポーネント
 */
export function CookingStation() {
  const { state, dispatch } = useContext(GameContext)
  if (!state || !dispatch) {
    return <div>読み込み中...</div>
  }

  const { inventory } = state

  // 各レシピが調理可能かどうかを事前に計算（useMemoで最適化）
  const recipeStatus = useMemo(() => {
    return Object.values(DISHES).map((dish) => {
      const canCook = dish.ingredients.every((ingredient) => {
        const itemInInventory = inventory.find((i) => i.item.id === ingredient.itemId)
        return itemInInventory && itemInInventory.quantity >= ingredient.quantity
      })
      return { dish, canCook }
    })
  }, [inventory])

  const handleCook = (dishId: string) => {
    dispatch({ type: "COOK_DISH", payload: { dishId } })
  }

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="text-lg flex items-center gap-2">
          <span>🍳</span>
          <span>クッキングステーション</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {recipeStatus.map(({ dish, canCook }) => (
          <RecipeCard key={dish.id} dish={dish} onCook={() => handleCook(dish.id)} canCook={canCook} />
        ))}
      </CardContent>
    </Card>
  )
}
