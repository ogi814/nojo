### **【改訂版 v4.0】第9章: 非同期データ取得戦略 〜モダンReact/Next.jsの流儀〜**

#### **この章で到達するレベル**

この章を読破したあなたは、モダンなReact/Next.jsアプリケーションにおけるデータ取得の課題と、それに対する最適なソリューションを体系的に理解し、実践できるようになります。あなたは以下の問いに自信を持って答えられるようになるでしょう。

*   データ取得処理が、単に`fetch`を呼ぶだけでなく、なぜ「ローディング」「成功」「エラー」という3つの状態管理を必要とするのか？それぞれの状態におけるユーザー体験の設計方法は？
*   `useEffect`を使った伝統的なデータ取得アプローチの、具体的な落とし穴（競合状態、ボイラープレート、古いクロージャ、手動キャンセル）は何か？
*   Next.jsのサーバーコンポーネントによるデータ取得が、なぜパラダイムシフトと呼ばれるほど画期的なのか？`Suspense`と`Error Boundary`がどのように連携し、データ取得のUXを向上させるのか？
*   Next.jsが拡張した`fetch` APIのキャッシュオプションが、どのようにしてSSG, SSR, ISRといったレンダリング戦略と直結しているのか？`revalidatePath`や`revalidateTag`によるキャッシュの制御方法は？
*   クライアントサイドでのデータ取得に、なぜ`SWR`のような専用ライブラリを使うべきなのか？`stale-while-revalidate`のコンセプトと、SWRが提供する自動再検証、ポーリング、エラーリトライといった機能は？
*   データの「取得(GET)」と「更新(POST/PUT)」を、`SWR`を使ってどのようにエレガントに扱うのか？特に、Optimistic UI（楽観的更新）の実装方法と、そのメリット・デメリットは？

この章は、あなたがアプリケーションの要件に応じて、サーバーサイドとクライアントサイドのデータ取得戦略を適切に選択し、パフォーマンスとユーザー体験を最大化するための、包括的な知識体系を構築することを目的としています。

---

### **【第1部：データ取得の難しさと伝統的なアプローチの限界】**

多くのアプリケーションは、外部のAPIサーバーからデータを取得して画面に表示します。一見シンプルに見えるこのタスクですが、堅牢で優れたユーザー体験を提供するためには、いくつかの複雑な側面を考慮する必要があります。

---

### **9.1 `fetch`の裏側：データが持つ3つのUI状態とユーザー体験**

データを取得する処理は、成功するか失敗するかの二択ではありません。ユーザーの視点から見ると、少なくとも3つの状態が存在し、それぞれの状態に対して適切なUIフィードバックを提供することが、優れたユーザー体験を構築する上で不可欠です。

1.  **ローディング (Loading):**
    *   **状態:** リクエストを送信し、サーバーからの応答を待っている状態。
    *   **UIフィードバック:** ユーザーはこの間、何かが進行中であることを知る必要があります。さもなければ、アプリが固まったと勘違いしてしまいます。
    *   **例:** スピナー、プログレスバー、スケルトンスクリーン（コンテンツのプレースホルダー）。
    *   **心理的影響:** 適切なローディング表示は、ユーザーの待機時間を短く感じさせ、離脱率を低減します。

2.  **成功 (Success):**
    *   **状態:** サーバーからデータが正常に返され、画面に表示できる状態。
    *   **UIフィードバック:** 取得したデータを整形して表示します。
    *   **例:** 取得した作物リスト、プレイヤーのプロフィール情報。

3.  **エラー (Error):**
    *   **状態:** ネットワークの問題、サーバー側の問題、認証エラーなどで、データの取得に失敗した状態。
    *   **UIフィードバック:** ユーザーに問題が発生したことを明確に伝え、可能であれば再試行の選択肢を提供すべきです。
    *   **例:** エラーメッセージの表示、再試行ボタン、サポートへの連絡先。
    *   **心理的影響:** エラーは避けられないものですが、ユーザーフレンドリーなエラーメッセージと解決策の提示は、ユーザーの不満を軽減し、信頼を維持するのに役立ちます。

**たとえ話：オンラインでの荷物追跡**
データ取得は、オンラインで商品を注文し、その配送状況を追跡するのに似ています。
*   **ローディング:** 注文後、「発送準備中」や「輸送中」と表示されている状態。
*   **成功:** 荷物が無事「配達完了」となった状態。
*   **エラー:** 「住所不明で返送」や「輸送中に紛失」といったトラブルが発生した状態。

