import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

/**
 * クラス名を結合・整理するユーティリティ関数
 * 
 * Tailwind CSSを使う際によく使われる `clsx` と `tailwind-merge` を組み合わせています。
 * - clsx: 条件付きでクラスを適用したり、配列を文字列に結合したりします。
 * - tw-merge: Tailwindのクラスの競合を解決します（例: 'px-2' と 'px-4' があったら最後も勝ちにする）。
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
