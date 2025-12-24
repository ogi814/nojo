### **【改訂版 v4.0】第6章: Context APIとuseReducer 〜アプリケーション全体での状態管理〜**

#### **この章で到達するレベル**

この章を読破したあなたは、Reactアプリケーションにおける「状態管理」の課題を深く理解し、Reactに組み込まれた強力なツールであるContext APIと`useReducer`フックを使いこなせるようになります。あなたは以下の問いに自信を持って答えられるようになるでしょう。

*   「Prop Drilling」がなぜ問題で、Context APIがそれをどのように解決するのか？Context APIの内部的な仕組みと、パフォーマンスへの影響は？
*   `createContext`, `Provider`, `useContext`の3つの要素が、どのように連携して機能するのか？複数のContextを使い分ける基準は？
*   どのような時に`useState`ではなく`useReducer`を選ぶべきか？その判断基準と、`useReducer`がもたらす予測可能性、テスト容易性、関心の分離といったメリットは？
*   Reducer関数とActionオブジェクトの役割とは何か？Actionの型定義における判別可能な共用体の活用方法は？
*   `useContext`と`useReducer`を組み合わせることで、なぜReduxのような外部ライブラリなしでもスケーラブルな状態管理が可能になるのか？その利点と限界は？
*   アプリケーション全体で利用可能なグローバルな`GameContext`を、どのように設計し、実装するのか？`localStorage`との連携による永続化の仕組みは？
*   Contextを消費するコンポーネントの不要な再レンダリングを防ぐための最適化戦略は？

この章は、あなたがコンポーネントレベルの状態管理から脱却し、アプリケーション全体のデータを一元的かつ安全に管理するための、高度な設計パターンを習得することを目的としています。

---

### **【第1部：Prop Drillingからの脱出とContext APIの基礎】**

この部では、アプリケーションの規模が大きくなるにつれて避けられない「Prop Drilling」という問題の根深さを再確認し、ReactのContext APIが提供するエレガントな解決策を学びます。Context APIの基本的な使い方から、その内部的な仕組み、そしてパフォーマンスへの影響までを深く掘り下げます。

---

### **6.1 問題再訪：Prop Drilling（プロップのバケツリレー）地獄**

第5章の最後で、私たちは`FarmPageClient`が持つ状態（`money`、`animals`、`plots`など）を、遠く離れた孫コンポーネントで使いたい場合に発生する問題に直面しました。

例えば、プレイヤーの所持金（`money`）をヘッダーと農場ページの両方で表示・使用したいとします。この状態を最上位の`RootLayout`で管理すると、データの流れは以下のようになります。

```mermaid
graph TD
    A[RootLayout (money, setMoney)]
    A -- money, setMoney --> B(Header)
    A -- money, setMoney --> C(FarmPage)
    C -- money, setMoney --> D(FarmField)
    D -- money, setMoney --> E(FarmPlot)

    subgraph E
        F[種を買うボタン]
    end

    style B fill:#f9f,stroke:#333,stroke-width:2px
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style D fill:#f9f,stroke:#333,stroke-width:2px
    style E fill:#f9f,stroke:#333,stroke-width:2px
```
*図6-1: Prop Drillingの悪夢 - 複数階層にわたるPropsの受け渡し*

`FarmPage`や`FarmField`は、`money`や`setMoney`を全く使いません。彼らの唯一の仕事は、受け取ったPropsをそのまま下の階層に流す「バケツリレー」をすることだけです。

**Prop Drillingが引き起こす深刻な問題:**
1.  **保守性の低下とリファクタリングの困難さ:**
    *   中間コンポーネントのPropsの型定義を、ただ通過させるためだけに修正する必要があり、リファクタリングが非常に面倒になります。
    *   例えば、`money`の型が`number`から`BigInt`に変わった場合、`RootLayout`から`FarmPlot`までのすべてのコンポーネントのPropsの型定義と、Propsを渡している箇所を修正しなければなりません。
2.  **コードの可読性の低下:**
    *   コンポーネントのPropsリストが長くなり、どのPropsがそのコンポーネント自身で使われ、どのPropsが子に渡されているのかが分かりにくくなります。
    *   新しい開発者がコードを読んだ際、Propsの出所や最終的な使われ方を追跡するのが困難になります。
3.  **コンポーネントの密結合:**
    *   コンポーネントが本来知る必要のない情報（Propsの存在や型）に依存してしまい、再利用性が損なわれます。`FarmField`は`money`を必要としないにも関わらず、`money`を受け取るPropsのインターフェースを持つことになります。
4.  **不要な再レンダリングの可能性:**
    *   `money`が更新されると、それを受け取っているすべての中間コンポーネントが、たとえそれを使っていなくても再レンダリングされる可能性があります。`React.memo`などの最適化手法で回避は可能ですが、根本的な解決にはならず、コードが複雑になります。
5.  **テストの複雑化:**
    *   コンポーネントをテストする際に、そのコンポーネントが直接使わないPropsまでモックとして渡す必要があり、テストコードが冗長になります。

これらの問題は、アプリケーションの規模が大きくなるにつれて顕著になり、開発者の生産性を著しく低下させます。

**思考実験:**
「Nojo Farm」で、プレイヤーのインベントリに表示される各アイテムカードに、現在の所持金とアイテムの価格を比較して「購入可能」かどうかを示すUIを追加するとします。所持金は`FarmPageClient`で管理されており、`Inventory`コンポーネント、`InventoryCategory`コンポーネント、`InventoryItemCard`コンポーネントという3階層を経て`InventoryItemCard`に到達します。このとき、所持金を`InventoryItemCard`に渡すために発生するProp Drillingの具体的な問題点を、コードの変更箇所、可読性、メンテナンス性の観点から説明してください。

---

### **6.2 解決策：React Context API**

