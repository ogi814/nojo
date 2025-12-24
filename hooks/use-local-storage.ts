"use client"

/**
 * ローカルストレージ連携のカスタムフック
 * 
 * ブラウザの保存領域（ローカルストレージ）とStateを同期させるフックです。
 * ページをリロードしてもデータが消えないようにするために使います。
 */

import { useState, useEffect, useCallback } from "react"

/**
 * ローカルストレージと同期する状態を管理するカスタムフック
 * @param key ストレージキー
 * @param initialValue 初期値
 * @returns [値, セッター, 削除関数]
 */
export function useLocalStorage<T>(key: string, initialValue: T) {
  // useStateの遅延初期化（Lazy Initialization）
  // 関数を渡すことで、初期レンダリング時のみ実行されるようになります。
  // ローカルストレージへのアクセスは重い処理なので、毎回実行しないようにする重要なテクニックです。
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === "undefined") {
      return initialValue
    }

    try {
      // 保存された値があればそれを使い、なければ初期値を使います
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.error(`[v0] Error reading localStorage key "${key}":`, error)
      return initialValue
    }
  })

  // useEffectを使って、state（storedValue）が変わるたびに
  // 自動的にローカルストレージにも保存します（同期）。
  useEffect(() => {
    if (typeof window === "undefined") return

    try {
      window.localStorage.setItem(key, JSON.stringify(storedValue))
    } catch (error) {
      console.error(`[v0] Error setting localStorage key "${key}":`, error)
    }
  }, [key, storedValue])

  // 値を更新するセッター
  const setValue = useCallback((value: T | ((val: T) => T)) => {
    setStoredValue((prev) => {
      const valueToStore = value instanceof Function ? value(prev) : value
      return valueToStore
    })
  }, [])

  // 値を削除する関数
  const removeValue = useCallback(() => {
    if (typeof window === "undefined") return

    try {
      window.localStorage.removeItem(key)
      setStoredValue(initialValue)
    } catch (error) {
      console.error(`[v0] Error removing localStorage key "${key}":`, error)
    }
  }, [key, initialValue])

  return [storedValue, setValue, removeValue] as const
}