優れたUIは、これらすべての状態を考慮して設計されています。

**思考実験:**
「Nojo Farm」で、プレイヤーが市場ページにアクセスした際に、利用可能なアイテムのリストをAPIから取得するとします。
1.  アイテムリストの取得中に、ユーザーにどのようなローディングUIを表示するのが最も効果的でしょうか？スピナー、プログレスバー、スケルトンスクリーンの中から選び、その理由を説明してください。
2.  もしAPIからのデータ取得に失敗した場合、ユーザーにどのようなエラーメッセージを表示し、どのような解決策を提示すべきでしょうか？例えば、「ネットワーク接続を確認してください」や「しばらくしてからもう一度お試しください」といったメッセージは適切ですか？

---

### **9.2 伝統的なアプローチ：`useEffect`の落とし穴と複雑性**

クライアントコンポーネントでデータを取得する最も基本的な方法は、`useEffect`と`useState`を組み合わせることです。しかし、このアプローチは一見すると機能しますが、多くの隠れた問題点と複雑性を抱えています。

```tsx
// このパターンはアンチパターンとして理解してください
import React, { useState, useEffect } from 'react';

interface UserProfile {
  id: string;
  name: string;
  level: number;
}

function TraditionalUserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const abortController = new AbortController(); // リクエストキャンセル用
    const signal = abortController.signal;

    const fetchUser = async () => {
      setIsLoading(true);
      setError(null); // 新しいフェッチ開始時にエラーをリセット

      try {
        const res = await fetch(`/api/users/${userId}`, { signal });
        if (!res.ok) {
          // HTTPエラーの場合
          const errorData = await res.json();
          throw new Error(errorData.message || `HTTP error! status: ${res.status}`);
        }
        const data: UserProfile = await res.json();
        setUser(data);
      } catch (err) {
        if (err instanceof DOMException && err.name === 'AbortError') {
          console.log('Fetch aborted'); // リクエストがキャンセルされた場合
        } else {
          setError(err instanceof Error ? err : new Error(String(err)));
        }
      } finally {
        setIsLoading(false);
      }
    };

    fetchUser();

    // クリーンアップ関数: コンポーネントがアンマウントされる時や、
    // 依存配列のuserIdが変更されてエフェクトが再実行される直前に呼ばれる
    return () => {
      abortController.abort(); // 未完了のリクエストをキャンセル
    };
  }, [userId]); // userIdが変わるたびに再フェッチ

  if (isLoading) return <div>ユーザー情報を読み込み中...</div>;
  if (error) return <div>エラーが発生しました: {error.message}</div>;
  if (!user) return <div>ユーザーが見つかりません。</div>; // データがnullの場合

  return (
    <div>
      <h2 className="text-xl font-bold">ようこそ, {user.name}さん！</h2>
      <p>レベル: {user.level}</p>
    </div>
  );
}
```
このアプローチは一見すると機能しますが、多くの隠れた問題点と複雑性を抱えています。

**`useEffect`によるデータ取得の落とし穴:**
1.  **ボイラープレートの多さ:** `isLoading`, `error`, `data`という3つの状態管理と、`try...catch...finally`、リクエストキャンセルロジックが、データを取得するすべてのコンポーネントで繰り返し記述されます。これはコードの重複とメンテナンスコストの増大を招きます。
2.  **競合状態 (Race Condition):**
    *   ユーザーが短時間に複数の異なるデータを要求した場合（例: ユーザーIDを素早く切り替える）、リクエストの応答順序が保証されないため、古いリクエストの結果が新しいリクエストの結果を上書きし、UIに不整合なデータが表示される可能性があります。
    *   上記の例では`AbortController`を使ってこれを軽減していますが、手動での管理は複雑です。
3.  **キャッシュ機能の欠如:**
    *   コンポーネントがアンマウントされ、再マウントされるたびに、同じデータを何度も取得しにいきます。これはサーバーへの不要な負荷と、ユーザーの待機時間の増加につながります。
    *   例えば、ユーザーがプロフィールページから別のページに移動し、すぐにプロフィールページに戻ってきた場合、データは再度フェッチされます。
4.  **手動での再取得と同期の複雑性:**
    *   ユーザーがタブを切り替えて戻ってきた時や、ネットワークに再接続した時に、データが古くなっている可能性がありますが、自動で再取得する仕組みはありません。
    *   データの更新（`POST`, `PUT`など）を行った後、関連する`GET`データを手動で再フェッチしてUIを同期させる必要があります。
