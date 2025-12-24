### **【改訂版 v4.0】第1章: Reactの核心を掴む 〜コンポーネント、JSX、そして宣言的UIの力〜**

#### **この章で到達するレベル**

この章を読破したあなたは、単にReactの書き方を知っているだけでなく、「なぜReactがこのように設計されているのか」を自分の言葉で説明できるようになります。あなたは以下の問いに自信を持って答えられるようになるでしょう。

*   jQuery時代のアプローチとReactの「宣言的UI」は何が本質的に違うのか？その根底にある仮想DOMと再調整のメカニズムとは？
*   JSXはブラウザでどのように解釈されているのか？その変換プロセスと、`key`属性の重要性とは？
*   コンポーネントを設計する際の「良い粒度」とは？単一責任の原則をReactコンポーネントに適用する方法は？
*   `props`が読み取り専用であるべきなのはなぜか？その原則がアプリケーションの予測可能性と保守性にどう貢献するのか？
*   `useState`の更新が非同期なのはなぜか？それはどんな問題を引き起こし、関数更新（Updater Function）がなぜ必要なのか？
*   複数のコンポーネント間で状態を共有するためのReactの基本的な戦略「リフティング・ステート・アップ」とは？
*   Reactのレンダリングプロセスにおける「レンダーフェーズ」と「コミットフェーズ」の役割とは？

この章は、あなたがチームの他のメンバーにReactの基本を教えたり、技術選択の議論に参加したりするための、強固な理論的基盤を築くことを目的としています。

---

### **【第1部：Reactの思想と基本コンポーネント】**

この部では、Reactの最も根幹にある「考え方」と、その考え方を実現するための基本的な構成要素である「コンポーネント」と「JSX」について、その表面的な使い方だけでなく、内部の仕組みや設計思想にまで踏み込んで学びます。

---

### **1.1 宣言的UIという革命**

Reactを学ぶ上で、最初に理解すべき最も重要な概念が「**宣言的UI (Declarative UI)**」です。この考え方こそ、Reactが現代のフロントエンド開発に革命をもたらした理由そのものです。

#### **1.1.1 UI構築の歴史：命令形から宣言形へ**

かつて、jQueryが一世を風靡した時代、私たちはUIを「**命令的 (Imperative)**」に構築していました。これは、「**どのように (How)** UIを変化させるか」を、一つ一つ手順を追ってコードで指示する方式です。

**たとえ話：カーナビ**
*   **命令的な指示:** 「ここを直進200m、次の信号を右折、3つ目の角を左折…」
*   **宣言的な指示:** 「最終目的地は東京タワーです」

命令的な指示は、手順が複雑になるほど間違えやすく、現在地が変わると全ての指示が無意味になる可能性があります。一方、宣言的な指示は、目的地さえ伝えれば、途中のルートはカーナビ（React）が現在地に応じて最適に計算してくれます。

**コードで見る命令的UI (jQuery風)**

例えば、「ボタンを押したらメッセージを表示し、ボタンを無効化する」という単純なUIを考えてみましょう。

```javascript
// HTML
// <div id="app">
//   <button id="myButton">クリックしてください</button>
//   <p id="message"></p>
// </div>

// JavaScript (jQuery)
$('#myButton').on('click', function() {
  // 1. メッセージ要素を取得する
  const messageEl = $('#message');
  // 2. メッセージのテキストを更新する
  messageEl.text('ボタンがクリックされました！');
  // 3. メッセージの色を赤に変える
  messageEl.css('color', 'red');

  // 4. ボタン要素を取得する (あれ、もう参照持ってたっけ？)
  const buttonEl = $(this);
  // 5. ボタンのテキストを変更する
  buttonEl.text('クリック済み');
  // 6. ボタンを無効化する
  buttonEl.prop('disabled', true);
});
```

このコードの問題点は、UIの状態（`isClicked`のような）を直接管理せず、DOMを直接操作して「手順」を記述している点です。UIが複雑になり、「もしユーザーがログインしていなかったら」「もしエラーが発生したら」といった条件が加わると、この「手順書」はあっという間にスパゲッティコードと化します。

#### **1.1.2 Reactの登場：宣言的UIの夜明け**

Reactは、このアプローチを根本から覆しました。Reactでは、「**UIがあるべき姿 (What)**」を**状態 (State)** の関数として宣言します。

**コードで見る宣言的UI (React)**

同じUIをReactで書いてみましょう。

```tsx
import React, { useState } from 'react';

function ClickableButton() {
  // UIの状態を「state」として定義する
  const [isClicked, setIsClicked] = useState(false);

  // ボタンがクリックされたら、状態を「クリック済み(true)」に更新するだけ
  const handleClick = () => {
    setIsClicked(true);
  };

  // 「状態（isClicked）」に基づいて、UIが「どうあるべきか」を宣言する
  return (
    <div>
      <button onClick={handleClick} disabled={isClicked}>
        {isClicked ? 'クリック済み' : 'クリックしてください'}
      </button>
      {isClicked && (
        <p style={{ color: 'red' }}>ボタンがクリックされました！</p>
      )}
    </div>
  );
}
```

jQueryの例と比べてみてください。Reactのコードには「IDを指定して要素を取得する」「CSSプロパティを直接変更する」といった**手順**は一切ありません。

あるのは、**「`isClicked`という状態が`false`ならこう、`true`ならこうあるべき」**という**宣言**だけです。`handleClick`関数の中で行っているのも、DOM操作ではなく、`isClicked`という状態を`true`に変えることだけです。

状態が変更されると、Reactが自動的に前回のUIとの差分を計算し、DOMへの最小限の変更を効率的に行ってくれます。私たちは、UIをどう変化させるかという面倒な手順を考える必要がなくなり、アプリケーションの「状態」の管理に集中できるのです。これこそが、Reactがもたらした革命的な変化です。

#### **1.1.3 宣言的UIの根幹：仮想DOMと再調整 (Reconciliation)**

Reactが宣言的UIを実現する上で最も重要な技術的基盤が「**仮想DOM (Virtual DOM)**」と「**再調整 (Reconciliation)**」のメカニズムです。

**仮想DOMとは？**
仮想DOMは、実際のブラウザDOMの軽量なJavaScriptオブジェクト表現です。Reactは、コンポーネントのStateやPropsが変更されるたびに、新しい仮想DOMツリーをメモリ上に構築します。

**再調整 (Reconciliation) のプロセス**
1.  **状態の変更:** コンポーネントのStateやPropsが更新されると、Reactは新しい仮想DOMツリーを生成します。
2.  **差分検出 (Diffing):** Reactは、新しく生成された仮想DOMツリーと、前回の仮想DOMツリーを比較し、両者の間の「差分」を効率的に検出します。この差分検出アルゴリズムは、ヒューリスティック（経験則）に基づいて最適化されており、非常に高速です。
    *   **要素のタイプが異なる場合:** 例えば、`<div>`が`<span>`に変わった場合、Reactは既存のDOMノードを破棄し、新しいノードを完全に再構築します。
    *   **要素のタイプが同じ場合:** 例えば、`<div>`が`<div>`のままの場合、Reactは属性（Props）の変更のみをチェックし、変更された属性だけを実際のDOMに適用します。
    *   **子要素の再帰処理:** 子要素に対しても同様の差分検出を再帰的に行います。リスト要素の場合、`key`属性が非常に重要になります（後述）。
3.  **実際のDOMへの適用:** 検出された最小限の差分のみを、実際のブラウザDOMに効率的に適用します。このプロセスは「**コミット (Commit)**」と呼ばれます。

**なぜ仮想DOMと再調整が必要なのか？**
実際のブラウザDOMへの操作は、非常にコストの高い処理です。頻繁なDOM操作はパフォーマンスのボトルネックとなり、UIの描画を遅くします。Reactは、仮想DOMを介して変更をバッチ処理し、実際のDOM操作を最小限に抑えることで、高いパフォーマンスとスムーズなUI更新を実現しています。開発者はDOM操作の詳細を意識することなく、アプリケーションの状態に集中できるのです。

**宣言的UIの利点まとめ:**
*   **予測可能性:** UIが常にStateの関数として表現されるため、アプリケーションの挙動が予測しやすくなります。
*   **デバッグの容易性:** バグが発生した場合、UIのどの部分がどのStateに依存しているかを追跡しやすくなります。
*   **保守性:** コードが「どうあるべきか」を記述するため、変更や機能追加が容易になります。
*   **パフォーマンス:** 仮想DOMと再調整により、開発者が意識することなく効率的なUI更新が実現されます。
*   **テスト容易性:** UIがStateの純粋な関数であるため、特定のStateを与えたときのUIの出力を簡単にテストできます。

#### **1.1.4 Reactの3つの核心的特徴**

