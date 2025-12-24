'use client'

import * as React from 'react'
import {
  ThemeProvider as NextThemesProvider,
  type ThemeProviderProps,
} from 'next-themes'

/**
 * テーマプロバイダーコンポーネント
 * 
 * next-themesライブラリを使用して、ダークモード/ライトモードの切り替え機能を提供します。
 * アプリ全体をこのコンポーネントで囲むことで、どこからでもテーマにアクセスできるようになります。
 */
export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