5.  **古いクロージャ (Stale Closures):**
    *   `useEffect`の依存配列を誤ると、エフェクト内の関数が古いStateやPropsの値を参照してしまう「古いクロージャ」の問題が発生し、デバッグが困難なバグにつながります。

これらの問題を自力で全て解決するのは非常に複雑で、多くの開発者が同じような車輪の再発明を繰り返してきました。幸いなことに、現代のフレームワークとライブラリは、より優れた解決策を提供してくれます。

**思考実験:**
「Nojo Farm」で、プレイヤーが農地の区画をクリックすると、その区画の詳細情報（作物の種類、成長度、土壌の肥沃度など）をAPIからフェッチして表示する`PlotDetailModal`コンポーネントを実装するとします。プレイヤーが複数の区画を素早くクリックした場合、`useEffect`を使った伝統的なアプローチではどのような競合状態が発生する可能性がありますか？また、その競合状態がUIにどのような不整合を引き起こすか具体的に説明してください。

---

### **【第2部：Next.js App Routerの流儀 - サーバーサイド取得】**

Next.jsのApp Routerは、データ取得の考え方を根本から変えました。多くの場合、クライアントサイドでの複雑な状態管理はもはや不要です。サーバーコンポーネントは、データ取得をコンポーネントのレンダリングプロセスに統合し、パフォーマンス、SEO、開発者体験を劇的に向上させます。

---

### **9.3 パラダイムシフト：サーバーコンポーネントでのデータ取得**

第3章で学んだように、App Routerではコンポーネントはデフォルトで**サーバーコンポーネント**です。そして、サーバーコンポーネントは`async/await`をトップレベルで使えます。これにより、データ取得がコンポーネントのレンダリングロジックの一部として自然に記述できるようになりました。

```tsx
// app/profile/page.tsx (サーバーコンポーネント)
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary'; // エラー境界ライブラリ

interface UserProfile {
  id: string;
  name: string;
  level: number;
  farmName: string;
}

async function getUserProfile(): Promise<UserProfile> {
  // Next.jsのfetch拡張機能により、キャッシュ戦略を制御
  const res = await fetch('https://api.nojo-farm.com/profile', {
    cache: 'no-store' // 常に最新のデータを取得 (SSR)
  });
  if (!res.ok) {
    // HTTPエラーの場合、エラーをスローしてError Boundaryでキャッチさせる
    const errorData = await res.json();
    throw new Error(errorData.message || `Failed to fetch profile: ${res.status}`);
  }
  return res.json();
}

// ProfilePageコンポーネント自体が非同期
export default async function ProfilePage() {
  // コンポーネントのレンダリング自体が非同期処理になる
  // データ取得が完了するまで、このコンポーネントのレンダリングは一時停止 (suspend) する
  const user = await getUserProfile();

  // このreturn文に到達した時点で、データは必ず存在するか、エラーで中断しているかのどちらか
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">プレイヤープロフィール</h1>
      <p>名前: {user.name}</p>
      <p>レベル: {user.level}</p>
      <p>農場名: {user.farmName}</p>
    </div>
  );
}
```
**`useEffect`アプローチとの根本的な違い:**
*   **状態管理が不要:** `isLoading`や`error`といったクライアントサイドの状態は必要ありません。コンポーネントのレンダリング自体が、データ取得が完了するまで**一時停止 (suspend)** します。
*   **ローディングとエラーの分離:** ローディングUIとエラーUIは、このコンポーネント自身ではなく、Next.jsの規約ファイルである`loading.tsx`と`error.tsx`が担当します。Reactの`Suspense`と`Error Boundary`の仕組みによって、関心が綺麗に分離されます。

**たとえ話：シェフの哲学**
*   **`useEffect`アプローチ:** 見習いシェフが、調理の各段階（「今、野菜を切ってます」「今、炒め始めました」「あ、焦がしました！」）を客席に逐一報告するようなもの。客席は混乱する。
*   **サーバーコンポーネント:** 巨匠シェフが、厨房で完璧な一皿を仕上げるまで、客席には何も出さない。客席のウェイター（Next.js）は、料理を待っている間は客に飲み物（`loading.tsx`）を提供し、もし厨房で火事（エラー）が起きたら、丁重にお詫びして代替案（`error.tsx`）を提示する。