1.  **コンポーネントベース (Component-Based):** UIを独立した再利用可能な部品（コンポーネント）に分割して構築します。これにより、コードの見通しが良くなり、保守性やテストの容易性が向上します。（詳しくは1.3で）
2.  **宣言的UI (Declarative UI):** 上述の通り。状態に基づいてUIのあるべき姿を宣言することで、コードはより予測可能でデバッグしやすくなります。
3.  **Learn Once, Write Anywhere:** ReactはWeb（React.js）だけでなく、モバイルアプリ（React Native）やデスクトップアプリ（Electron）、VR（React 360）など、様々なプラットフォームで同じ開発モデルを適用できます。

**思考実験:**
「Nojo Farm」アプリケーションで、プレイヤーの所持金がリアルタイムで更新されるUIを実装するとします。もしReactのような宣言的UIフレームワークがなかった場合、jQueryを使ってどのように実装しますか？所持金が増減するたびに、DOMのどの部分を、どのような手順で更新する必要があるでしょうか？その実装は、所持金以外の要素（例えば、インベントリのアイテム数）も同時に更新される場合に、どのように複雑化するでしょうか？

---

### **1.2 JSXの深層：ただのHTMLにあらず**

JSXは、多くのReact初学者が最初に目にする魔法です。JavaScriptのコード内にHTMLのような構文を書けるため、直感的にUIを記述できます。しかし、その正体は単なるHTMLではなく、JavaScriptの強力な拡張機能です。

#### **1.2.1 JSXの正体：`React.createElement()`への変換と新しいJSX変換**

ブラウザはJSXを直接理解できません。私たちが書いたJSXは、実際にブラウザで実行される前に、**Babel**のようなトランスパイラによって通常のJavaScriptコードに変換されています。

**従来のJSX変換 (React 16以前、または明示的に指定した場合):**
JSXは`React.createElement()`という関数の呼び出し（シンタックスシュガー）に過ぎませんでした。

**私たちが書くJSX:**
```jsx
const element = (
  <div className="greeting">
    <h1>Hello, world!</h1>
  </div>
);
```

**Babelによって変換された後のJavaScript:**
```javascript
// このため、各ファイルで `import React from 'react';` が必須だった
const element = React.createElement(
  'div',
  { className: 'greeting' },
  React.createElement('h1', null, 'Hello, world!')
);
```
`React.createElement()`は、3つ以上の引数を取ります。
1.  **`type`**: タグの種類（例: `'div'`）やReactコンポーネント。
2.  **`props`**: 属性（例: `{ className: 'greeting' }`）。
3.  **`...children`**: 子要素。さらに`React.createElement()`がネストされます。

**新しいJSX変換 (React 17以降のデフォルト):**
React 17から導入された新しいJSX変換では、`React.createElement`の代わりに、`react/jsx-runtime`からインポートされる特別な関数（`_jsx`や`_jsxs`）が使用されます。これにより、JSXを使用するファイルで明示的に`import React from 'react';`を記述する必要がなくなりました。

**新しいJSX変換後のJavaScript:**
```javascript
// import { jsx as _jsx } from "react/jsx-runtime";
// import { jsxs as _jsxs } from "react/jsx-runtime";

const element = _jsx("div", {
  className: "greeting",
  children: _jsx("h1", { children: "Hello, world!" })
});
```
この変更は主にビルドツール側の最適化であり、開発者がJSXを書く方法に大きな影響はありませんが、`import React from 'react';`が不要になったことで、バンドルサイズがわずかに削減され、開発体験が向上しました。

この変換プロセスを理解することで、JSXの様々なルールがなぜ存在するのかが明確になります。

#### **1.2.2 JSXの必須ルールと高度な使い方**

1.  **単一のルート要素で返す**
    JSXは、必ず単一の親要素で全体がラップされていなければなりません。

    ```jsx
    // NG ❌: 隣接する要素が2つある
    // return (
    //   <h1>タイトル</h1>
    //   <p>本文</p>
    // );

    // OK ✅: divでラップする
    return (
      <div>
        <h1>タイトル</h1>
        <p>本文</p>
      </div>
    );
    ```
    **なぜ？** `React.createElement()`の構造を思い出してください。関数は通常、単一の戻り値しか返せません。JSXも同様に、単一の「要素オブジェクト」を返す必要があるためです。

    **`React.Fragment`という解決策**
    不要な`div`をDOMに追加したくない場合、`React.Fragment`またはその短縮構文`<></>`を使用します。これは、DOMツリーに余分なノードを追加せずに、複数の要素をグループ化するのに役立ちます。

    ```jsx
    // OK ✅: Fragmentを使う（DOMに余分なノードを追加しない）
    return (
      <React.Fragment>
        <h1>タイトル</h1>
        <p>本文</p>
      </React.Fragment>
    );

    // OK ✅: 短縮構文（最も一般的）
    return (
      <>
        <h1>タイトル</h1>
        <p>本文</p>
      </>
    );
    ```
    **ユースケース:** CSSのFlexboxやGridレイアウトを使用している場合、余分な`div`がレイアウトを崩す可能性があります。また、セマンティックなHTMLを維持したい場合にも有用です。

2.  **JavaScript式の埋め込み `{}`**
    JSXの最も強力な機能の一つが、波括弧`{}`を使ってJavaScriptの式を埋め込めることです。

    ```jsx
    const user = { name: '農場主', level: 10 };
    const today = new Date().toLocaleDateString('ja-JP'); // 日本語形式で日付を取得

    return (
      <div>
        <h1>ようこそ, {user.name}さん！</h1>
        <p>現在のレベル: {user.level}</p>
        <p>合計レベル: {user.level + 5}</p>
        <p>今日は {today} です。</p>
        {/* 条件付きレンダリング: user.levelが10以上なら特別なメッセージを表示 */}
        {user.level >= 10 && <p>ベテラン農場主ですね！</p>}
      </div>
    );
    ```
    `{}`の中には、文字列、数値、配列、関数呼び出しなど、**値を返すJavaScriptの式なら何でも**書けます。ただし、`if`文や`for`ループのような**文 (statement)** は直接書けません。その場合は、三項演算子や論理AND演算子 (`&&`)、`map`メソッドなどを使います。

    **条件付きレンダリングのパターン:**
    *   **`&&` (論理AND演算子):** `条件 && <要素>`。条件が`true`の場合にのみ要素をレンダリングします。条件が`false`の場合、Reactは`false`を無視して何もレンダリングしません。
        ```jsx
        {isLoading && <p>データを読み込み中...</p>}
        ```
    *   **三項演算子:** `条件 ? <trueの場合の要素> : <falseの場合の要素>`。
        ```jsx
        {isLoggedIn ? <UserProfile /> : <LoginButton />}
        ```
    *   **`if`文を関数内で使用:** 複雑な条件分岐の場合、コンポーネントのJSXの外で`if`文を使って早期リターンすることも可能です。
        ```tsx
        function Greeting({ isLoggedIn }) {
          if (!isLoggedIn) {
            return <p>ログインしてください。</p>;
          }
          return <p>ようこそ！</p>;
        }
        ```

    **リストレンダリングと`key`属性の重要性:**
    配列のデータをJSX要素のリストとしてレンダリングする場合、`map`メソッドを使用するのが一般的です。この際、各リストアイテムに一意の`key`属性を付与することが**必須**です。

    ```tsx
    // Nojo Farmの作物リストをレンダリングする例
    const crops = [
      { id: 1, name: 'トマト', status: '成長中' },
      { id: 2, name: 'ナス', status: '収穫可能' },
      { id: 3, name: 'キュウリ', status: '種' },
    ];

    function CropList() {
      return (
        <ul>
          {crops.map(crop => (
            // keyはリスト内で一意である必要がある
            <li key={crop.id}>
              {crop.name}: {crop.status}
            </li>
          ))}
        </ul>
      );
    }
    ```
    **`key`属性の役割:**
    Reactは、リストの要素が追加、削除、または並べ替えられたときに、どの要素が変更されたかを効率的に識別するために`key`属性を使用します。
    *   `key`がない場合、Reactはリスト全体を再レンダリングしようとし、パフォーマンスが低下したり、Stateが正しく保持されなかったりする可能性があります。
    *   `key`は、リスト内で**一意**であり、かつ**安定**している値である必要があります。理想的には、データベースのIDのような、データの永続的な識別子を使用します。
    *   **インデックスを`key`として使うのは避けるべきです。** リストの順序が変更されたり、要素が追加・削除されたりすると、インデックスが変わり、Reactが要素を正しく追跡できなくなるため、予期せぬバグやパフォーマンス問題を引き起こす可能性があります。

3.  **属性の命名規則**
    JSXの属性はHTMLと似ていますが、いくつか重要な違いがあります。これらは、JavaScriptの予約語との衝突を避けたり、DOM APIのプロパティ名に合わせたりするために存在します。

    *   `class` → `className` (`class`はJavaScriptの予約語)
    *   `for` → `htmlFor` (`for`はJavaScriptの予約語)
    *   `tabindex` → `tabIndex` (キャメルケース)
    *   `onclick` → `onClick` (イベントハンドラはキャメルケース)
    *   `checked`, `value`, `selected`などのフォーム要素の属性は、ReactではStateと連携して「制御されたコンポーネント」として扱われます（後述）。

