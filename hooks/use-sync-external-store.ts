"use client"

/**
 * useSyncExternalStoreの使用例
 * 
 * React 18で導入された新しいフックです。
 * Reactの外側にあるデータ（ブラウザのAPIや外部ライブラリのストアなど）と
 * コンポーネントの状態を安全に同期させるために使います。
 * useEffect + useState で手動同期するよりも、テアリング（表示のズレ）が起きにくく推奨されています。
 */

import { useSyncExternalStore } from "react"

// =====================================================
// オンライン状態の監視
// =====================================================

/**
 * ブラウザのオンライン状態を監視するフック
 * useSyncExternalStoreを使用して外部のブラウザ状態と同期
 */
export function useOnlineStatus(): boolean {
  // スナップショットを取得する関数
  const getSnapshot = (): boolean => {
    return typeof navigator !== "undefined" ? navigator.onLine : true
  }

  // サーバーサイドレンダリング用のスナップショット
  const getServerSnapshot = (): boolean => {
    return true // サーバーでは常にオンラインと仮定
  }

  // 購読関数
  const subscribe = (callback: () => void): (() => void) => {
    if (typeof window === "undefined") return () => { }

    window.addEventListener("online", callback)
    window.addEventListener("offline", callback)

    return () => {
      window.removeEventListener("online", callback)
      window.removeEventListener("offline", callback)
    }
  }

  // 第1引数: 購読(subscribe)関数。データが変わった時に通知を受け取る登録処理。
  // 第2引数: 現在の値(snapshot)を取得する関数。
  // 第3引数: サーバーサイドレンダリング(SSR)時の初期値。
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}

// =====================================================
// ウィンドウサイズの監視
// =====================================================

interface WindowSize {
  width: number
  height: number
}

/**
 * ウィンドウサイズを監視するフック
 */
export function useWindowSize(): WindowSize {
  const getSnapshot = (): WindowSize => {
    if (typeof window === "undefined") {
      return { width: 0, height: 0 }
    }
    return {
      width: window.innerWidth,
      height: window.innerHeight,
    }
  }

  const getServerSnapshot = (): WindowSize => {
    return { width: 1200, height: 800 } // デフォルト値
  }

  const subscribe = (callback: () => void): (() => void) => {
    if (typeof window === "undefined") return () => { }

    window.addEventListener("resize", callback)
    return () => window.removeEventListener("resize", callback)
  }

  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}

// =====================================================
// ローカルストレージの監視（外部ストアパターン）
// =====================================================

/**
 * ローカルストレージを外部ストアとして扱うフック
 * 複数のタブ間で同期する
 */
export function useStorageSync<T>(key: string, defaultValue: T): T {
  const getSnapshot = (): T => {
    if (typeof window === "undefined") return defaultValue

    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : defaultValue
    } catch {
      return defaultValue
    }
  }

  const getServerSnapshot = (): T => defaultValue

  const subscribe = (callback: () => void): (() => void) => {
    if (typeof window === "undefined") return () => { }

    // storageイベントは他のタブでの変更を検知
    const handleStorage = (e: StorageEvent) => {
      if (e.key === key) callback()
    }

    window.addEventListener("storage", handleStorage)
    return () => window.removeEventListener("storage", handleStorage)
  }

  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}
