"use client"

import { useContext } from "react"
import { GameContext } from "@/contexts/game-context"
import { ACHIEVEMENTS } from "@/data/game-data"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { CheckCircle, Lock } from "lucide-react"
import { cn } from "@/lib/utils"

export function AchievementPanel() {
  const { state } = useContext(GameContext)
  const unlockedAchievements = state.unlockedAchievements || {}

  return (
    <Card className="bg-card/80 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="text-lg flex items-center gap-2">
          <span>🏆</span>
          <span>実績</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {Object.values(ACHIEVEMENTS).map((ach) => {
          const isUnlocked = !!unlockedAchievements[ach.id]
          const isSecretAndLocked = ach.isSecret && !isUnlocked

          return (
            <div
              key={ach.id}
              className={cn(
                "flex items-center gap-4 p-3 rounded-lg border",
                isUnlocked ? "bg-farm-gold/10 border-farm-gold/30" : "bg-muted/50",
              )}
            >
              <div className={cn("text-4xl", !isUnlocked && "opacity-30")}>{isSecretAndLocked ? "🤫" : ach.icon}</div>
              <div className="flex-1">
                <p className={cn("font-bold", !isUnlocked && "text-muted-foreground")}>
                  {isSecretAndLocked ? "？？？" : ach.name}
                </p>
                <p className="text-xs text-muted-foreground">
                  {isSecretAndLocked ? "条件を満たすと解除されます。" : ach.description}
                </p>
              </div>
              {isUnlocked ? (
                <CheckCircle className="w-6 h-6 text-farm-gold" />
              ) : (
                <Lock className="w-6 h-6 text-muted-foreground/50" />
              )}
            </div>
          )
        })}
      </CardContent>
    </Card>
  )
}
