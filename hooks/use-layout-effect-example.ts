"use client"

/**
 * useLayoutEffectの使用例
 * 
 * useEffectとほぼ同じですが、実行タイミングが異なります。
 * - useEffect: 画面描画「後」に実行される（非同期）
 * - useLayoutEffect: 画面描画「前」に実行される（同期）
 * 
 * 要素のサイズを測ってレイアウトを調整する場合など、
 * 描画前に処理を完了させないと画面がチラつく（フリッカー）場合にこれを使います。
 */

import { useLayoutEffect, useRef, useState } from "react"

/**
 * 要素のサイズを測定するフック
 * useLayoutEffectを使用してレンダリング後すぐにサイズを取得
 */
export function useMeasure<T extends HTMLElement>() {
  const ref = useRef<T>(null)
  const [bounds, setBounds] = useState({
    width: 0,
    height: 0,
    top: 0,
    left: 0,
  })

  // useLayoutEffectを使用することで、ブラウザが画面を描画する前に
  // サイズ計測と状態更新を行います。これにより、
  // 「初期表示（サイズ0）」→「再描画（サイズ確定）」というチラつきを防げます。
  useLayoutEffect(() => {
    if (!ref.current) return

    const updateBounds = () => {
      const rect = ref.current?.getBoundingClientRect()
      if (rect) {
        setBounds({
          width: rect.width,
          height: rect.height,
          top: rect.top,
          left: rect.left,
        })
      }
    }

    updateBounds()

    // ResizeObserverでサイズ変更を監視
    const resizeObserver = new ResizeObserver(updateBounds)
    resizeObserver.observe(ref.current)

    return () => {
      resizeObserver.disconnect()
    }
  }, [])

  return { ref, bounds }
}

/**
 * スクロール位置を復元するフック
 * ページ遷移時などにスクロール位置を維持
 */
export function useScrollRestoration(key: string) {
  const scrollRef = useRef<HTMLElement>(null)

  // useLayoutEffectで描画前にスクロール位置を復元
  useLayoutEffect(() => {
    if (!scrollRef.current) return

    const savedPosition = sessionStorage.getItem(`scroll-${key}`)
    if (savedPosition) {
      scrollRef.current.scrollTop = Number.parseInt(savedPosition, 10)
    }

    return () => {
      if (scrollRef.current) {
        sessionStorage.setItem(`scroll-${key}`, scrollRef.current.scrollTop.toString())
      }
    }
  }, [key])

  return scrollRef
}