Context APIは、このProp Drilling問題を解決するための、Reactに組み込まれた公式の機能です。コンポーネントツリーの任意の場所に「大域的なデータ置き場」を作り、その中のデータを、階層の深さに関わらず、どのコンポーネントからでも直接読み取れるようにします。

**たとえ話：掲示板システム**
*   **Prop Drilling:** 特定の人に情報を伝えるために、列に並んだ人々が一人ずつ「伝言ゲーム」をするようなもの。途中で情報が歪んだり、関係ない人が煩わされたりする。
*   **Context API:** 建物の中央にある大きな「**掲示板**」。情報を伝えたい人（Provider）がそこに情報を貼り出せば、情報を知りたい人（Consumer）は誰でも、いつでも、直接その掲示板を見に行くことができる。途中の人々を煩わせる必要はない。

#### **Context APIの3つの主要要素**

1.  **`createContext(defaultValue)`**:
    *   新しいContextオブジェクト（掲示板）を作成します。
    *   `defaultValue`は、`Provider`が見つからなかった場合（または`Provider`の`value`が`undefined`の場合）にのみ使われる値です。通常は`null`または`undefined`を渡し、`useContext`内で`Provider`が存在しない場合のエラーハンドリングを行います。
2.  **`<MyContext.Provider value={...}>`**:
    *   作成したContextの`Provider`コンポーネント。
    *   `value`プロパティに渡した値を、配下の子孫コンポーネントに提供（掲示板に貼り出し）します。
    *   `Provider`の`value`が変更されると、その`Provider`の配下にあるすべての`useContext`を使用しているコンポーネントが再レンダリングされます。
3.  **`useContext(MyContext)`**:
    *   `Provider`によって提供された値を読み取る（掲示板を見る）ためのフック。
    *   このフックを呼び出すコンポーネントは、最も近い祖先の`Provider`から`value`を取得します。

```mermaid
graph TD
    A[Context Object<br>(createContext)] --> B[Provider<br>(MyContext.Provider)];
    B -- "value={data}" --> C[Component Tree];
    C --> D[Consumer Component<br>(useContext)];
    D -- "data" --> E[UI];
```
*図6-2: Context APIのデータフロー*

#### **シンプルな実践例：テーマ切り替え (Nojo FarmのUIテーマ)**

```tsx
// contexts/theme-context.tsx
"use client"; // クライアントコンポーネントとして実行

import React, { createContext, useContext, useState, useEffect } from 'react';

type Theme = 'light' | 'dark';

// 1. Context（掲示板）を作成
// 初期値はnullとし、Providerがない場合のエラーハンドリングをuseThemeフックで行う
const ThemeContext = createContext<{ theme: Theme; toggleTheme: () => void; } | null>(null);

// 2. Provider（情報提供者）コンポーネントを作成
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  // localStorageから初期テーマを読み込むロジック
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window !== 'undefined' && window.localStorage) {
      const savedTheme = localStorage.getItem('theme') as Theme;
      if (savedTheme) return savedTheme;
    }
    // システムのダークモード設定をデフォルトにする
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  });

  // themeが変更されたら、HTML要素にクラスを適用し、localStorageに保存
  useEffect(() => {
    const root = window.document.documentElement;
    root.classList.remove(theme === 'dark' ? 'light' : 'dark'); // 既存のテーマクラスを削除
    root.classList.add(theme); // 新しいテーマクラスを追加
    localStorage.setItem('theme', theme);
  }, [theme]); // themeが変更されるたびに実行

  const toggleTheme = () => setTheme(current => (current === 'light' ? 'dark' : 'light'));

  // Providerのvalueに、状態と更新関数を渡す
  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// 3. useContextをラップしたカスタムフック（情報閲覧者）を作成
export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined || context === null) { // nullチェックも追加
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}
```

**使い方:**
```tsx
// app/layout.tsx (Next.jsのルートレイアウト)
import { ThemeProvider } from '@/contexts/theme-context';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body>
        <ThemeProvider> {/* アプリ全体をProviderでラップ */}
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}

// components/common/ThemeToggleButton.tsx (深い階層のコンポーネント)
"use client";
import { useTheme } from '@/contexts/theme-context';
import { Button } from '@/components/ui/button'; // shadcn/uiのButton

export function ThemeToggleButton() {
  const { theme, toggleTheme } = useTheme(); // Propsを受け取らずに直接Contextの値を取得！

  return (
    <Button onClick={toggleTheme} variant="outline" size="sm">
      {theme === 'light' ? '🌙 ダークモード' : '☀️ ライトモード'}
    </Button>
  );
}
```
`ThemeToggleButton`は、親コンポーネントからPropsを一切受け取ることなく、グローバルなテーマの状態とそれを変更する関数に直接アクセスできています。Prop Drillingは完全に解消されました。

**Context APIのパフォーマンスに関する考慮事項:**
Contextの`value`が変更されると、その`Provider`の配下にあるすべての`useContext`を使用しているコンポーネントが**無条件に再レンダリング**されます。これは、`value`がオブジェクトの場合、たとえオブジェクトのプロパティが変更されていなくても、参照が変更されるだけで再レンダリングがトリガーされる可能性があるため、注意が必要です。
*   **解決策:**
    *   `value`に渡すオブジェクトは`useMemo`でメモ化する。
    *   Contextを細かく分割し、関連性の高いデータのみを一つのContextにまとめる。
    *   Contextを消費するコンポーネントを`React.memo`でメモ化する。

**複数のContextの使い分け:**
アプリケーションの状態をすべて一つの巨大なContextにまとめるのではなく、関心事ごとに複数のContextに分割することも有効です。例えば、認証情報用の`AuthContext`、テーマ用の`ThemeContext`、ゲームの状態用の`GameContext`などです。これにより、特定のContextの`value`が変更されても、そのContextを消費しているコンポーネントだけが再レンダリングされ、パフォーマンスへの影響を局所化できます。

