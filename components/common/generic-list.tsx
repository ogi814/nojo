"use client"
import type { ListProps } from "@/types/game.types"

/**
 * ジェネリックリストコンポーネント
 * 任意の型のアイテム配列をレンダリングする汎用コンポーネントです。
 * 
 * @template T アイテムの型（Generics）
 * 型引数 <T> を使うことで、どんな型のアイテム（文字列、数値、オブジェクトなど）にも対応できます。
 * 使用時に T が実際のデータ型（例: InventoryItem）に置き換わります。
 */
export function GenericList<T>({ items, renderItem, keyExtractor, emptyComponent }: ListProps<T>) {
  // アイテムが空の場合は空コンポーネントを表示
  if (items.length === 0 && emptyComponent) {
    return <>{emptyComponent}</>
  }

  return (
    <div className="space-y-2">
      {/* リストとキーのレンダリング - keyは一意（ユニーク）である必要があります */}
      {/* keyがないと、Reactはどの要素が変更されたか特定できず、再描画の効率が落ちます。 */}
      {items.map((item, index) => (
        <div key={keyExtractor(item)}>{renderItem(item, index)}</div>
      ))}
    </div>
  )
}
