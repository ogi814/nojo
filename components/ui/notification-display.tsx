"use client"

/**
 * 通知表示コンポーネント
 */

import { memo, useCallback } from "react"
import { useNotifications } from "@/contexts/notification-context"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { X } from "lucide-react"
import type { NotificationType } from "@/types/game.types"

/**
 * 通知タイプに応じたスタイルを取得
 */
function getNotificationStyles(type: NotificationType): string {
  switch (type) {
    case "success":
      return "bg-farm-grass text-white"
    case "error":
      return "bg-destructive text-destructive-foreground"
    case "warning":
      return "bg-farm-gold text-foreground"
    case "info":
    default:
      return "bg-primary text-primary-foreground"
  }
}

/**
 * 通知表示コンポーネント
 */
export const NotificationDisplay = memo(function NotificationDisplay() {
  const { notifications, removeNotification } = useNotifications()

  // 閉じるハンドラ
  const handleClose = useCallback(
    (id: string) => {
      removeNotification(id)
    },
    [removeNotification],
  )

  // 通知がない場合は何も表示しない
  if (notifications.length === 0) return null

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2 max-w-sm">
      {notifications.map((notification) => (
        <div
          key={notification.id}
          className={cn(
            "flex items-center gap-2 px-4 py-2 rounded-lg shadow-lg animate-grow",
            getNotificationStyles(notification.type),
          )}
          role="alert"
        >
          <span className="flex-1 text-sm">{notification.message}</span>
          <Button
            variant="ghost"
            size="sm"
            className="h-6 w-6 p-0 hover:bg-white/20"
            onClick={() => handleClose(notification.id)}
            aria-label="閉じる"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      ))}
    </div>
  )
})
