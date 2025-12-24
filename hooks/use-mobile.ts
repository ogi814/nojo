import * as React from 'react'

const MOBILE_BREAKPOINT = 768

/**
 * モバイル端末（スマホ）かどうかを判定するカスタムフック
 * 画面幅が768px未満かどうかをチェックします。
 */
export function useIsMobile() {
  const [isMobile, setIsMobile] = React.useState<boolean | undefined>(undefined)

  React.useEffect(() => {
    // window.matchMediaを使って、メディアクエリ（CSSの条件）にマッチするか監視します
    const mql = window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`)

    // 画面サイズが変わった時に実行される関数
    const onChange = () => {
      setIsMobile(window.innerWidth < MOBILE_BREAKPOINT)
    }

    // イベントリスナーを追加
    mql.addEventListener('change', onChange)

    // 初回チェック
    setIsMobile(window.innerWidth < MOBILE_BREAKPOINT)

    // クリーンアップ関数: コンポーネントが不要になったらリスナーを削除
    // これを忘れるとメモリリーク（メモリの無駄遣い）の原因になります
    return () => mql.removeEventListener('change', onChange)
  }, [])

  return !!isMobile
}