**思考実験:**
「Nojo Farm」で、ゲームのサウンド設定（BGMの音量、効果音の音量、ミュート状態）を管理する`SoundSettingsContext`を実装するとします。このContextは、`SoundSettingsProvider`と`useSoundSettings`フックを提供し、アプリケーションのどこからでもサウンド設定にアクセスできるようにします。
1.  `SoundSettingsContext`の型定義と`createContext`の呼び出しを記述してください。
2.  `SoundSettingsProvider`コンポーネントを実装し、`useState`を使ってサウンド設定を管理し、`value`として提供してください。
3.  `useSoundSettings`フックを実装し、`Provider`が見つからない場合のエラーハンドリングを含めてください。
4.  この`SoundSettingsContext`を`GameContext`と組み合わせて使用する場合、`app/layout.tsx`でどのように`Provider`をネストしますか？

---

### **【第2部：より高度な状態管理 `useReducer`】**

Context APIはデータの受け渡し問題を解決しますが、そのデータ自体の更新ロジックが複雑になると、`useState`だけでは管理が難しくなってきます。特に、複数の状態が互いに関連している場合や、次の状態が前の状態に依存して複雑に変化する場合に、`useState`だけではコードが煩雑になり、バグの温床となる可能性があります。そこで登場するのが`useReducer`フックです。

---

### **6.3 `useState`の限界と`useReducer`の必要性**

`useState`はシンプルな状態管理には最適ですが、状態が複雑になるとコードが煩雑になりがちです。

*   **複数の状態が互いに関連している場合:**
    ```tsx
    // 悪い例: 関連する状態がuseStateでバラバラに管理されている
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<Error | null>(null);
    const [data, setData] = useState<any>(null);

    const fetchData = async () => {
      setIsLoading(true);
      setError(null); // 常にエラーをリセット
      try {
        const res = await fetch('/api/data');
        const json = await res.json();
        setData(json);
      } catch (err) {
        setError(err as Error);
      } finally {
        setIsLoading(false);
      }
    };
    ```
    これらの状態は、API通信の一連のプロセス（開始→成功/失敗）の中で密接に関連していますが、それぞれが別の`useState`で管理されているため、更新ロジックが分散しがちです。`setIsLoading(false)`を忘れたり、`setError(null)`を書き忘れたりするミスが発生しやすくなります。

*   **次の状態が前の状態に依存して複雑に変化する場合:**
    ゲームの状態のように、「プレイヤーがアイテムAを使ったら、所持金が減り、経験値が増え、アイテムAの個数が減る」といった複数の状態変更が一度のアクションで発生する場合、`useState`でこれを管理すると更新ロジックがコンポーネント内に散らばり、見通しが悪くなります。また、`setMoney(prev => prev - cost)`のように関数更新を使っても、複数の`useState`の更新が同時に行われると、意図しない順序で実行されたり、一部の更新が漏れたりするリスクがあります。

---

### **6.4 `useReducer`：状態更新の司令塔**

`useReducer`は、このような複雑な状態更新ロジックをコンポーネントから分離し、一元管理するためのフックです。これは、FluxやReduxといった状態管理ライブラリの思想に強く影響を受けています。

**たとえ話：レストランの注文システム**
*   **`useState`:** お客さん（コンポーネント）が、厨房（状態更新ロジック）に直接「塩を取って」「火を強めて」と個別の指示をバラバラに出すようなもの。厨房は混乱しがち。
*   **`useReducer`:** お客さん（コンポーネント）は、ウェイター（`dispatch`関数）に「**ペペロンチーノを一つ**」という注文票（`action`オブジェクト）を渡すだけ。厨房（`reducer`関数）では、その注文票を見て、塩を振る、パスタを茹でる、ソースと絡める、といった一連の調理手順を間違いなく実行する。

#### **`useReducer`の3つの主要要素**

1.  **Reducer関数 `(state, action) => newState`**:
    *   現在の`state`と、実行すべき内容を記述した`action`オブジェクトを受け取り、**新しい状態 (`newState`)** を返す純粋関数。
    *   **すべての状態更新ロジックはこの関数内に集約されます。**
    *   Reducer関数は**純粋関数**である必要があります。つまり、同じ`state`と`action`が与えられた場合、常に同じ`newState`を返し、外部の変数やAPI呼び出しなどの副作用を持たないようにします。
2.  **初期状態 `initialState`**:
    *   このReducerが管理する状態の初期値。
3.  **`dispatch`関数**:
    *   `action`オブジェクトをReducerに送る（注文票を厨房に渡す）ための関数。コンポーネントはこの関数を呼び出すことで、状態の更新を「依頼」します。

#### **実践例：カウンターの再実装と複雑なアクション**

