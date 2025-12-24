"use client"

/**
 * 通知コンテキスト
 * 
 * 画面上にポップアップ表示される通知（トースト通知とも呼ばれます）を管理するコンテキストです。
 * 収穫完了時やレベルアップ時などに、ユーザーにメッセージを伝えます。
 */

import { createContext, useContext, useState, useCallback, useMemo, useId, type ReactNode } from "react"
import type { Notification, NotificationType, NotificationContextType } from "@/types/game.types"

// =====================================================
// コンテキストの作成
// =====================================================

const NotificationContext = createContext<NotificationContextType | undefined>(undefined)
NotificationContext.displayName = "NotificationContext"

// =====================================================
// プロバイダーコンポーネント
// =====================================================

interface NotificationProviderProps {
  children: ReactNode
}

export function NotificationProvider({ children }: NotificationProviderProps) {
  // useStateで通知リストを管理
  const [notifications, setNotifications] = useState<Notification[]>([])

  // useIdを使用して一意のIDプレフィックスを生成（React 18の新機能）
  const idPrefix = useId()

  /**
   * 通知を追加する関数
   * 
   * useCallback: 関数をメモ化（再利用）するためのフックです。
   * これにより、この関数が再生成されるのを防ぎ、子コンポーネントの不要な再レンダリングを抑えます。
   */
  const addNotification = useCallback(
    (type: NotificationType, message: string) => {
      const newNotification: Notification = {
        // useIdとタイムスタンプを組み合わせてユニークなIDを生成
        id: `${idPrefix}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        type,
        message,
        createdAt: Date.now(),
      }

      // setNotificationsに関数を渡すことで、現在の状態（prev）を元に新しい状態を作れます
      setNotifications((prev) => [...prev, newNotification])

      // 5秒後に通知を自動的に削除するタイマーをセット
      setTimeout(() => {
        setNotifications((prev) => prev.filter((n) => n.id !== newNotification.id))
      }, 5000)
    },
    [idPrefix], // 依存配列: idPrefixが変わった時だけ関数を作り直す
  )

  /**
   * 通知を削除する関数
   */
  const removeNotification = useCallback((id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id))
  }, [])

  // コンテキスト値をメモ化
  const contextValue = useMemo<NotificationContextType>(
    () => ({
      notifications,
      addNotification,
      removeNotification,
    }),
    [notifications, addNotification, removeNotification],
  )

  return <NotificationContext.Provider value={contextValue}>{children}</NotificationContext.Provider>
}

// =====================================================
// カスタムフック
// =====================================================

/**
 * 通知コンテキストを使用するカスタムフック
 */
export function useNotifications(): NotificationContextType {
  const context = useContext(NotificationContext)

  if (context === undefined) {
    throw new Error("useNotifications must be used within a NotificationProvider")
  }

  return context
}