**`Suspense`と`Error Boundary`によるデータ取得のUX向上:**
*   **`loading.tsx` (Suspense):** サーバーコンポーネントがデータをフェッチしている間、`loading.tsx`で定義されたUIが表示されます。データ取得が完了すると、自動的に`page.tsx`の内容に置き換わります。これにより、ユーザーはコンテンツが表示されるまでの間、何かが進行中であることを視覚的に認識できます。
*   **`error.tsx` (Error Boundary):** データ取得中にエラーが発生した場合、`error.tsx`で定義されたUIが表示されます。これにより、アプリケーション全体がクラッシュするのを防ぎ、ユーザーにフレンドリーなエラーメッセージと再試行の選択肢を提供できます。

**`server-only`パッケージ:**
サーバーコンポーネントでのみ使用されるべきコード（例: データベース接続、APIキーなど）を誤ってクライアントコンポーネントからインポートしてしまうのを防ぐために、`server-only`パッケージを使用できます。このパッケージをインポートしたファイルは、クライアントコンポーネントからインポートされるとビルドエラーになります。

**思考実験:**
「Nojo Farm」で、プレイヤーのインベントリページ（`/inventory`）をサーバーコンポーネントとして実装するとします。このページは、`getInventoryItems()`という非同期関数を使ってAPIからアイテムリストを取得します。
1.  `getInventoryItems()`関数と`InventoryPage`コンポーネントを実装してください。
2.  `InventoryPage`がデータをフェッチしている間に表示される`loading.tsx`と、データ取得に失敗した場合に表示される`error.tsx`を実装してください。
3.  `error.tsx`がクライアントコンポーネントである必要がある理由と、`reset`関数がどのように機能するかを説明してください。

---

### **9.4 Next.jsの拡張`fetch`APIとキャッシュ戦略**

サーバーコンポーネントでのデータ取得の挙動は、Next.jsが拡張した`fetch` APIのキャッシュオプションによって完全に制御されます。これが、SSG, SSR, ISRといったレンダリング戦略と直結しています。Next.jsは、`fetch` APIをラップし、リクエストメモ化、データキャッシュ、再検証といった高度なキャッシュ機能を提供します。

**`fetch`のキャッシュメカニズム:**
*   **リクエストメモ化 (Request Memoization):** 同じ`fetch`リクエストが同じコンポーネントツリー内で複数回呼び出されても、一度だけ実行され、結果がキャッシュされます。
*   **データキャッシュ (Data Cache):** `fetch`の結果は、Next.jsのデータキャッシュに保存されます。このキャッシュは、ビルド時、リクエスト時、またはバックグラウンドで再検証されます。

1.  **静的サイト生成 (SSG - Static Site Generation):**
    *   **オプション:** `fetch(url)` (デフォルト) または `fetch(url, { cache: 'force-cache' })`
    *   **挙動:** **ビルド時**にデータを取得し、その結果を永続的にキャッシュします。以降のリクエストでは、常にキャッシュされたデータが使われます。
    *   **ユースケース (Nojo Farm):** ゲームのルール説明ページ (`/rules`)、農場紹介ページ (`/about`) など、内容がほとんど変わらないページ。
    ```tsx
    // app/rules/page.tsx
    async function getGameRules() {
      // デフォルトでSSG (ビルド時にフェッチされ、キャッシュされる)
      const res = await fetch('https://api.nojo-farm.com/rules');
      return res.json();
    }
    export default async function RulesPage() {
      const rules = await getGameRules();
      return <div dangerouslySetInnerHTML={{ __html: rules.content }} />;
    }
    ```