```tsx
import React, { useReducer } from 'react';

// 1. Actionの型を定義 (どんな注文票があるか)
// 判別可能な共用体 (Discriminated Union) を使用して型安全性を高める
type CounterAction =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'RESET' }
  | { type: 'ADD_AMOUNT'; payload: number }; // payload: 追加情報

// 2. Reducer関数を定義 (厨房のレシピ)
// stateとactionの型を明示的に指定
function counterReducer(state: { count: number }, action: CounterAction): { count: number } {
  switch (action.type) {
    case 'INCREMENT':
      return { count: state.count + 1 };
    case 'DECREMENT':
      return { count: state.count - 1 };
    case 'RESET':
      return { count: 0 };
    case 'ADD_AMOUNT':
      // payloadの型は action.type === 'ADD_AMOUNT' の場合に number であることが保証される
      return { count: state.count + action.payload };
    default:
      // 未知のアクションタイプが来た場合にエラーを投げる (網羅性チェック)
      // const exhaustiveCheck: never = action; // TypeScriptがエラーを検出
      throw new Error('Unknown action type');
  }
}

function Counter() {
  // 3. useReducerを呼び出す
  // state: 現在の状態、dispatch: 状態更新を依頼する関数
  const [state, dispatch] = useReducer(counterReducer, { count: 0 });

  return (
    <div className="p-4 border rounded-md space-y-2">
      <p className="text-xl font-bold">Count: {state.count}</p>
      {/* 4. dispatch関数でActionを発行（注文票を渡す） */}
      <button onClick={() => dispatch({ type: 'INCREMENT' })} className="bg-blue-500 text-white px-3 py-1 rounded mr-2">+1</button>
      <button onClick={() => dispatch({ type: 'DECREMENT' })} className="bg-red-500 text-white px-3 py-1 rounded mr-2">-1</button>
      <button onClick={() => dispatch({ type: 'RESET' })} className="bg-gray-500 text-white px-3 py-1 rounded mr-2">Reset</button>
      <button onClick={() => dispatch({ type: 'ADD_AMOUNT', payload: 5 })} className="bg-green-500 text-white px-3 py-1 rounded">+5</button>
    </div>
  );
}
```
`Counter`コンポーネント自身は、状態が「どのように」更新されるかのロジックを一切知りません。ただ、`dispatch`を通じて「何をしたいか」を表明するだけです。これにより、**UI（ビュー）とビジネスロジック（状態更新）が綺麗に分離**されます。Reducer関数は純粋関数であるため、テストも非常に容易になります。

**`useReducer`の初期化関数:**
`useReducer`は、第3引数に初期化関数を受け取ることができます。これは、初期状態の計算が高コストな場合や、初期状態を遅延して計算したい場合に有用です。

```typescript
function init(initialCount: number) {
  return { count: initialCount };
}

function CounterWithLazyInit({ initialCount = 0 }) {
  const [state, dispatch] = useReducer(counterReducer, initialCount, init);
  // ...
}
```

**思考実験:**
「Nojo Farm」で、プレイヤーのインベントリを管理する`useInventoryReducer`フックを実装するとします。インベントリの状態は、`items: { [itemId: string]: number }`（アイテムIDと数量のマップ）とします。このReducerは、`ADD_ITEM`（`itemId`, `quantity`）、`REMOVE_ITEM`（`itemId`, `quantity`）、`CLEAR_INVENTORY`といったアクションを処理できるようにしてください。
1.  `InventoryState`と`InventoryAction`の型を定義してください。
2.  `inventoryReducer`関数を実装し、各アクションタイプに応じた状態更新ロジックを記述してください。特に、`ADD_ITEM`アクションで既存のアイテムの数量を増やすロジックを考慮してください。
3.  この`useInventoryReducer`フックを`InventoryDisplay`コンポーネントでどのように使用しますか？

---

### **【第3部：グローバルなゲームコンテキストの構築】**

いよいよ、Context APIと`useReducer`という2つの強力な武器を組み合わせ、この農場ゲームの心臓部となるグローバルな状態管理システムを構築します。このパターンは、Reactの標準機能だけでReduxのような集中型状態管理を実現する、非常に効果的な方法です。

---

### **6.5 究極のパターン：`useContext` + `useReducer`**

この2つを組み合わせることで、Reactに標準で備わっている機能だけで、スケーラブルで高性能な状態管理が実現できます。

*   `useReducer`が、複雑な状態とその更新ロジックを一つの場所に**集約**する。これにより、状態更新の予測可能性とテスト容易性が向上します。
*   `useContext`が、その集約された状態（`state`）と更新依頼用の`dispatch`関数を、アプリケーションのどこからでもアクセスできるように**配信**する。これにより、Prop Drillingの問題が解消されます。

```mermaid
graph TD
    A[React Component] --> B[dispatch(action)];
    B --> C[GameContext.Provider];
    C --> D[gameReducer(state, action)];
    D -- "newState" --> C;
    C -- "state" --> E[useGameContext()];
    E --> A;
```
*図6-3: `useContext` + `useReducer`のデータフロー*

**このパターンの利点:**
*   **標準機能:** 外部ライブラリに依存しないため、バンドルサイズが小さく、学習コストも比較的低い。
*   **関心の分離:** UIコンポーネントは`dispatch`するだけでよく、状態更新ロジックはReducerに集中。
*   **予測可能性:** Reducerは純粋関数であるため、状態の変化が予測しやすい。
*   **テスト容易性:** Reducer関数は独立してテスト可能。
*   **Prop Drillingの解消:** どのコンポーネントからでもグローバルな状態にアクセス可能。

**このパターンの限界:**
*   **パフォーマンス:** Contextの`value`が変更されると、そのContextを消費しているすべてのコンポーネントが再レンダリングされるため、非常に頻繁に更新される大規模な状態には注意が必要。
*   **ミドルウェアの欠如:** Reduxのようなミドルウェア（非同期処理のハンドリング、ロギングなど）の機能は標準では提供されない。必要であれば、カスタムフックや`useEffect`で実装する必要がある。

---

### **6.6 `GameContext`の実装：Nojo Farmの心臓部**

#### **ステップ1：型の定義 (`types/game.types.ts`)**
まず、アプリケーション全体で共有する状態（`GameState`）と、その状態を変更するためのアクション（`GameAction`）の型を定義します。ここでは、`system-design-document.md`で定義されている`GameState`と`GameAction`を参考に、より詳細な型を定義します。