4.  **インラインスタイル `style={{}}`**
    スタイルを直接要素に適用する場合、二重の波括弧`{{}}`を使います。

    ```jsx
    const styleObject = {
      color: 'blue',
      backgroundColor: '#f0f0f0', // プロパティはキャメルケース
      padding: '10px'
    };

    return <div style={styleObject}>スタイル適用</div>;

    // または直接書く
    return <div style={{ color: 'red', fontSize: '16px' }}>直接スタイル適用</div>;
    ```
    外側の`{}`はJSXでJavaScriptを埋め込むための構文、内側の`{}`はスタイルを定義するJavaScriptオブジェクトリテラルです。CSSプロパティ名は、JavaScriptの命名規則に従い、ハイフン区切りではなくキャメルケースで記述します（例: `background-color` → `backgroundColor`）。
    ただし、インラインスタイルは特定の要素にのみ適用され、再利用性や保守性に欠けるため、大規模なアプリケーションではTailwind CSSやCSS Modulesなどの別のスタイリング手法が推奨されます（第4章で詳述）。

5.  **セキュリティ：XSSからの自動防御**
    JSXに埋め込まれた値は、Reactによって自動的にエスケープ（無害化）されます。これにより、クロスサイトスクリプティング（XSS）攻撃を防ぐことができます。

    ```jsx
    const maliciousInput = '<h1>攻撃！</h1><script>alert("XSS!");</script>';

    // Reactはこれをただの文字列として表示する
    // 画面には "<h1>攻撃！</h1><script>alert("XSS!");</script>" と表示される
    return <div>{maliciousInput}</div>;
    ```
    もし意図的にHTMLをレンダリングしたい場合は、`dangerouslySetInnerHTML`という特別なプロパティを使いますが、その名の通り危険性を理解した上で慎重に使う必要があります。これは、サニタイズされていないユーザー入力に対しては**絶対に使用してはいけません**。信頼できるソースからのHTMLコンテンツにのみ使用を限定すべきです。

**思考実験:**
「Nojo Farm」のインベントリ画面で、プレイヤーが所持しているアイテムのリストを表示するとします。各アイテムにはID、名前、数量があります。このリストをJSXで効率的かつ正しくレンダリングするために、どのようなコードを書きますか？特に、リストの要素が追加・削除・並べ替えられたときに問題が発生しないように、`key`属性をどのように設定しますか？

---

### **1.3 コンポーネント設計入門：UIを分割統治する**

コンポーネントはReactアプリケーションの基本的な構成単位です。しかし、ただUIを部品に分けるだけでは不十分で、「どのように分けるか」がアプリケーションの品質を大きく左右します。

#### **1.3.1 コンポーネントの責務と粒度：単一責任の原則 (SRP)**

優れたコンポーネントは、**単一責任の原則 (Single Responsibility Principle)** に従います。つまり、一つのコンポーネントは、一つのことだけに対して責任を持つべきです。これにより、コンポーネントは理解しやすく、テストしやすく、再利用しやすくなります。

**悪い例 ❌: `FarmDashboard`コンポーネント**
このコンポーネントは、農場の全体像を表示するだけでなく、天気予報の取得と表示、プレイヤーのインベントリ管理、さらには作物の成長タイマーのロジックまで抱え込んでいます。

```tsx
function FarmDashboard({ player }) {
  // ... 天気予報のStateとAPI呼び出しロジック ...
  // ... インベントリのStateと更新ロジック ...
  // ... 作物の成長タイマーのStateとロジック ...

  return (
    <div className="farm-dashboard">
      {/* 天気予報の表示 */}
      {/* プレイヤーのインベントリ表示 */}
      {/* 各作物の成長状況表示 */}
      {/* 収穫ボタン、種まきボタンなど */}
    </div>
  );
}
```
このコンポーネントは肥大化し、修正やテストが困難になります。例えば、天気予報の表示方法を変更したいだけでも、インベントリや作物タイマーのロジックに影響を与えてしまう可能性があります。

**良い例 ✅: 責務の分割**
同じ機能を、責務ごとにコンポーネントに分割します。

*   `WeatherDisplay`: 天気予報の取得と表示の責務。
*   `InventorySummary`: プレイヤーのインベントリの概要表示の責務。
*   `CropTimer`: 個々の作物の成長状況とタイマー表示の責務。
*   `FarmMap`: 農地の区画と作物の配置を表示する責務。

そして、これらのコンポーネントをまとめる親コンポーネントを用意します。

```tsx
// FarmDashboardPage.tsx (親コンポーネント)
import React, { useState, useEffect } from 'react';
import { WeatherDisplay } from '../WeatherDisplay';
import { InventorySummary } from '../InventorySummary';
import { FarmMap } from '../FarmMap';
import { CropTimer } from '../CropTimer'; // 各作物に適用される

function FarmDashboardPage({ player }) {
  // FarmDashboardPageは、子コンポーネント間の調整役や、
  // グローバルな状態（GameContextなど）との連携に集中する
  const [currentWeather, setCurrentWeather] = useState('晴れ');
  const [inventory, setInventory] = useState(player.inventory); // 仮のState

  useEffect(() => {
    // 天気予報のAPIを呼び出すロジックなど
    // setCurrentWeather(...)
  }, []);

  return (
    <div className="farm-dashboard-page">
      <h1>{player.name}さんの農場</h1>
      <WeatherDisplay weather={currentWeather} />
      <InventorySummary inventory={inventory} />
      <FarmMap playerCrops={player.crops} /> {/* FarmMap内でCropTimerが使われる */}
      {/* その他の農場管理UI */}
    </div>
  );
}
```
各コンポーネントが小さく、自己完結しているため、再利用しやすく、理解も容易になります。`WeatherDisplay`は天気予報の表示にのみ責任を持ち、`InventorySummary`はインベントリの表示にのみ責任を持ちます。これにより、変更の影響範囲が限定され、開発効率と保守性が向上します。

**コンポーネントの粒度を判断するヒント:**
*   **再利用性:** その部分だけでアプリケーションの他の場所で再利用できるか？ (例: `Button`, `Avatar`, `Modal`)
*   **コードの長さ:** コードが長くなりすぎていないか？ (目安として100行を超えたら分割を検討)
*   **状態とロジックの複雑さ:** 複数の状態やロジックが絡み合っていないか？
*   **変更の理由:** そのコンポーネントを変更する理由が複数あるか？もしそうなら、それは複数の責任を負っている可能性があります。
*   **デザイナーの視点:** デザイナーがその部分を「部品」として認識しているか？デザインシステムにおける最小単位は、良いコンポーネントの粒度を示唆します。

#### **1.3.2 コンポーネントの分類：プレゼンテーションとコンテナ (Presentational vs Container Components)**

Reactの初期のベストプラクティスとして、コンポーネントを「プレゼンテーションコンポーネント」と「コンテナコンポーネント」に分類する考え方がありました。フックの登場によりこの区別は以前ほど厳密ではなくなりましたが、概念としては依然として有用です。

*   **プレゼンテーションコンポーネント (Presentational Components):**
    *   **責務:** UIの見た目を担当。Propsを受け取り、JSXをレンダリングする。
    *   **特徴:** 自身のStateを持たない（または最小限のUI Stateのみ）。データ取得やビジネスロジックは行わない。再利用性が高い。
    *   **例:** `Button`, `Card`, `Avatar`, `FarmPlotDisplay` (作物の見た目を表示するだけ)。

*   **コンテナコンポーネント (Container Components):**
    *   **責務:** データの取得、ビジネスロジック、State管理を担当。プレゼンテーションコンポーネントにPropsを渡す。
    *   **特徴:** 自身のUIはほとんど持たず、プレゼンテーションコンポーネントを組み合わせて構成する。
    *   **例:** `FarmDashboardPage` (天気データを取得し、`WeatherDisplay`に渡す), `InventoryManager` (インベントリのStateを管理し、`InventorySummary`に渡す)。

この分類は、コンポーネントの責務を明確にし、アプリケーションの構造を整理するのに役立ちます。

#### **1.3.3 コンポーネントの命名とファイル構成**

*   **命名:** コンポーネント名は必ず**パスカルケース (PascalCase)** で始めます（例: `PlayerCard`, `FarmPlot`）。これは、通常のHTMLタグ（`div`, `p`）と区別するためのJSXの規約です。
    *   ファイル名もコンポーネント名と一致させることが一般的です（例: `PlayerCard.tsx`）。