2.  **サーバーサイドレンダリング (SSR - Server-Side Rendering):**
    *   **オプション:** `fetch(url, { cache: 'no-store' })`
    *   **挙動:** **リクエストごと**に、常にサーバーから新しいデータを取得します。キャッシュは一切利用しません。
    *   **ユースケース (Nojo Farm):** プレイヤーのダッシュボード (`/dashboard`)、市場のリアルタイム価格表示 (`/market`) など、常に最新でパーソナライズされた情報が必要なページ。
    ```tsx
    // app/dashboard/page.tsx
    async function getPlayerDashboard(userId: string) {
      // リクエストごとに最新データを取得 (キャッシュしない)
      const res = await fetch(`https://api.nojo-farm.com/users/${userId}/dashboard`, { cache: 'no-store' });
      return res.json();
    }
    export default async function DashboardPage() {
      const userId = 'player-123'; // 実際には認証情報から取得
      const dashboardData = await getPlayerDashboard(userId);
      return <p>所持金: {dashboardData.money} G</p>;
    }
    ```

3.  **インクリメンタル静的再生成 (ISR - Incremental Static Regeneration):**
    *   **オプション:** `fetch(url, { next: { revalidate: 60 } })`
    *   **挙動:** ビルド時にデータを取得してキャッシュしますが、指定した秒数（この例では60秒）が経過した後の最初のリクエストで、バックグラウンドでデータの再検証が行われます。ユーザーにはまずキャッシュされた古いデータが返され、再検証が完了するとキャッシュが更新されます。
    *   **ユースケース (Nojo Farm):** 市場のアイテム一覧ページ (`/market/items`)、ゲーム内のランキングページ (`/leaderboard`) など、 شبهリアルタイム性が求められるが、SSRほどの負荷はかけたくないページ。
    ```tsx
    // app/market/items/page.tsx
    async function getMarketItems() {
      // 1時間 (3600秒) ごとにデータを再検証
      const res = await fetch('https://api.nojo-farm.com/market/items', { next: { revalidate: 3600 } });
      return res.json();
    }
    export default async function MarketItemsPage() {
      const items = await getMarketItems();
      return <ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>;
    }
    ```

**キャッシュの再検証 (Revalidation) と手動制御:**
Next.jsのキャッシュは、`revalidate`オプションによる時間ベースの再検証だけでなく、手動での再検証もサポートしています。これは、データが更新されたときに、Next.jsのキャッシュを最新の状態に保つために非常に重要です。

*   **`revalidatePath(path)`:** 特定のパスのキャッシュを再検証します。
*   **`revalidateTag(tag)`:** `fetch`オプションで指定したタグに基づいて、関連するキャッシュを再検証します。

```tsx
// app/actions.ts (サーバーアクションの例)
"use server";
import { revalidatePath, revalidateTag } from 'next/cache';

export async function updateCropStatus(cropId: string) {
  // データベースを更新するロジック
  // await db.updateCrop(cropId, { status: 'harvested' });

  // /farmパスのキャッシュを再検証
  revalidatePath('/farm');
  // 'crops'タグを持つfetchリクエストのキャッシュを再検証
  revalidateTag('crops');
}
```
これらのAPIは、データが更新されたときに、Next.jsのキャッシュを最新の状態に保つために非常に重要です。例えば、管理画面でブログ記事を更新した際に、`revalidatePath('/blog/[slug]')`を呼び出すことで、その記事のキャッシュを即座に無効化し、次回のリクエストで最新のコンテンツを生成させることができます。

**思考実験:**
「Nojo Farm」で、プレイヤーが新しい作物を植える`POST`リクエストを送信するサーバーアクションを実装するとします。このアクションが成功した後、農場ページ（`/farm`）の作物リストが最新の状態に更新されるようにするには、`revalidatePath`または`revalidateTag`をどのように使用しますか？それぞれの方法のメリットとデメリットを説明してください。

---

### **【第3部：モダンなクライアントサイドデータ取得 `SWR`】**

サーバーコンポーネントは強力ですが、すべてのデータ取得がサーバーサイドで完結するわけではありません。ユーザー操作に依存するデータ、頻繁に変化するリアルタイム性の高いデータ、データの更新処理（Mutation）など、クライアントサイドでのデータ取得が必要な場面も依然として存在します。

---

### **9.5 クライアントサイド取得が必要な時**

サーバーコンポーネントでのデータ取得は多くのメリットを提供しますが、以下のようなシナリオではクライアントサイドでのデータ取得が不可欠、またはより適しています。

*   **ユーザー操作に依存するデータ:**
    *   検索ボックスに文字を入力するたびに結果をフェッチする場合。
    *   フィルターやソートのオプションを変更するたびにデータを再フェッチする場合。
    *   ページネーションや無限スクロールで追加データをロードする場合。
*   **頻繁に変化するリアルタイム性の高いデータ:**
    *   チャットメッセージ、通知フィード、ゲーム内のリアルタイムイベントログ。
    *   市場の価格チャートなど、数秒ごとに更新されるデータ。
*   **データの更新処理 (Mutation):**
    *   フォームの送信（`POST`）、データの更新（`PUT`）、削除（`DELETE`）といった、サーバーの状態を変更する操作。これらの操作は通常、ユーザーのインタラクションによってトリガーされます。
*   **クライアントサイドの状態に依存するデータ:**
    *   `localStorage`や`sessionStorage`に保存されたユーザー設定に基づいてデータをフェッチする場合。
    *   ブラウザのGeolocation APIなど、クライアントサイドのAPIから取得した情報に基づいてデータをフェッチする場合。

これらのシナリオでは、`useEffect`の落とし穴を避けるため、`SWR`や`React Query`といった専用のデータ取得ライブラリを使用するのが現代のベストプラクティスです。

---

### **9.6 `SWR`：より良いデータ取得フック**

`SWR`は、Next.jsを開発するVercel社が作成した、React向けのデータ取得ライブラリです。その名前は`stale-while-revalidate`というHTTPキャッシュ戦略に由来します。

**`stale-while-revalidate`のコンセプト:**
`stale-while-revalidate`は、データ取得のUXを劇的に向上させるキャッシュ戦略です。
1.  まずキャッシュにある古いデータ（`stale`）を返して素早くUIを表示し、
2.  その裏側で最新のデータを取得（`revalidate`）しにいき、
3.  取得が完了したらUIを更新する。

**たとえ話：ニュースアプリの挙動**
`SWR`は、スマートフォンのニュースアプリの挙動に似ています。
1.  アプリを開くと、まず前回読み込んだ記事（**staleなキャッシュ**）が瞬時に表示される。
2.  その裏側で、アプリは最新のニュース（**revalidate**）をダウンロードし始める。
3.  ダウンロードが完了すると、新しいニュースが画面に表示される。

これにより、ユーザーはオフラインでもコンテンツを見ることができ、かつオンラインになれば自動で最新情報に更新されるという、非常に優れたUXが実現されます。

#### **`SWR`の基本APIとメリット**
`useEffect`パターンを`SWR`で書き換えてみましょう。

```tsx
// components/client/PlayerInventorySWR.tsx
"use client";
import useSWR from 'swr';
import type { InventoryItem } from '@/types/game.types';