```ts
// types/game.types.ts

// プリミティブな型
export type CropStage = 'seed' | 'growth' | 'harvest';

// オブジェクトの型
export interface Crop {
  id: string;
  name: string;
  stage: CropStage;
  plantedAt: number; // 植えられたゲーム内時間 (タイムスタンプ)
}

export interface Plot {
  id: number;
  crop: Crop | null;
}

export interface Animal {
  id: string;
  name: string;
  species: string;
  fed: boolean;
  lastFedAt: number | null; // 最後に餌を与えたゲーム内時間
}

export interface InventoryItem {
  id: string;
  name: string;
  quantity: number;
  type: 'seed' | 'product' | 'tool';
}

export interface Achievement {
  id: string;
  name: string;
  description: string;
  unlocked: boolean;
}

// アプリケーション全体のグローバルな状態 (GameState)
export interface GameState {
  username: string;
  money: number;
  gameTime: number; // ゲーム内時間の経過（秒）
  plots: Plot[];
  animals: Animal[];
  inventory: InventoryItem[];
  achievements: Achievement[];
}

// 実行可能なすべてのアクションを定義（判別可能な共用体）
export type GameAction =
  // 時間経過
  | { type: 'TICK'; payload: { seconds: number } }
  // 農場関連
  | { type: 'PLANT'; payload: { plotId: number; cropId: string; cropName: string; seedPrice: number; } }
  | { type: 'HARVEST'; payload: { plotId: number; productId: string; productName: string; sellPrice: number; } }
  | { type: 'FEED_ANIMAL'; payload: { animalId: string; foodId: string; foodQuantity: number; } }
  // 市場関連
  | { type: 'BUY_ITEM'; payload: { itemId: string; quantity: number; price: number; } }
  | { type: 'SELL_ITEM'; payload: { itemId: string; quantity: number; price: number; } }
  // 実績関連
  | { type: 'UNLOCK_ACHIEVEMENT'; payload: { achievementId: string; } }
  // ユーザー関連
  | { type: 'SET_USERNAME'; payload: { username: string; } }
  // ゲームの状態をロード
  | { type: 'LOAD_GAME_STATE'; payload: { state: GameState; } };
```

#### **ステップ2：Reducerの作成 (`contexts/game-reducer.ts`)**
次に、`GameAction`を受け取って`GameState`を更新するロジックをすべて詰め込んだReducer関数を作成します。Reducerは純粋関数であり、副作用を持たないように注意します。

```ts
// contexts/game-reducer.ts (新規作成)
import type { GameState, GameAction, CropStage, InventoryItem } from '@/types/game.types';

// ゲームのマスターデータ（例: 作物の成長時間、販売価格など）
// 実際にはAPIから取得するか、静的ファイルとして管理
const MASTER_DATA = {
  crops: {
    'tomato-seed': { id: 'tomato-seed', name: 'トマトの種', seedPrice: 50, growthTime: 300, harvestTime: 600, productId: 'tomato', productPrice: 100 },
    'carrot-seed': { id: 'carrot-seed', name: 'ニンジンの種', seedPrice: 30, growthTime: 200, harvestTime: 400, productId: 'carrot', productPrice: 60 },
  },
  products: {
    'tomato': { id: 'tomato', name: 'トマト', sellPrice: 100 },
    'carrot': { id: 'carrot', name: 'ニンジン', sellPrice: 60 },
  },
  animals: {
    'cow': { id: 'cow', name: '牛', feedInterval: 1800 }, // 30分ごとに空腹になる
  },
};

export const gameReducer = (state: GameState, action: GameAction): GameState => {
  switch (action.type) {
    case 'TICK': {
      const newGameTime = state.gameTime + action.payload.seconds;
      // 時間経過による作物の成長判定
      const updatedPlots = state.plots.map(plot => {
        if (plot.crop) {
          const cropMaster = MASTER_DATA.crops[`${plot.crop.id}-seed`]; // 種IDからマスターデータを取得
          if (!cropMaster) return plot;

          const timeElapsed = newGameTime - plot.crop.plantedAt;
          let newStage: CropStage = plot.crop.stage;

          if (plot.crop.stage === 'seed' && timeElapsed >= cropMaster.growthTime) {
            newStage = 'growth';
          } else if (plot.crop.stage === 'growth' && timeElapsed >= cropMaster.harvestTime) {
            newStage = 'harvest';
          }
          return { ...plot, crop: { ...plot.crop, stage: newStage } };
        }
        return plot;
      });

      // 時間経過による動物の空腹判定
      const updatedAnimals = state.animals.map(animal => {
        if (animal.fed && animal.lastFedAt !== null) {
          const animalMaster = MASTER_DATA.animals[animal.species];
          if (!animalMaster) return animal;
          if (newGameTime - animal.lastFedAt >= animalMaster.feedInterval) {
            return { ...animal, fed: false, lastFedAt: null }; // 空腹状態に戻す
          }
        }
        return animal;
      });

      return {
        ...state,
        gameTime: newGameTime,
        plots: updatedPlots,
        animals: updatedAnimals,
      };
    }

    case 'PLANT': {
      const { plotId, cropId, cropName, seedPrice } = action.payload;
      if (state.money < seedPrice) return state; // 所持金不足

      const cropMaster = MASTER_DATA.crops[cropId];
      if (!cropMaster) return state;

      return {
        ...state,
        money: state.money - seedPrice,
        plots: state.plots.map(plot =>
          plot.id === plotId && !plot.crop
            ? { ...plot, crop: { id: cropId, name: cropName, stage: 'seed', plantedAt: state.gameTime } }
            : plot
        ),
        inventory: state.inventory.map(item =>
          item.id === cropId && item.quantity > 0
            ? { ...item, quantity: item.quantity - 1 }
            : item
        ).filter(item => item.quantity > 0), // 数量が0になったアイテムは削除
      };
    }

    case 'HARVEST': {
      const { plotId, productId, productName, sellPrice } = action.payload;
      const targetPlot = state.plots.find(p => p.id === plotId);
      if (!targetPlot || targetPlot.crop?.stage !== 'harvest') return state; // 収穫できない

      const productMaster = MASTER_DATA.products[productId];
      if (!productMaster) return state;

      const existingProductIndex = state.inventory.findIndex(item => item.id === productId);
      const updatedInventory = existingProductIndex !== -1
        ? state.inventory.map((item, index) =>
            index === existingProductIndex ? { ...item, quantity: item.quantity + 1 } : item
          )
        : [...state.inventory, { id: productId, name: productName, quantity: 1, type: 'product' }];

      return {
        ...state,
        money: state.money + sellPrice,
        plots: state.plots.map(plot =>
          plot.id === plotId ? { ...plot, crop: null } : plot
        ),
        inventory: updatedInventory,
      };
    }

    case 'FEED_ANIMAL': {
      const { animalId, foodId, foodQuantity } = action.payload;
      const targetAnimal = state.animals.find(a => a.id === animalId);
      if (!targetAnimal || targetAnimal.fed) return state; // 満腹または動物が存在しない

      const existingFoodIndex = state.inventory.findIndex(item => item.id === foodId && item.quantity >= foodQuantity);
      if (existingFoodIndex === -1) return state; // 餌が足りない

      return {
        ...state,
        animals: state.animals.map(animal =>
          animal.id === animalId ? { ...animal, fed: true, lastFedAt: state.gameTime } : animal
        ),
        inventory: state.inventory.map((item, index) =>
          index === existingFoodIndex ? { ...item, quantity: item.quantity - foodQuantity } : item
        ).filter(item => item.quantity > 0),
      };
    }

    case 'BUY_ITEM': {
      const { itemId, quantity, price } = action.payload;
      const totalCost = quantity * price;
      if (state.money < totalCost) return state; // 所持金不足

      const existingItemIndex = state.inventory.findIndex(item => item.id === itemId);
      const updatedInventory = existingItemIndex !== -1
        ? state.inventory.map((item, index) =>
            index === existingItemIndex ? { ...item, quantity: item.quantity + quantity } : item
          )
        : [...state.inventory, { id: itemId, name: itemId, quantity: quantity, type: 'seed' }]; // 仮でnameとtypeを設定

      return {
        ...state,
        money: state.money - totalCost,
        inventory: updatedInventory,
      };
    }

    case 'SELL_ITEM': {
      const { itemId, quantity, price } = action.payload;
      const totalRevenue = quantity * price;
      const existingItemIndex = state.inventory.findIndex(item => item.id === itemId && item.quantity >= quantity);
      if (existingItemIndex === -1) return state; // アイテムが足りない

      return {
        ...state,
        money: state.money + totalRevenue,
        inventory: state.inventory.map((item, index) =>
          index === existingItemIndex ? { ...item, quantity: item.quantity - quantity } : item
        ).filter(item => item.quantity > 0),
      };
    }

    case 'UNLOCK_ACHIEVEMENT': {
      const { achievementId } = action.payload;
      return {
        ...state,
        achievements: state.achievements.map(ach =>
          ach.id === achievementId ? { ...ach, unlocked: true } : ach
        ),
      };
    }

    case 'SET_USERNAME': {
      const { username } = action.payload;
      return { ...state, username };
    }

    case 'LOAD_GAME_STATE': {
      // ロードされた状態をそのまま返す
      return action.payload.state;
    }

    default:
      // 未知のアクションタイプが来た場合にエラーを投げる (網羅性チェック)
      const exhaustiveCheck: never = action;
      throw new Error(`Unhandled action type: ${exhaustiveCheck}`);
  }
};
```