*   **ファイル構成:** 一般的なパターンとして、コンポーネントごとにフォルダを作成し、その中に`index.tsx`を置く方法や、コンポーネントファイルを直接配置する方法があります。

    **パターン1: フォルダにまとめる (関連ファイルが多い場合)**
    ```
    components/
    ├── Button/
    │   ├── index.tsx       # Buttonコンポーネントの定義 (export default Button;)
    │   ├── Button.module.css # Button専用のスタイル
    │   └── Button.test.tsx # Buttonのテストファイル
    └── PlayerCard/
        ├── index.tsx
        └── PlayerCard.types.ts # PlayerCard専用の型定義
    ```
    この場合、`import Button from 'components/Button';` のようにフォルダ名を指定してインポートできます。

    **パターン2: コンポーネントファイルを直接配置 (シンプルな場合)**
    ```
    components/
    ├── Button.tsx
    ├── Input.tsx
    └── Card.tsx
    ```
    この場合、`import { Button } from 'components/Button';` のようにファイル名を指定してインポートします。`export default`を使う場合は`import Button from 'components/Button';`となります。

    **Nojo Farmのディレクトリ構造 (system-design-document.mdより):**
    `system-design-document.md`で示されているように、Nojo Farmでは機能ごとにコンポーネントをグループ化し、共通コンポーネントは`components/common`や`components/ui`に配置する戦略を採用しています。

    ```
    components/
    ├── common/           # アプリケーション全体で使われる共通コンポーネント
    ├── farm/             # farm機能に特化したコンポーネント
    ├── market/           # market機能に特化したコンポーネント
    └── ui/               # shadcn/uiベースの汎用UI部品 (Button, Card, etc.)
    ```
    この構造は、大規模なアプリケーションにおいて、関心事を分離し、見通しを良くするのに非常に効果的です。

#### **1.3.4 `export default` vs `export`**

*   **`export default`**: 1ファイルにつき1つだけ。そのファイルの「主要な」エクスポートであることを示します。インポート時に好きな名前を付けられます。
    ```tsx
    // Button.tsx
    export default function Button() { /* ... */ }

    // App.tsx
    import MyCustomButton from './Button'; // 好きな名前でインポート可能
    ```

*   **`export`**: 1ファイルに複数可能。名前付きエクスポートと呼ばれ、インポート時には`{}`を使って同じ名前で受け取る必要があります。
    ```tsx
    // ui.ts
    export function Button() { /* ... */ }
    export function Input() { /* ... */ }

    // App.tsx
    import { Button, Input } from './ui'; // 必ず同じ名前でインポート
    ```

**使い分けの指針:**
*   1ファイル1コンポーネントで、そのコンポーネントがそのファイルの主要なエクスポートである場合は`export default`が一般的です。
*   複数の小さなユーティリティ関数や、関連する複数のコンポーネントを1つのファイルにまとめる場合は`export`が便利です。例えば、`shadcn/ui`のコンポーネントは、`components/ui/button.tsx`のように単一ファイルで`export`されることが多いです。

**思考実験:**
「Nojo Farm」の市場ページを設計するとします。このページには、購入可能なアイテムのリスト、プレイヤーのインベントリ、現在の所持金が表示されます。これらの要素をどのようにコンポーネントに分割しますか？それぞれのコンポーネントにどのような責務を持たせますか？また、それらのコンポーネントをどのようにファイルに配置し、命名しますか？

---
### **【第2部：コンポーネントに命を吹き込むPropsとState】**

第1部ではコンポーネントという「器」を学びました。この部では、その器に「データ」と「インタラクティブ性」という魂を吹き込むための2大要素、`Props`と`State`を徹底的に解剖します。

---

### **1.4 Props完全ガイド：親から子へのデータの流れ**

Props (Propertiesの略) は、親コンポーネントから子コンポーネントへデータを渡すための仕組みです。これにより、コンポーネントの再利用性が劇的に向上します。Reactにおけるデータフローは基本的に「**単方向 (Unidirectional)**」であり、親から子へとPropsを通じてデータが流れます。

#### **1.4.1 様々なデータ型を渡す**

Propsとしては、JavaScriptのほぼ全てのデータ型を渡すことができます。

```tsx
import React from 'react';

// UserProfileコンポーネントのPropsの型定義 (TypeScript)
interface UserProfileProps {
  name: string;
  age: number;
  isPremium: boolean;
  userObject: { id: string; email: string };
  skills: string[];
  onLogin: () => void; // 関数もPropsとして渡せる
  children?: React.ReactNode; // childrenもPropsの一種
}

function UserProfile({ name, age, isPremium, userObject, skills, onLogin, children }: UserProfileProps) {
  return (
    <div className="user-profile-card">
      <h2>{name}さんのプロフィール</h2>
      <p>年齢: {age}歳</p>
      {isPremium && <p>✨ プレミアム会員 ✨</p>}
      <p>メール: {userObject.email}</p>
      <p>スキル: {skills.join(', ')}</p>
      <button onClick={onLogin}>ログイン状態を更新</button>
      {children && (
        <div className="additional-info">
          <h3>追加情報:</h3>
          {children}
        </div>
      )}
    </div>
  );
}

function ParentComponent() {
  const user = { id: 'u1', email: 'alice@example.com' };
  const skills = ['React', 'TypeScript', 'Next.js'];

  const handleLogin = () => {
    console.log('ログイン処理を実行しました！');
    // 実際にはここで親のStateを更新するなど
  };

  return (
    <UserProfile
      name="Alice"
      age={30}
      isPremium={true}
      userObject={user}
      skills={skills}
      onLogin={handleLogin}
    >
      {/* childrenとして任意のJSXを渡せる */}
      <p>これはUserProfileコンポーネントの内部に表示される追加のコンテンツです。</p>
      <p>農場経営シミュレーションのベテランプレイヤー。</p>
    </UserProfile>
  );
}
```

**分割代入によるPropsの受け取り**
毎回`props.`と書くのは冗長なので、通常は引数の部分で分割代入を使います。TypeScriptを使用している場合、Propsの型を明示的に定義することで、コードの可読性と堅牢性が大幅に向上します。

#### **1.4.2 `props.children`：究極の汎用コンポーネントを作る**

Propsの中でも特殊で非常に強力なのが`props.children`です。これは、コンポーネントの開始タグと終了タグの間に挟まれた任意の内容を受け取ります。

**例：汎用的な`Card`コンポーネント (Nojo Farm風)**

```tsx
// Card.tsx
import React from 'react';

interface CardProps {
  title: string;
  children: React.ReactNode; // childrenの型はReact.ReactNode
  footer?: React.ReactNode; // オプションでフッターも受け取る
}

// childrenを受け取ることで、Cardの中身を自由に変えられる
function Card({ children, title, footer }: CardProps) {
  return (
    <div className="border rounded-lg shadow-md p-4 bg-white">
      <h2 className="text-xl font-semibold mb-2">{title}</h2>
      <div className="text-gray-700">
        {children}
      </div>
      {footer && (
        <div className="border-t pt-2 mt-4 text-sm text-gray-500">
          {footer}
        </div>
      )}
    </div>
  );
}

// App.tsx
import React from 'react';
import { Card } from './Card'; // Cardコンポーネントをインポート

function FarmOverview() {
  const totalCrops = 150;
  const totalAnimals = 20;

  return (
    <div className="grid grid-cols-2 gap-4 p-8">
      <Card title="農場の作物状況">
        <p>現在、{totalCrops}個の作物が成長中です。</p>
        <ul>
          <li>トマト: 50個</li>
          <li>ナス: 30個</li>
          <li>キュウリ: 70個</li>
        </ul>
      </Card>

      <Card
        title="農場の動物たち"
        footer={<p>動物たちは毎日新鮮な餌を食べています。</p>}
      >
        <p>合計で{totalAnimals}匹の動物がいます。</p>
        <ul>
          <li>牛: 5頭</li>
          <li>鶏: 15羽</li>
        </ul>
        <button className="bg-blue-500 text-white px-4 py-2 rounded mt-2">
          動物たちをチェック
        </button>
      </Card>
    </div>
  );
}
```
`Card`コンポーネントは、中身が何であるかを一切気にしません。ただ、渡された`children`を指定の場所に表示するだけです。これにより、`Card`はレイアウトや装飾という責務に集中でき、極めて高い再利用性を実現します。モーダル、ダイアログ、サイドバーなど、多くのUI部品がこのパターンを利用しています。

#### **1.4.3 Propsは読み取り専用（Immutability）**

**これはReactの最重要ルールの一つです。コンポーネントは、受け取ったPropsを絶対に直接変更してはいけません。**

```tsx
function BadComponent({ name }) {
  // 絶対にやってはいけない！ ❌
  // name = 'Taro'; // propsを直接変更しようとしている
  // TypeScriptはこれをコンパイルエラーにするでしょう

  // 正しい方法: 親から渡されたnameをそのまま使う
  return <h1>Hello, {name}</h1>;
}
```

**なぜ？**
Reactのデータフローは「**トップダウン**」、つまり親から子への一方通行です。もし子が受け取ったPropsを勝手に変更できてしまうと、データの流れが追跡不能になり、アプリケーションの挙動が予測不可能になります。親コンポーネントは、自分が渡したデータが子によって変更されていないと信頼できなければなりません。

この原則は、関数における「純粋性」の概念と似ています。同じ入力（Props）に対しては、常に同じ出力（UI）を返すコンポーネントを「純粋なコンポーネント」と呼びます。Propsを変更することは、この純粋性を破壊する行為です。

