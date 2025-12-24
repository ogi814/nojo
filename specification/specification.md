# プログラム仕様書とUML設計図

## 1. 概要
本ゲームは農場シミュレーションで、React + TypeScript + Next.js を使用しています。主な機能は以下です。
- 作物の栽培・収穫
- 動物の飼育・餌やり
- 釣り・狩りミニゲーム
- 市場での売買・統計表示

## 2. アーキテクチャ概要
- **Next.js App Router** (`app/` ディレクトリ) がページ遷移を管理。
- **React Context** (`contexts/game-context.tsx`) が全体状態 (`GameState`) を保持し、`useReducer` で状態遷移を管理。
- **カスタムフック** (`hooks/`) が各機能ロジックを分離。
- **コンポーネント** (`components/`) が UI を構築。

\`\`\`mermaid
flowchart TD
    A[Next.js App] --> B[GameContext Provider]
    B --> C[Page Components]
    C --> D[Custom Hooks]
    D --> E[State Management]
\`\`\`

## 3. データモデル（TypeScript 型）
\`\`\`ts
export interface Crop {
  id: string;
  name: string;
  category: "crop";
  sellPrice: number;
  icon: string;
  seedId: string;
}

export interface Animal {
  id: string;
  name: string;
  category: "animal";
  sellPrice: number;
  icon: string;
  feedCost: number;
}

export interface Item {
  id: string;
  name: string;
  category: string;
  sellPrice: number;
  icon: string;
}
\`\`\`

## 4. 主なコンポーネントと関係図
\`\`\`mermaid
classDiagram
    class FarmPage {
        +FarmField
        +Barn
    }
    class MarketPage {
        +ShopPanel
        +InventoryPanel
        +StatsPanel
    }
    class FishingPage {
        +FishingArea
    }
    class HuntingPage {
        +HuntingArea
    }
    FarmPage --> FarmField
    FarmPage --> Barn
    MarketPage --> ShopPanel
    MarketPage --> InventoryPanel
    MarketPage --> StatsPanel
    FishingPage --> FishingArea
    HuntingPage --> HuntingArea
\`\`\`

## 5. 状態遷移（Reducer）
\`\`\`mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Planting : PLANT_SEED
    Planting --> Growing : TIME_TICK
    Growing --> Harvestable : GROWTH_COMPLETE
    Harvestable --> Harvested : HARVEST_CROP
    Harvested --> Idle
    Idle --> Buying : BUY_ITEM
    Buying --> Idle
    Idle --> Selling : SELL_ITEM
    Selling --> Idle
\`\`\`

## 6. シーケンス図（例：釣り）
\`\`\`mermaid
sequenceDiagram
    participant UI as UI
    participant Hook as useFishing
    participant Timer as setTimeout
    UI->>Hook: startFishing()
    Hook->>Timer: setTimeout(bite, 2000)
    Timer-->>Hook: bite()
    Hook->>UI: showBiteAnimation()
    UI->>Hook: catch()
    Hook->>Timer: clearTimeout()
    Hook->>UI: showCatchResult()
\`\`\`

## 7. テスト方針
- **ユニットテスト**: `jest` と `@testing-library/react` でフックとコンポーネントをテスト。
- **統合テスト**: ページ遷移とゲームループのシナリオテスト。
- **型チェック**: `tsc --noEmit` で型安全性を保証。

---

*この仕様書は `specification.md` として `c:/work/nojo/specification/specification.md` に保存されています。*