#### **ステップ3：ContextとProviderの作成 (`contexts/game-context.tsx`)**

最後に、Contextオブジェクトと、`useReducer`を使って状態を管理し、それを配信する`Provider`コンポーネントを作成します。ここでは、`localStorage`との連携によるゲーム状態の永続化も実装します。

```tsx
// contexts/game-context.tsx (新規作成)
"use client";

import React, { createContext, useContext, useReducer, Dispatch, useEffect, useMemo } from 'react';
import type { GameState, GameAction } from '@/types/game.types';
import { gameReducer } from './game-reducer';
import { useLocalStorage } from '@/hooks/use-local-storage'; // localStorageカスタムフック

// 初期状態を定義
const initialState: GameState = {
  username: 'Player1',
  money: 1000,
  gameTime: 0,
  plots: [
    { id: 1, crop: null }, { id: 2, crop: null }, { id: 3, crop: null }, { id: 4, crop: null },
    { id: 5, crop: null }, { id: 6, crop: null }, { id: 7, crop: null }, { id: 8, crop: null },
  ],
  animals: [
    { id: 'cow-001', name: 'モーさん', species: 'cow', fed: false, lastFedAt: null },
    { id: 'chicken-001', name: 'コケコ', species: 'chicken', fed: false, lastFedAt: null },
  ],
  inventory: [
    { id: 'tomato-seed', name: 'トマトの種', quantity: 5, type: 'seed' },
    { id: 'carrot-seed', name: 'ニンジンの種', quantity: 3, type: 'seed' },
    { id: 'cow-food', name: '牛の餌', quantity: 10, type: 'product' },
  ],
  achievements: [
    { id: 'first-harvest', name: '初収穫', description: '初めて作物を収穫する', unlocked: false },
  ],
};

// Contextを作成。stateとdispatchの両方を提供できるようにする
const GameContext = createContext<{
  state: GameState;
  dispatch: Dispatch<GameAction>;
} | undefined>(undefined);

// Providerコンポーネント
export const GameProvider = ({ children }: { children: React.ReactNode }) => {
  // localStorageからゲーム状態をロード
  const [savedState, setSavedState] = useLocalStorage<GameState>('nojo-game-state', initialState);

  // useReducerの初期状態としてsavedStateを使用
  const [state, dispatch] = useReducer(gameReducer, savedState);

  // stateが変更されるたびにlocalStorageに保存
  useEffect(() => {
    setSavedState(state);
  }, [state, setSavedState]);

  // Contextのvalueオブジェクトをメモ化して不要な再レンダリングを防ぐ
  const contextValue = useMemo(() => ({ state, dispatch }), [state, dispatch]);

  return (
    <GameContext.Provider value={contextValue}>
      {children}
    </GameContext.Provider>
  );
};

// カスタムフック
export const useGameContext = () => {
  const context = useContext(GameContext);
  if (context === undefined) {
    throw new Error('useGameContext must be used within a GameProvider');
  }
  return context;
};
```
**`useLocalStorage`カスタムフックの例:**
```ts
// hooks/use-local-storage.ts
import { useState, useEffect } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T): [T, React.Dispatch<React.SetStateAction<T>>] {
  // Stateを初期化する関数を渡すことで、初回レンダリング時のみlocalStorageを読み込む
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') {
      return initialValue;
    }
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error('Error reading from localStorage:', error);
      return initialValue;
    }
  });

  // useEffectを使って、storedValueが変更されたときにlocalStorageを更新
  useEffect(() => {
    if (typeof window !== 'undefined') {
      try {
        window.localStorage.setItem(key, JSON.stringify(storedValue));
      } catch (error) {
        console.error('Error writing to localStorage:', error);
      }
    }
  }, [key, storedValue]);

  return [storedValue, setStoredValue];
}
```