Propsの値を変更したい場合は、その値を管理している親コンポーネントに「変更してほしい」と依頼する必要があります（後述のイベントハンドラやリフティング・ステート・アップで詳解）。この原則は、Reactアプリケーションの予測可能性、デバッグの容易性、そして保守性を保証する上で不可欠です。

#### **1.4.4 デフォルトProps**

Propsが渡されなかった場合の初期値を設定することができます。これは、コンポーネントの利用をより柔軟にし、Propsの欠落によるエラーを防ぐのに役立ちます。

**方法1: 分割代入のデフォルト値 (ES6)**
最も一般的で推奨される方法です。

```tsx
interface ThemedButtonProps {
  text: string;
  theme?: 'default' | 'primary' | 'secondary'; // themeはオプション
}

function ThemedButton({ text, theme = 'default' }: ThemedButtonProps) {
  const className = `button theme-${theme}`;
  return <button className={className}>{text}</button>;
}

function App() {
  return (
    <div>
      <ThemedButton text="OK" theme="primary" /> {/* themeは'primary' */}
      <ThemedButton text="Cancel" />             {/* themeは'default'が適用される */}
    </div>
  );
}
```

**方法2: `defaultProps` (非推奨、クラスコンポーネントの名残)**
関数コンポーネントでは、上記の方法1が推奨されます。

**Props Drilling (Propsのバケツリレー) とその課題:**
Propsは親から子へデータを渡す強力なメカニズムですが、コンポーネント階層が深くなると、直接関係のない中間コンポーネントがPropsをただ「通過させる」だけの役割を担うことがあります。これを「Props Drilling」と呼びます。

```
App -> Page -> Section -> Card -> Button
// Buttonが必要なデータを、AppからPage, Section, Cardを経由して渡す
```
Props Drillingは、コードの可読性を低下させ、リファクタリングを困難にします。このような場合、Reactの**Context API**（第6章で詳述）や状態管理ライブラリ（Redux, Zustandなど）がより適切な解決策となることがあります。

**思考実験:**
「Nojo Farm」で、プレイヤーの現在の所持金を表示する`MoneyDisplay`コンポーネントと、アイテムを購入するための`BuyButton`コンポーネントがあるとします。`BuyButton`はクリックされたときに、購入するアイテムの価格を`MoneyDisplay`に通知し、`MoneyDisplay`は所持金を更新する必要があります。このデータフローをPropsとイベントハンドラを使ってどのように設計しますか？特に、Propsの読み取り専用の原則をどのように守りますか？

---
### **1.5 `useState`フック完全ガイド：コンポーネントの記憶**

Stateは、コンポーネントが内部で保持し、時間と共に変化するデータです。ユーザーのインタラクションやAPIからの応答などに応じてUIを動的に変化させるための心臓部です。`useState`は、関数コンポーネントにこの「記憶」機能を追加するためのフックです。

#### **1.5.1 `useState`の基本と再レンダリング**

`useState`を呼び出すと、Reactはコンポーネントに「状態変数」と、その状態を更新するための「セッター関数」のペアを返します。

```tsx
// 1. useStateをReactからインポート
import React, { useState } from 'react';

function Counter() {
  // 2. useStateを呼び出し、状態変数とセッター関数を受け取る
  //    count: 現在の状態の値 (初期値は0)
  //    setCount: countを更新するための関数
  const [count, setCount] = useState(0);

  const increment = () => {
    // 3. セッター関数を呼び出して状態を更新する
    setCount(count + 1);
  };

  // このconsole.logはレンダリングのたびに実行される
  console.log(`Counterコンポーネントがレンダリングされました。現在のcount: ${count}`);

  return (
    <div>
      <p>現在のカウント: {count}</p>
      <button onClick={increment}>+1</button>
    </div>
  );
}
```

**重要なプロセス:**
1.  `increment`関数内で`setCount(count + 1)`が呼ばれる。
2.  Reactは、`count`の状態が変更されることを予約する。
3.  Reactは、このコンポーネントの**再レンダリング**をスケジュールする。
4.  再レンダリング時、`Counter`関数が再び実行される。このとき、`useState(0)`は**新しい`count`の値（`1`）**を返す。
5.  Reactは、新しく生成されたJSXと前回のJSXを比較（差分検出）し、変更があった部分だけを実際のDOMに反映する。

**注意：Stateを直接変更してはいけない**
Propsと同様、Stateも直接変更してはいけません。

```tsx
// NG ❌: これではReactは変更を検知できず、再レンダリングが起こらない
// count = count + 1; // TypeScriptはこれをコンパイルエラーにするでしょう
```
必ずセッター関数（`setCount`）を使ってください。セッター関数こそが、Reactに「状態が変わったからUIを更新してね」と伝える唯一の合図なのです。Stateを直接変更すると、Reactの内部的な状態とUIの表示が同期されなくなり、予測不能なバグの原因となります。

#### **1.5.2 Stateの更新は非同期（バッチング）**

これはReact初学者が最もつまずきやすいポイントの一つです。**セッター関数を呼び出しても、状態変数はすぐには更新されません。** Reactはパフォーマンス向上のため、複数のState更新をまとめて一度の再レンダリングで処理しようとします。これを**バッチング (Batching)** と呼びます。

```tsx
function AsyncCounter() {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    setCount(count + 1); // ① countを1に更新するよう予約
    console.log(`クリック直後 (1回目): ${count}`);    // ❌ ここではまだ 0 が表示される！

    setCount(count + 1); // ② countを1に更新するよう予約
    console.log(`クリック直後 (2回目): ${count}`);    // ❌ ここでもまだ 0 が表示される！
  };
  // このクリック後、最終的にcountは1になる（2ではない！）

  return <button onClick={handleClick}>クリック</button>;
}
```
**なぜ？**
`handleClick`関数が実行される際、そのスコープ内の`count`の値は、その`handleClick`が定義されたレンダリング時点での`count`の値（この場合は`0`）で固定されています。これはJavaScriptの**クロージャ (Closure)** の働きによるものです。

1.  最初の`setCount(count + 1)`は、`setCount(0 + 1)`としてReactに更新を予約します。
2.  次の`console.log(count)`は、まだ`count`が`0`であるため`0`を出力します。
3.  2番目の`setCount(count + 1)`も、同様に`setCount(0 + 1)`としてReactに更新を予約します。

Reactはこれらの予約された更新をバッチ処理し、「`count`を`1`に更新する」という操作を一度だけ実行します。結果として、`count`は`1`になります。

**バッチングの利点:**
*   **パフォーマンス向上:** 複数のState更新があっても、DOM操作を一度にまとめることで、ブラウザの再描画回数を減らし、アプリケーションの応答性を高めます。
*   **UIの一貫性:** 中間的なStateの変更がUIに反映されないため、UIが一時的に不整合な状態になることを防ぎます。

#### **1.5.3 関数によるStateの更新（Updater Function）**

前のStateの値に基づいて新しいStateを計算したい場合は、セッター関数に**関数**を渡す必要があります。この関数は、現在のStateの値を引数として受け取り、新しいStateの値を返します。これを**Updater Function**と呼びます。

```tsx
function CorrectAsyncCounter() {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    // 「現在のcountに1を足した値」で更新して、とお願いする
    setCount(prevCount => prevCount + 1); // prevCountは常に最新のState値

    // 「現在のcountに1を足した値」で更新して、と再度お願いする
    setCount(prevCount => prevCount + 1);
  };
  // このクリック後、countは正しく2になる

  return <button onClick={handleClick}>クリック</button>;
}
```
ReactはこれらのUpdater Functionをキューに入れ、順番に実行します。
1.  最初の`setCount`のUpdater Functionが実行されます。`prevCount`は`0`なので、`0 + 1 = 1`が新しいStateとして予約されます。
2.  2番目の`setCount`のUpdater Functionが実行されます。この時点での`prevCount`は、前のUpdater Functionの結果（`1`）が反映されているため、`1 + 1 = 2`が新しいStateとして予約されます。
これにより、非同期な更新の中でも安全にStateを更新できます。**「前の値を使って次の値を計算する」場合は、常に関数更新を使いましょう。**

#### **1.5.4 Stateとして何を保持すべきか？**

コンポーネントに不要なStateを持たせることは、バグの温床になります。Stateとして保持すべきなのは、「**最小限の、他の値から計算できないデータ**」だけです。これを**単一の情報源 (Single Source of Truth)** の原則と呼びます。

**悪い例 ❌: `firstName`, `lastName`, `fullName`を全てStateで持つ**
```tsx
import React, { useState } from 'react';

function UserProfileFormBad() {
  const [firstName, setFirstName] = useState('Taro');
  const [lastName, setLastName] = useState('Yamada');
  // fullNameはfirstNameとlastNameから計算できるので、不要なState
  const [fullName, setFullName] = useState('Taro Yamada'); // ❌

  // firstNameを変更したときに、fullNameも手動で更新する必要があり、忘れやすい
  const handleFirstNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFirstName(e.target.value);
    // ここでsetFullNameを忘れると、fullNameとfirstName/lastNameが不整合になる
    setFullName(e.target.value + ' ' + lastName); // 😩
  };

  return (
    <div>
      <input value={firstName} onChange={handleFirstNameChange} />
      <input value={lastName} onChange={(e) => setLastName(e.target.value)} />
      <p>フルネーム: {fullName}</p>
    </div>
  );
}
```