interface PlayerInventory {
  items: InventoryItem[];
  lastUpdated: string;
}

// どんなURLが来ても、標準のfetchでデータを取得してJSONを返す、という共通関数
const fetcher = (url: string) => fetch(url).then(res => {
  if (!res.ok) {
    throw new Error('Failed to fetch data');
  }
  return res.json();
});

export default function PlayerInventorySWR({ playerId }: { playerId: string }) {
  // useSWRに「キー(通常はURL)」と「fetcher関数」を渡す
  const { data: inventory, error, isLoading } = useSWR<PlayerInventory>(`/api/users/${playerId}/inventory`, fetcher);

  if (isLoading) return <div className="text-center p-4">インベントリを読み込み中...</div>;
  if (error) return <div className="text-red-500 p-4">エラーが発生しました: {error.message}</div>;
  if (!inventory) return <div className="p-4">インベントリデータがありません。</div>;

  return (
    <div className="p-4 border rounded-md shadow-sm">
      <h2 className="text-xl font-bold mb-3">プレイヤーインベントリ</h2>
      <ul>
        {inventory.items.map(item => (
          <li key={item.id}>{item.name} ({item.quantity})</li>
        ))}
      </ul>
      <p className="text-sm text-gray-500 mt-2">最終更新: {new Date(inventory.lastUpdated).toLocaleTimeString()}</p>
    </div>
  );
}
```
`useEffect`と3つの`useState`が、たった1行の`useSWR`フックに置き換わりました。
**`SWR`が自動でやってくれること:**
*   `isLoading`, `error`, `data`の状態管理
*   リクエスト結果のメモリキャッシュ
*   **自動再検証 (Automatic Revalidation):**
    *   **フォーカス時:** ユーザーがブラウザタブを切り替えて戻ってきたときに、自動的にデータを再取得し、最新の状態に更新します。
    *   **ネットワーク再接続時:** ネットワーク接続が回復したときに、自動的にデータを再取得します。
    *   **ポーリング:** （設定により）一定間隔でデータを再取得します。
*   **エラーリトライ:** データ取得に失敗した場合、自動的にリトライを試みます。
*   **重複リクエストの排除:** 同じキーに対する複数のリクエストを自動的にマージし、一度だけフェッチします。

**その他のSWRフック:**
*   **`useSWRImmutable`:** データが一度フェッチされたら、自動再検証を行わない場合に便利です。
*   **`useSWRInfinite`:** 無限スクロールやページネーションを実装する際に、複数のページにわたるデータを効率的に取得・管理できます。

**思考実験:**
「Nojo Farm」の市場ページで、リアルタイムの市場価格チャートを表示する`MarketPriceChart`コンポーネントを実装するとします。このチャートは、5秒ごとにAPIから最新の価格データを取得し、表示を更新する必要があります。`SWR`の`useSWR`フックを使って、このポーリング機能をどのように実装しますか？また、ユーザーが市場ページから別のタブに移動している間はポーリングを一時停止し、戻ってきたら再開するようにするには、`SWR`のどの機能が役立ちますか？

---

### **9.7 `SWR`によるデータ更新 (Mutation) とOptimistic UI**

`SWR`の真価は、データの取得だけでなく、更新処理においても発揮されます。`mutate`関数を使うことで、サーバーのデータを更新した後にUIを効率的に同期させることができます。

**実践例：農地の作物を植える/収穫する (Nojo Farm)**
プレイヤーが農地の区画をクリックして作物を植えたり収穫したりする操作は、サーバーの状態を変更するミューテーションです。

```tsx
// components/farm/FarmPlotSWR.tsx
"use client";
import useSWR, { useSWRConfig } from 'swr';
import type { Plot } from '@/types/game.types';