#### **ステップ4：アプリケーションをProviderでラップする**
`app/layout.tsx`で、アプリケーション全体を`GameProvider`で囲みます。

```tsx
// app/layout.tsx
import { GameProvider } from '@/contexts/game-context';
import { ThemeProvider } from '@/contexts/theme-context'; // 複数のContextをネスト

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body>
        <ThemeProvider> {/* テーマContext */}
          <GameProvider> {/* ゲームContext */}
            {children}
          </GameProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
```
複数のContextを使用する場合、Providerをネストすることで、それぞれのContextが提供する値にアクセスできるようになります。ネストの順序は、通常、より広範囲に影響するContext（例: テーマ）を外側に、より具体的なContext（例: ゲーム状態）を内側に配置します。

---

### **6.7 `GameContext`の利用と最適化**

これで準備は完了です。第5章で作成した`FarmPageClient`をリファクタリングし、ローカルな状態管理からグローバルな`GameContext`を利用するように変更しましょう。

```tsx
// components/pages/FarmPageClient.tsx (最終形態)
"use client";

import React, { useEffect, useCallback } from "react";
import { Barn } from "@/components/farm/Barn";
import { FarmField } from "@/components/farm/FarmField";
import { PlayerStats } from "@/components/farm/PlayerStats";
import { GameTimeDisplay } from "@/components/farm/GameTimeDisplay";
import { ActionLog } from "@/components/farm/ActionLog";
import { useGameContext } from "@/contexts/game-context"; // グローバルContextフックを利用

export default function FarmPageClient() {
  // グローバルなstateとdispatchを直接取得！
  const { state, dispatch } = useGameContext();
  const { player, animals, plots, gameTime, actionLog } = state; // stateから必要なデータを分割代入

  // ゲーム内時間の経過ロジック
  useEffect(() => {
    const timer = setInterval(() => {
      dispatch({ type: 'TICK', payload: { seconds: 60 } }); // 1秒で60秒(1分)進む
    }, 1000);

    return () => clearInterval(timer); // クリーンアップ
  }, [dispatch]); // dispatchは安定した関数なので依存配列に含めても問題ない

  // ロジックはdispatchを呼ぶだけ！
  // useCallbackを使って、これらの関数が不要に再生成されるのを防ぐ
  const handleFeedAnimal = useCallback((animalId: string, foodId: string, foodQuantity: number) => {
    dispatch({ type: 'FEED_ANIMAL', payload: { animalId, foodId, foodQuantity } });
    // setActionLog(prevLog => [`動物 ${animalId} に餌をやりました。`, ...prevLog]); // Reducer内でログも管理可能
  }, [dispatch]);

  const handlePlantCrop = useCallback((plotId: number, cropId: string, cropName: string, seedPrice: number) => {
    dispatch({ type: 'PLANT', payload: { plotId, cropId, cropName, seedPrice } });
    // setActionLog(prevLog => [`区画${plotId}に${cropName}を植えました。`, ...prevLog]);
  }, [dispatch]);

  const handleHarvestCrop = useCallback((plotId: number, productId: string, productName: string, sellPrice: number) => {
    dispatch({ type: 'HARVEST', payload: { plotId, productId, productName, sellPrice } });
    // setActionLog(prevLog => [`区画${plotId}から作物を収穫しました。`, ...prevLog]);
  }, [dispatch]);

  return (
    <div className="grid grid-cols-1 lg:grid-cols-4 gap-8 p-4">
      {/* 左サイドバー: プレイヤー情報、ゲーム時間、アクションログ */}
      <div className="lg:col-span-1 space-y-6">
        <PlayerStats player={player} />
        <GameTimeDisplay gameTime={gameTime} />
        <ActionLog logs={actionLog} /> {/* actionLogはstateから取得 */}
      </div>

      {/* メインコンテンツ: 動物小屋と畑 */}
      <div className="lg:col-span-3 space-y-8">
        {/* 動物小屋セクション */}
        <div className="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg shadow-md">
          <h2 className="text-2xl font-bold mb-4 text-yellow-800 dark:text-yellow-200">動物小屋</h2>
          <Barn animals={animals} onFeed={handleFeedAnimal} />
        </div>

        {/* 畑セクション */}
        <div className="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg shadow-md">
          <h2 className="text-2xl font-bold mb-4 text-green-800 dark:text-green-200">畑</h2>
          <FarmField plots={plots} onPlant={handlePlantCrop} onHarvest={handleHarvestCrop} />
        </div>
      </div>
    </div>
  );
}
```
`FarmPageClient`から`useState`が消え、代わりに`useGameContext`を呼び出すだけになりました。コンポーネントは状態管理の具体的な実装から解放され、ただ「`FEED_ANIMAL`アクションを発行する」「`PLANT`アクションを発行する」という責務に集中できます。