**良い例 ✅: 計算できる値はレンダリング中に計算する**
```tsx
import React, { useState } from 'react';

function UserProfileFormGood() {
  const [firstName, setFirstName] = useState('Taro');
  const [lastName, setLastName] = useState('Yamada');

  // fullNameはレンダリングのたびに計算する。Stateではない。
  const fullName = `${firstName} ${lastName}`; // テンプレートリテラルで結合

  return (
    <div>
      <input value={firstName} onChange={(e) => setFirstName(e.target.value)} />
      <input value={lastName} onChange={(e) => setLastName(e.target.value)} />
      <p>フルネーム: {fullName}</p>
    </div>
  );
}
```
これにより、データソースが`firstName`と`lastName`の2つに限定され、状態の不整合が起こらなくなります。UIに表示される`fullName`は常に最新の`firstName`と`lastName`から計算されるため、常に一貫性が保たれます。

**オブジェクトや配列のStateを更新する際の注意点 (不変性の維持):**
Stateがオブジェクトや配列の場合、直接変更するのではなく、常に新しいオブジェクトや配列を作成して更新する必要があります。

```tsx
import React, { useState } from 'react';

interface Crop {
  id: number;
  name: string;
  quantity: number;
}

function FarmInventory() {
  const [crops, setCrops] = useState<Crop[]>([
    { id: 1, name: 'トマト', quantity: 10 },
    { id: 2, name: 'ナス', quantity: 5 },
  ]);

  const addCrop = (newCropName: string) => {
    const newCrop: Crop = { id: crops.length + 1, name: newCropName, quantity: 1 };
    // NG ❌: crops.push(newCrop); // 配列を直接変更している
    // OK ✅: 新しい配列を作成して更新
    setCrops([...crops, newCrop]);
  };

  const updateCropQuantity = (id: number, newQuantity: number) => {
    // NG ❌: crops.find(...).quantity = newQuantity; // オブジェクトを直接変更している
    // OK ✅: 新しい配列と、更新された新しいオブジェクトを作成して更新
    setCrops(crops.map(crop =>
      crop.id === id ? { ...crop, quantity: newQuantity } : crop
    ));
  };

  return (
    <div>
      <h2>農場インベントリ</h2>
      <ul>
        {crops.map(crop => (
          <li key={crop.id}>{crop.name}: {crop.quantity}個</li>
        ))}
      </ul>
      <button onClick={() => addCrop('キュウリ')}>キュウリを追加</button>
      <button onClick={() => updateCropQuantity(1, 15)}>トマトを15個に更新</button>
    </div>
  );
}
```
オブジェクトや配列を不変的に更新することで、Reactは前後のStateの差分を正確に検出し、効率的な再レンダリングを行うことができます。

**思考実験:**
「Nojo Farm」で、プレイヤーが農地の区画をクリックすると、その区画に作物が植えられる機能を実装するとします。農地の区画は`Plot`オブジェクトの配列としてStateで管理されています。プレイヤーが特定の区画をクリックしたときに、その`Plot`オブジェクトの`crop`プロパティを更新するには、`useState`のセッター関数をどのように使いますか？特に、配列やオブジェクトの不変性をどのように維持しますか？

---
### **1.6 StateとPropsの連携：動的なコンポーネントの構築**

個々のコンポーネントがStateを持てるようになりました。しかし、実際のアプリケーションでは、複数のコンポーネントが同じ状態を共有したり、互いに影響を与えたりする必要があります。

#### **1.6.1 リフティング・ステート・アップ（Lifting State Up）**

複数の子コンポーネントで同じ状態を共有する必要がある場合、その状態を**最も近い共通の親コンポーネント**に移動させ、Propsとして子に渡します。このパターンを「リフティング・ステート・アップ」と呼びます。これにより、状態の単一の情報源が保証され、コンポーネント間の同期が容易になります。

**シナリオ：Nojo Farmの市場ページにおける所持金とアイテム購入**

市場ページには、プレイヤーの所持金を表示する`MoneyDisplay`コンポーネントと、アイテムを購入するための`ShopItem`コンポーネントが複数存在するとします。`ShopItem`がクリックされたら、所持金を更新し、`MoneyDisplay`に反映させる必要があります。

**ステップ1：問題の特定**
`MoneyDisplay`と`ShopItem`がそれぞれ独立して所持金を管理すると、同期が取れません。`ShopItem`が購入処理を行っても、`MoneyDisplay`は所持金の変更を知ることができません。

**ステップ2：共通の親を見つける**
`MoneyDisplay`と`ShopItem`の両方を包含する親コンポーネント（例: `MarketPage`）を見つけます。

**ステップ3：Stateを親に移動（リフトアップ）**
プレイヤーの所持金の状態（`money`）を、親である`MarketPage`に持たせます。

**ステップ4：Stateと更新関数をPropsで渡す**
親から子へ、現在の値と、値が変更されたときに親のStateを更新するための関数をPropsとして渡します。

```tsx
// MarketPage.tsx (親コンポーネント)
import React, { useState } from 'react';

interface ShopItemData {
  id: string;
  name: string;
  price: number;
}

const shopItems: ShopItemData[] = [
  { id: 'seed-tomato', name: 'トマトの種', price: 50 },
  { id: 'seed-carrot', name: 'ニンジンの種', price: 30 },
];

function MoneyDisplay({ amount }: { amount: number }) {
  return (
    <div className="p-4 bg-green-100 rounded-md">
      現在の所持金: <span className="font-bold text-green-700">{amount} G</span>
    </div>
  );
}

function ShopItem({ item, onBuy }: { item: ShopItemData; onBuy: (price: number) => void }) {
  const handleBuyClick = () => {
    onBuy(item.price);
  };

  return (
    <div className="border p-3 rounded-md flex justify-between items-center">
      <span>{item.name} ({item.price} G)</span>
      <button
        onClick={handleBuyClick}
        className="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
      >
        購入
      </button>
    </div>
  );
}

function MarketPage() {
  const [money, setMoney] = useState(1000); // 所持金を親で管理

  const handleBuyItem = (price: number) => {
    if (money >= price) {
      setMoney(prevMoney => prevMoney - price); // 関数更新で安全にStateを更新
      alert(`${price} G を消費しました。`);
    } else {
      alert('所持金が足りません！');
    }
  };

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">市場</h1>
      <MoneyDisplay amount={money} /> {/* 親のStateをPropsとして渡す */}

      <div className="mt-6">
        <h2 className="text-xl font-semibold mb-3">販売アイテム</h2>
        <div className="space-y-2">
          {shopItems.map(item => (
            <ShopItem key={item.id} item={item} onBuy={handleBuyItem} /> {/* 親の更新関数をPropsとして渡す */}
          ))}
        </div>
      </div>
    </div>
  );
}
```
この例では、`money`の状態は`MarketPage`に一元管理され（単一の情報源）、データは常に親から子へと流れるトップダウンのデータフローが維持されます。`ShopItem`は、自身がクリックされたときに、親から渡された`onBuy`関数を呼び出すだけで、具体的な所持金の更新ロジックを知る必要はありません。これはReactで状態を管理する上で最も基本的かつ重要なパターンです。

**リフティング・ステート・アップのメリット:**
*   **単一の情報源:** 状態が一箇所で管理されるため、データの整合性が保たれます。
*   **同期の容易性:** 複数のコンポーネントが同じ状態を共有し、同期して動作させることが容易になります。
*   **デバッグの容易性:** 状態の変更がどこで発生しているかを追跡しやすくなります。

**リフティング・ステート・アップのデメリット:**
*   **Props Drilling:** コンポーネント階層が深くなると、中間コンポーネントが関係のないPropsをただ通過させるだけの「Props Drilling」が発生し、コードの可読性や保守性が低下する可能性があります。

#### **1.6.2 制御されたコンポーネント（Controlled Components）**

HTMLのフォーム要素（`<input>`, `<textarea>`, `<select>`）は、それ自体がユーザーの入力を保持する独自の「状態」を持っています。しかし、これをReactのStateで管理することで、フォームの挙動をより細かく制御できます。

`input`要素を制御されたコンポーネントにするには、2つのことを行います。
1.  `value`属性にReactのStateを渡す。
2.  `onChange`イベントでStateを更新する。