interface FarmPlotSWRProps {
  plotId: number;
}

const fetcher = (url: string) => fetch(url).then(res => res.json());

export default function FarmPlotSWR({ plotId }: FarmPlotSWRProps) {
  const { mutate } = useSWRConfig(); // グローバルなmutate関数を取得
  const { data: plot, error, isLoading } = useSWR<Plot>(`/api/plots/${plotId}`, fetcher);

  const handlePlantCrop = async (cropName: string) => {
    if (!plot) return;

    // 1. Optimistic UI: サーバーからの応答を待たずに、先にUIを更新してしまう
    // mutateの第一引数: 更新するデータのキー
    // mutateの第二引数: キャッシュを更新する関数 (現在のデータを受け取り、新しいデータを返す)
    // mutateの第三引数: revalidate (再検証) を行うかどうか (ここではfalseで、後で明示的に再検証)
    mutate(
      `/api/plots/${plotId}`,
      (currentPlot) => {
        if (!currentPlot) return currentPlot;
        return { ...currentPlot, crop: { id: 'new-crop', name: cropName, stage: 'seed', plantedAt: Date.now() } };
      },
      false // サーバーからの応答を待たずにUIを更新するため、ここでは再検証しない
    );

    try {
      // 2. サーバーに更新リクエストを送信
      await fetch(`/api/plots/${plotId}/plant`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cropName }),
      });
      // 3. サーバーへのリクエストが成功したら、最終的なデータで再検証
      mutate(`/api/plots/${plotId}`); // SWRに`/api/plots/${plotId}`のデータを再取得させ、UIを自動で更新
    } catch (err) {
      // エラーが発生した場合、UIを元の状態に戻す (ロールバック)
      alert('作物の植え付けに失敗しました。');
      mutate(`/api/plots/${plotId}`); // キャッシュを強制的に再検証して元の状態に戻す
    }
  };

  const handleHarvestCrop = async () => {
    if (!plot || plot.crop?.stage !== 'harvest') return;

    mutate(
      `/api/plots/${plotId}`,
      (currentPlot) => {
        if (!currentPlot) return currentPlot;
        return { ...currentPlot, crop: null }; // 収穫後、区画を空にする
      },
      false
    );

    try {
      await fetch(`/api/plots/${plotId}/harvest`, { method: 'POST' });
      mutate(`/api/plots/${plotId}`);
    } catch (err) {
      alert('作物の収穫に失敗しました。');
      mutate(`/api/plots/${plotId}`);
    }
  };

  if (isLoading) return <div className="p-4 border rounded-md">読み込み中...</div>;
  if (error) return <div className="text-red-500 p-4">エラー: {error.message}</div>;
  if (!plot) return <div className="p-4">区画データがありません。</div>;

  return (
    <div className="p-4 border rounded-md shadow-sm">
      <p>区画ID: {plot.id}</p>
      {plot.crop ? (
        <>
          <p>作物: {plot.crop.name}</p>
          <p>ステージ: {plot.crop.stage}</p>
          {plot.crop.stage === 'harvest' && (
            <button onClick={handleHarvestCrop} className="bg-green-500 text-white px-3 py-1 rounded mt-2">
              収穫する
            </button>
          )}
        </>
      ) : (
        <button onClick={() => handlePlantCrop('トマト')} className="bg-blue-500 text-white px-3 py-1 rounded mt-2">
          トマトを植える
        </button>
      )}
    </div>
  );
}
```
`mutate(key)`を呼び出すことで、指定したキー（URL）のデータを再検証させ、UIを最新の状態に保つことができます。

**Optimistic UI（楽観的更新）:**
Optimistic UIは、サーバーからの応答を待たずに、成功すると仮定して先にUIを更新してしまう方法です。これにより、ユーザーはボタンをクリックした瞬間にUIが反応するため、非常に体感速度の速いアプリケーションを構築できます。

*   **メリット:** ユーザー体験の向上（UIの即時反応）。
*   **デメリット:** サーバーでの処理が失敗した場合、UIを元の状態に戻す（ロールバック）処理が必要になります。

**`useSWRMutation`フック:**
`SWR`は、ミューテーションをよりシンプルに扱うための`useSWRMutation`フックも提供しています。これは、ミューテーションのローディング状態、エラー状態、そしてOptimistic UIのロジックをより宣言的に記述できます。

**思考実験:**
「Nojo Farm」で、プレイヤーが動物に餌を与える`FeedAnimalButton`コンポーネントを実装するとします。このボタンをクリックすると、`POST /api/animals/{animalId}/feed`というAPIを呼び出し、動物の`fed`ステータスを`true`に更新します。
1.  `FeedAnimalButton`コンポーネントを`SWR`の`mutate`関数とOptimistic UIを使って実装してください。
2.  Optimistic UIを実装する際に、サーバーからの応答を待たずにUIを更新するロジックと、API呼び出しが失敗した場合にUIを元の状態に戻す（ロールバック）ロジックを具体的に記述してください。
3.  `useSWRMutation`フックを使うと、このミューテーションロジックはどのように簡略化されますか？

---
### **第9章のまとめ**

この章では、現代のReact/Next.jsアプリケーションにおける非同期データ取得の戦略を、サーバーサイドとクライアントサイドの両面から探求しました。

*   **データ取得の複雑性**: ローディング、成功、エラーという3つの状態管理の必要性を理解し、それぞれの状態におけるユーザー体験の設計の重要性を学びました。
*   **`useEffect`の落とし穴**: 伝統的な`useEffect`を使ったデータ取得アプローチが抱えるボイラープレート、競合状態、キャッシュの欠如、手動での再取得といった問題点を深く掘り下げました。
*   **サーバーコンポーネントでの取得**: Next.js App Routerの標準的な方法として、`async/await`と`fetch`のキャッシュオプションを組み合わせ、レンダリング戦略と直結したシンプルで強力なデータ取得を学びました。`Suspense`と`Error Boundary`がどのように連携し、データ取得のUXを向上させるのかを理解しました。
*   **Next.jsの拡張`fetch`APIとキャッシュ戦略**: Next.jsが提供する`fetch`のキャッシュメカニズム（リクエストメモ化、データキャッシュ）と、SSG, SSR, ISRといったレンダリング戦略との連携を詳細に学びました。`revalidatePath`や`revalidateTag`によるキャッシュの手動制御方法も習得しました。
*   **クライアントサイド取得の必要性**: ユーザー操作に依存するデータや、リアルタイム性の高いデータ、データの更新処理には、依然としてクライアントサイドでの取得が必要であることを認識しました。
*   **`SWR`によるモダンなクライアント取得**: `useEffect`パターンの多くの落とし穴を解決し、キャッシュ、自動再取得、ローディング/エラー状態の管理を自動化する`SWR`の強力な機能を学びました。`stale-while-revalidate`のコンセプトが、いかに優れたUXを実現するのかを理解しました。
*   **`SWR`によるデータ更新 (Mutation)**: `SWR`の`mutate`関数を使い、サーバーのデータを更新した後にUIを効率的に同期させる方法を習得しました。特に、Optimistic UI（楽観的更新）の実装方法と、そのメリット・デメリットを深く理解しました。`useSWRMutation`フックによるミューテーションの簡略化についても触れました。

データ取得は、アプリケーションのパフォーマンスとユーザー体験の根幹をなす要素です。サーバーコンポーネントを主軸としつつ、必要な場面で`SWR`のようなモダンなライブラリをクライアントサイドで活用する。このハイブリッドなアプローチこそが、現代のNext.js開発におけるベストプラクティスと言えるでしょう。

次の章では、アプリケーションのパフォーマンスをさらに向上させるための、より高度な最適化テクニックについて探求します。