さらに、ヘッダーコンポーネントで所持金を表示するのも簡単です。
```tsx
// components/common/Header.tsx
"use client";
import React from 'react';
import { useGameContext } from "@/contexts/game-context";
import { ThemeToggleButton } from './ThemeToggleButton'; // テーマ切り替えボタン

export function Header() {
  const { state } = useGameContext();
  return (
    <header className="bg-gray-800 text-white p-4 flex justify-between items-center">
      <h1 className="text-2xl font-bold">Nojo Farm</h1>
      <div className="flex items-center space-x-4">
        <p className="text-lg">所持金: <span className="font-semibold">{state.money} G</span></p>
        <ThemeToggleButton />
      </div>
    </header>
  );
}
```
`Header`は、`FarmPageClient`とは全く関係ない場所にあるにも関わらず、同じデータソース（`GameContext`）から最新の所持金を直接取得できています。Prop Drillingは完全に過去のものとなりました。

**Contextを消費するコンポーネントの最適化:**
Contextの`value`が変更されると、そのContextを消費しているすべてのコンポーネントが再レンダリングされるという特性は、パフォーマンスのボトルネックになる可能性があります。特に`GameContext`のように巨大な状態を扱う場合、一部のプロパティだけが変更されても、すべてのコンシューマが再レンダリングされてしまいます。

*   **`useMemo`による`contextValue`のメモ化:** `GameProvider`内で`contextValue`を`useMemo`でメモ化することで、`state`または`dispatch`の参照が変更されない限り、`value`オブジェクトが再生成されるのを防ぎます。
*   **`React.memo`によるコンポーネントのメモ化:** Contextを消費する子コンポーネントを`React.memo`でラップすることで、Propsが変更されない限り、そのコンポーネントの再レンダリングを防ぐことができます。
    ```tsx
    // components/farm/PlayerStats.tsx
    import React from 'react';
    // ...
    export const PlayerStats = React.memo(({ player }: PlayerStatsProps) => {
      // ...
    });
    ```
*   **Contextの分割:** 巨大な`GameContext`を、`PlayerContext`、`PlotsContext`、`AnimalsContext`のように、関心事ごとに複数の小さなContextに分割することも有効です。これにより、特定のContextの`value`が変更されても、そのContextを消費しているコンポーネントだけが再レンダリングされ、パフォーマンスへの影響を局所化できます。ただし、Contextの数が増えると管理が複雑になるというトレードオフもあります。

**思考実験:**
「Nojo Farm」の市場ページで、プレイヤーがアイテムを購入する`MarketItemCard`コンポーネントがあるとします。このコンポーネントは、`GameContext`から`state.money`と`dispatch`を取得し、購入ボタンがクリックされたら`BUY_ITEM`アクションをディスパッチします。
1.  `MarketItemCard`コンポーネントを実装し、`useGameContext`を使って所持金を表示し、購入アクションをディスパッチするようにしてください。
2.  もし`state.money`が頻繁に更新される場合、`MarketItemCard`コンポーネントの再レンダリングを最適化するためにどのような手法を検討しますか？`React.memo`の使用例を挙げて説明してください。
3.  `GameContext`を`PlayerContext`と`InventoryContext`に分割するとしたら、それぞれのContextの`value`にはどのような情報を含めますか？また、`MarketItemCard`はどのようにこれらのContextを消費しますか？

---
### **第6章のまとめ**

この章では、Reactアプリケーションの状態管理を劇的に進化させる2つの重要なフックと、それらを組み合わせた強力な設計パターンを学びました。

*   **Context API**: 「Prop Drilling」問題を解決し、コンポーネントツリーのどこからでもデータに直接アクセスできる「掲示板」のような仕組みを提供してくれることを学びました。`createContext`, `Provider`, `useContext`の基本的な使い方から、Contextの内部的な仕組み、パフォーマンスへの影響、そして複数のContextを使い分ける基準までを深く掘り下げました。
*   **`useReducer`フック**: 複雑な状態更新ロジックをコンポーネントから分離し、Reducer関数に集約することで、コードの見通しと保守性を向上させる方法を習得しました。Reducer関数が純粋関数であることの重要性、Actionオブジェクトの型定義における判別可能な共用体の活用、そして`useState`の限界と`useReducer`の必要性を理解しました。
*   **`useContext` + `useReducer`パターン**: これら2つを組み合わせることで、アプリケーション全体のグローバルな状態を一元的かつ安全に管理する、スケーラブルな状態管理システム（`GameContext`）を構築しました。このパターンがReduxのような外部ライブラリなしで集中型状態管理を実現する利点と限界を考察しました。
*   **`GameContext`の実装**: Nojo Farmの心臓部となる`GameContext`を、`GameState`と`GameAction`の型定義からReducerの実装、そして`Provider`と`useGameContext`フックの作成まで、具体的なコードを通して構築しました。`localStorage`との連携によるゲーム状態の永続化の仕組みも実装しました。
*   **関心の分離と最適化**: 状態管理ロジックをReducerやContextに追い出すことで、コンポーネントは純粋にUIの表示とユーザーアクションの`dispatch`に集中できることを体感しました。また、Contextを消費するコンポーネントの不要な再レンダリングを防ぐための`useMemo`や`React.memo`といった最適化戦略についても学びました。

あなたは今、コンポーネント単体の状態だけでなく、アプリケーション全体にまたがる複雑な状態を、Reactの標準機能だけでエレガントに管理する高度なスキルを手に入れました。

次の章では、アプリケーションの品質を保証し、自信を持って変更を加えられるようにするための「テスト」の世界に足を踏み入れます。