```tsx
import React, { useState } from 'react';

function NameForm() {
  const [name, setName] = useState(''); // Stateで入力値を管理

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    // 入力があるたびにStateを更新
    setName(e.target.value);
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); // フォームのデフォルト送信動作を防ぐ
    alert('入力された名前: ' + name);
    setName(''); // 送信後にフォームをクリア
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 p-4 border rounded-md">
      <label className="block">
        <span className="text-gray-700">名前:</span>
        <input
          type="text"
          value={name} // Stateの値をvalueにバインド
          onChange={handleChange} // onChangeイベントでStateを更新
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        />
      </label>
      <button
        type="submit"
        className="bg-indigo-500 text-white px-4 py-2 rounded-md hover:bg-indigo-600"
      >
        送信
      </button>
      <p className="text-sm text-gray-600">現在の入力値: {name}</p>
    </form>
  );
}
```
これにより、`input`の表示内容は常にReactの`name` Stateと一致します（単一の情報源）。大文字への自動変換、入力文字数の制限、リアルタイムバリデーションなど、あらゆる処理を`handleChange`関数内で行えるようになります。

**制御されたコンポーネントの利点:**
*   **即時バリデーション:** ユーザーが入力するたびに、リアルタイムで入力値を検証し、フィードバックを提供できます。
*   **入力の整形:** 入力値を自動的に大文字に変換したり、特定のフォーマットに整形したりできます。
*   **条件付き入力:** 特定の条件に基づいて入力フィールドを無効にしたり、特定の文字の入力を制限したりできます。
*   **フォームのクリア:** フォーム送信後にStateをリセットするだけで、フォーム全体を簡単にクリアできます。

**非制御コンポーネント (Uncontrolled Components):**
ReactのStateでフォームの値を管理しないコンポーネントを「非制御コンポーネント」と呼びます。この場合、DOM自体がフォームの値を管理し、`useRef`フックを使って直接DOM要素にアクセスし、その値を取得します。シンプルで一時的なフォームには便利ですが、複雑なフォームの制御には向いていません。

**思考実験:**
「Nojo Farm」で、プレイヤーが新しい作物の種を市場で購入する際に、購入数量を入力するフォームを実装するとします。このフォームは、購入可能な最大数量を超えないようにリアルタイムでバリデーションを行い、数量が不正な場合は購入ボタンを無効化する必要があります。このフォームを「制御されたコンポーネント」として実装するには、どのようなStateとイベントハンドラが必要ですか？

---
### **【第3部：レンダリングとReactのライフサイクル入門】**

これまでの部で、コンポーネントがどのようにデータを扱い、インタラクションに応答するかを学びました。この最後の部では、その結果としてUIがどのように画面に描画されるのか、つまり「レンダリング」のプロセスと、ユーザーとの対話の起点となる「イベント処理」について深掘りします。

---

### **1.7 レンダリングの仕組み：いつ、何が画面に描かれるのか**

「レンダリング」はReactの文脈で少し特殊な意味を持ちます。それは「**Reactがコンポーネントを呼び出して、画面に何を表示すべきかを計算するプロセス**」を指します。この計算結果に基づいて、Reactは実際のDOMを更新します。

#### **1.7.1 レンダリングがトリガーされる3つの条件**

Reactコンポーネントの再レンダリングは、以下のいずれかの条件が満たされたときにスケジュールされます。

1.  **初回レンダリング (Initial Render):**
    *   アプリケーションが最初に読み込まれたとき、または新しいコンポーネントがマウントされるときに発生します。
    *   Reactはコンポーネント関数を呼び出し、その結果として得られるJSXを仮想DOMツリーに変換し、最終的に実際のDOMに描画します。

2.  **Stateの更新 (State Update):**
    *   コンポーネント自身、またはその祖先コンポーネントのStateが、`useState`のセッター関数（例: `setCount`）や`useReducer`の`dispatch`関数によって更新されたときに発生します。
    *   Reactは、Stateの変更を検知すると、そのコンポーネントとその子孫コンポーネントの再レンダリングをスケジュールします。

3.  **Propsの変更 (Props Change):**
    *   親コンポーネントが再レンダリングされ、その結果として子コンポーネントに渡されるPropsの値が変更されたときに発生します。
    *   親コンポーネントが再レンダリングされると、デフォルトではそのすべての子コンポーネントも再レンダリングされます。たとえPropsが変更されていなくても、子コンポーネント関数は再実行されます。これは、Reactのパフォーマンス最適化の重要なポイントとなります（後述の`React.memo`で詳述）。

#### **1.7.2 純粋なコンポーネント（Pure Components）と副作用**

Reactは、コンポーネントが「純粋な関数」のように振る舞うことを期待しています。純粋な関数とは：
*   **同じ入力に対しては、常に同じ出力を返す。** (Reactでは、同じPropsとStateに対して常に同じJSXを返す)
*   **副作用を持たない。** (自身のスコープ外の変数やオブジェクトを変更しない、API呼び出し、DOM操作、タイマー設定などを行わない)

**レンダリングは計算のためだけの時間です。** レンダリング中にStateを更新したり、APIを呼び出したりするべきではありません。

**悪い例 ❌: レンダリング中にStateを更新**
```tsx
import React, { useState } from 'react';

function BadCounter({ initialValue }: { initialValue: number }) {
  const [count, setCount] = useState(initialValue);

  // レンダリング中にStateを更新している！
  // これにより無限ループが発生する (setCount -> 再レンダリング -> setCount -> ...)
  // ReactのStrict Modeでは、この種の副作用は2回実行され、問題が顕在化しやすくなる
  setCount(count + 1); // 😱

  return <h1>{count}</h1>;
}
```
このような副作用は、`useEffect`フック（後の章で詳解）の中で扱うのが適切です。コンポーネントの本体は、PropsとStateを受け取ってJSXを返すだけの、予測可能な計算処理に徹するべきです。これにより、コンポーネントの動作が予測可能になり、デバッグが容易になります。

#### **1.7.3 Reactの2つのフェーズ：レンダーとコミット**

Reactの更新プロセスは、大きく2つのフェーズに分かれています。この分離は、ReactがUIの応答性を維持しながら、複雑な更新を効率的に処理するための鍵となります。

1.  **レンダーフェーズ (Render Phase):**
    *   **目的:** UIに表示すべき内容を計算する。
    *   **プロセス:** Stateの更新などをトリガーに、Reactはコンポーネント関数を呼び出し、その結果として新しい仮想DOMツリーを構築します。このフェーズでは、Reactは前回の仮想DOMツリーとの差分検出（Reconciliation）も行います。
    *   **特徴:**
        *   このフェーズは、中断・再開される可能性があります（React Fiberの機能）。例えば、ユーザーの入力のような優先度の高い更新が発生した場合、Reactは現在のレンダーフェーズを一時停止し、より重要な更新を先に処理することができます。
        *   DOMへの変更は一切行われません。純粋な計算のみが行われます。
        *   副作用（API呼び出し、DOM操作など）は、このフェーズで行うべきではありません。

2.  **コミットフェーズ (Commit Phase):**
    *   **目的:** レンダーフェーズで計算された変更を実際のDOMに適用し、副作用を実行する。
    *   **プロセス:** レンダーフェーズが完了した後、Reactは計算された差分を実際のブラウザDOMに適用します。
    *   **特徴:**
        *   このフェーズは同期的で、中断されません。
        *   DOMの書き換えが完了すると、`useEffect`のクリーンアップ関数や`useLayoutEffect`が同期的に実行されます。これらのフックは、DOMが更新された後に副作用を実行するための安全な場所を提供します。

この2段階のプロセスにより、Reactは効率的でスムーズなUI更新を実現しています。特に、レンダーフェーズが中断可能であることは、Reactの将来的な並行モード（Concurrent Mode）の基盤となっており、より応答性の高いUI体験を提供するための重要な設計です。

**パフォーマンス最適化のヒント (概要):**
*   **不要な再レンダリングの回避:** 親コンポーネントが再レンダリングされると、子コンポーネントもデフォルトで再レンダリングされます。Propsが変更されていないにもかかわらず再レンダリングされるのを防ぐために、`React.memo`（関数コンポーネント用）や`shouldComponentUpdate`（クラスコンポーネント用）を使用できます。
*   **`useMemo`と`useCallback`:** 高コストな計算結果や関数オブジェクトをメモ化（キャッシュ）することで、不要な再計算や子コンポーネントの再レンダリングを防ぎ、パフォーマンスを向上させることができます（第8章で詳述）。

**思考実験:**
「Nojo Farm」で、プレイヤーが農地の区画をクリックすると、作物の成長ステージが更新されるとします。この更新によって、`FarmPlot`コンポーネントが再レンダリングされるのはなぜですか？また、もし`FarmPlot`コンポーネントが非常に複雑で、頻繁な再レンダリングがパフォーマンスに影響を与える場合、どのような最適化手法を検討すべきでしょうか？

---

### **1.8 イベント処理の深層**

イベント処理は、ユーザーの操作を検知し、Stateの更新などをトリガーするための入り口です。Reactはブラウザのネイティブイベントシステムの上に独自の「合成イベントシステム (Synthetic Event System)」を構築しています。

#### **1.8.1 イベントハンドラの指定方法**

*   **キャメルケース:** HTMLの`onclick`ではなく`onClick`、`onmouseover`ではなく`onMouseOver`を使います。これはJavaScriptのDOM APIの慣習に合わせたものです。
*   **関数を渡す:** `{}`の中には、イベント発生時に実行したい**関数そのもの**を渡します。関数を呼び出した結果(`handleClick()`)を渡してはいけません。

    ```jsx
    // OK ✅: handleClick関数への参照を渡している
    <button onClick={handleClick}>

    // NG ❌: レンダリング時に関数が実行されてしまう
    // onClickには戻り値(undefined)が渡される
    // <button onClick={handleClick()}>
    ```

    引数が必要な場合は、アロー関数でラップします。
    ```jsx
    // イベントオブジェクト e を受け取る場合
    <button onClick={(e) => alert(`Clicked at ${e.clientX}, ${e.clientY}`)}>

    // 複数の引数を渡す場合
    <button onClick={() => deleteItem(itemId)}>
    ```
    アロー関数でラップすると、コンポーネントが再レンダリングされるたびに新しい関数オブジェクトが作成されます。これがパフォーマンスに影響を与える可能性があるため、最適化が必要な場合は`useCallback`フック（第8章で詳述）の使用を検討します。

#### **1.8.2 合成イベント (Synthetic Event) とイベントオブジェクト `e`**

イベントハンドラには、自動的に**合成イベントオブジェクト**が引数として渡されます。これはブラウザのネイティブイベントをラップしたもので、クロスブラウザ互換性を提供し、Reactのイベントシステムと統合されています。合成イベントは、ネイティブイベントとほぼ同じインターフェースを持ちますが、一部のプロパティやメソッドは正規化されています。

*   **`e.preventDefault()`**: イベントのデフォルトの動作をキャンセルします。フォームの送信やリンクの遷移を抑制するためによく使われます。
    ```tsx
    function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
      e.preventDefault(); // フォームのデフォルト送信をキャンセル
      console.log('フォームのデフォルト送信をキャンセルしました。');
      // ここでフォームのデータを処理する
    }
    ```
*   **`e.stopPropagation()`**: イベントが親要素へ伝播（バブリング）するのを止めます。
    ```jsx
    // 親と子の両方にonClickがある場合、子のクリックで親のonClickも発火する（バブリング）
    // e.stopPropagation()を呼ぶと、子のonClickだけが実行される
    <div onClick={() => alert('親がクリックされました')}>
      <button onClick={(e) => {
        e.stopPropagation(); // イベントの伝播を停止
        alert('子がクリックされました');
      }}>
        クリック
      </button>
    </div>
    ```
*   **`e.target`と`e.currentTarget`**:
    *   `e.target`: イベントが発生した要素（最も深い要素）。
    *   `e.currentTarget`: イベントハンドラがアタッチされている要素。
    これらの違いは、イベントの委譲（Event Delegation）パターンを理解する上で重要です。

#### **1.8.3 子から親へのイベント通知**

Propsとして渡せるのはデータだけではありません。**関数（イベントハンドラ）をPropsとして渡す**ことで、子は親に「イベントが起きたよ！」と通知できます。これは「リフティング・ステート・アップ」で見たパターンそのものです。

```tsx
// 親コンポーネント
import React, { useState } from 'react';

function FarmManager() {
  const [message, setMessage] = useState('農場は平和です。');

  const handlePlantCrop = (cropName: string) => {
    setMessage(`${cropName}を植えました！`);
    // 実際にはここでGameContextのdispatchを呼び出すなど
  };

  const handleFeedAnimal = (animalId: string) => {
    setMessage(`動物 ${animalId} に餌をやりました！`);
    // 実際にはここでGameContextのdispatchを呼び出すなど
  };

  return (
    <div className="p-6 border rounded-lg">
      <h1 className="text-2xl font-bold mb-4">農場管理</h1>
      <p className="mb-4 text-lg">{message}</p>
      <div className="flex space-x-4">
        <ActionPanel onPlantCrop={handlePlantCrop} onFeedAnimal={handleFeedAnimal} />
      </div>
    </div>
  );
}

// 中間コンポーネント
interface ActionPanelProps {
  onPlantCrop: (cropName: string) => void;
  onFeedAnimal: (animalId: string) => void;
}

function ActionPanel({ onPlantCrop, onFeedAnimal }: ActionPanelProps) {
  return (
    <div className="border p-4 rounded-md">
      <h2 className="text-xl font-semibold mb-3">アクション</h2>
      <div className="space-y-2">
        <FarmButton text="トマトを植える" onClick={() => onPlantCrop('トマト')} />
        <FarmButton text="牛に餌をやる" onClick={() => onFeedAnimal('cow-001')} />
      </div>
    </div>
  );
}

// 子コンポーネント
interface FarmButtonProps {
  text: string;
  onClick: () => void;
}

function FarmButton({ text, onClick }: FarmButtonProps) {
  // このコンポーネントは、クリックされたら何が起こるかを知らない。
  // ただ、親から渡されたonClick関数を呼び出すだけ。
  return (
    <button
      onClick={onClick}
      className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 w-full"
    >
      {text}
    </button>
  );
}
```
この例では、`FarmButton`コンポーネントは「クリックできる」という機能に特化でき、具体的な動作は親である`ActionPanel`、そしてさらに親である`FarmManager`が決定できます。コンポーネントの責務が明確に分離され、再利用性が高まります。

**イベント委譲 (Event Delegation):**
Reactの合成イベントシステムは、内部的にイベント委譲を利用しています。これは、個々のDOM要素にイベントハンドラを直接アタッチするのではなく、ドキュメントルートなどの上位の要素に単一のイベントハンドラをアタッチし、イベントのバブリングを利用して、どの要素でイベントが発生したかを判断する手法です。これにより、メモリ使用量を削減し、動的に追加・削除される要素に対しても自動的にイベントハンドラが機能するようになります。

**思考実験:**
「Nojo Farm」の農地マップで、複数の`FarmPlot`コンポーネントが並んでいるとします。各`FarmPlot`はクリック可能で、クリックされると、その区画のIDを親コンポーネントに通知する必要があります。このとき、各`FarmPlot`に個別の`onClick`ハンドラを渡す代わりに、イベント委譲の概念を応用して、より効率的にイベントを処理する方法はありますか？（ヒント: 親コンポーネントでイベントを捕捉し、`e.target`や`e.currentTarget`を使ってどの`FarmPlot`がクリックされたかを判断する）

---
### **第1章のまとめ**

お疲れ様でした！この非常に長い章で、私たちはReactの表面的なAPIだけでなく、その背後にある思想とメカニズムまで深く探求しました。

*   **宣言的UI**: UIの状態を宣言することで、ReactにDOM操作の「方法」を委任する、Reactの核心思想を学びました。仮想DOMと再調整のメカニズムが、この宣言的アプローチをどのように技術的に支えているかを理解しました。
*   **JSX**: `React.createElement`への変換プロセス、そしてReact 17以降の新しいJSX変換について学びました。`Fragment`や属性のルール、そしてリストレンダリングにおける`key`属性の重要性がなぜ存在するのかを深く掘り下げました。
*   **コンポーネント設計**: 単一責任の原則に基づき、再利用可能で保守しやすいコンポーネントを設計するための基礎を固めました。プレゼンテーションコンポーネントとコンテナコンポーネントの概念、そして適切なファイル構成についても学びました。
*   **Props**: `children`を含む様々なデータの渡し方、そしてPropsが「読み取り専用」であることの重要性を理解しました。この原則がアプリケーションの予測可能性と保守性にどう貢献するのかを深く考察しました。
*   **State**: `useState`による状態管理、更新の非同期性とバッチング、そして関数更新（Updater Function）の必要性を学びました。不要なStateをなくし、単一の情報源を維持することの重要性も探求し、オブジェクトや配列のStateを不変的に更新する実践的な方法を習得しました。
*   **連携パターン**: 「リフティング・ステート・アップ」と「制御されたコンポーネント」という、動的なアプリケーションを構築するための必須パターンを習得しました。これらのパターンが、コンポーネント間のデータフローとインタラクションをどのように整理するかを理解しました。
*   **レンダリング**: レンダリングのトリガー、純粋なコンポーネントの概念、そしてレンダーフェーズとコミットフェーズというReactの内部プロセスを覗き見しました。これにより、ReactがUIを効率的に更新する仕組みの理解を深めました。
*   **イベント処理**: ユーザーとの対話の基本であり、子から親への通信手段でもあるイベント処理の仕組みを学びました。合成イベントシステム、イベントオブジェクトの活用、そしてイベント委譲の概念についても触れました。

これらの知識は、あなたのReactジャーニーにおける羅針盤となるはずです。あなたはもはや、ただコードを模倣するだけでなく、Reactの流儀に沿って考え、設計し、デバッグする力を手に入れました。

次の章では、この強力なReactの仕組みに「静的型付け」という安全装置を追加する**TypeScript**の世界に飛び込みます。Propsの渡し間違いやStateの誤った使い方といった、多くの一般的なバグを開発段階で根絶やしにする方法を学びましょう。