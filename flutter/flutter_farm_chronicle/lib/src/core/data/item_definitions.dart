// ゲーム内で使用するアイテムの定義を保持するファイルです。
// ここで定義されるアイテムは、ゲームの進行中に変化しない静的なデータです。

// アイテムの種類を識別するための列挙型（enum）です。
// 例えば、作物、道具、魚、料理など、アイテムが何に分類されるかを示します。
enum ItemType {
  crop, // 作物
  tool, // 道具
  fish, // 魚
  dish, // 料理
  seed, // 種
  material, // 素材（木材、石など）
  animalProduct, // 動物の生産物（卵、ミルクなど）
  misc, // その他
}

// ゲーム内の各アイテムの情報を保持するクラスです。
// このクラスは、DriftのItemDefinitionsテーブルと連携して、アイテムのコード、名前、説明、売値などを管理します。
class Item {
  final String code; // アイテムを一意に識別するコード（例: 'tomato_seed', 'tilled_soil'）
  final String name; // アイテムの表示名（例: 'トマトの種', '耕された土'）
  final String description; // アイテムの説明文
  final int sellPrice; // アイテムの売値
  final ItemType type; // アイテムの種類
  final int? maxGrowthStage; // 作物の場合、最大成長段階（収穫可能になる段階）

  // コンストラクタ
  Item({
    required this.code,
    required this.name,
    required this.description,
    required this.sellPrice,
    required this.type,
    this.maxGrowthStage, // 作物以外はnull
  });
}

// ゲーム内で利用可能なすべてのアイテムの定義リストです。
// ゲーム開始時にデータベースのItemDefinitionsテーブルに初期データとして投入されます。
final List<Item> allGameItems = [
  // --- 土地の状態 ---
  Item(
    code: 'empty_soil',
    name: '空の土',
    description: '何も植えられていない土壌。',
    sellPrice: 0,
    type: ItemType.misc,
  ),
  Item(
    code: 'tilled_soil',
    name: '耕された土',
    description: '作物を植える準備ができた土壌。',
    sellPrice: 0,
    type: ItemType.misc,
  ),

  // --- 種 ---
  Item(
    code: 'turnip_seed',
    name: 'カブの種',
    description: '春に育つカブの種。',
    sellPrice: 10,
    type: ItemType.seed,
  ),

  // --- 作物 ---
  Item(
    code: 'turnip_crop',
    name: 'カブ',
    description: '春に収穫できる野菜。',
    sellPrice: 60,
    type: ItemType.crop,
    maxGrowthStage: 3, // カブは3段階成長したら収穫可能
  ),

  // --- 料理 ---
  Item(
    code: 'turnip_soup',
    name: 'カブのスープ',
    description: 'カブを煮込んだ温かいスープ。スタミナ回復効果がある。',
    sellPrice: 150,
    type: ItemType.dish,
  ),

  // --- 素材 ---
  Item(
    code: 'wood',
    name: '木材',
    description: '森で採れる基本的な素材。',
    sellPrice: 20,
    type: ItemType.material,
  ),
  Item(
    code: 'mushroom',
    name: 'キノコ',
    description: '森で採れる食用キノコ。',
    sellPrice: 30,
    type: ItemType.material,
  ),
  Item(
    code: 'wild_berry',
    name: '野イチゴ',
    description: '森で採れる甘酸っぱいベリー。',
    sellPrice: 25,
    type: ItemType.material,
  ),

  // --- 魚 ---
  Item(
    code: 'small_fish',
    name: '小魚',
    description: '小さな川魚。',
    sellPrice: 50,
    type: ItemType.fish,
  ),
  Item(
    code: 'medium_fish',
    name: '中魚',
    description: '食べ応えのある魚。',
    sellPrice: 120,
    type: ItemType.fish,
  ),
  Item(
    code: 'big_fish',
    name: '大魚',
    description: '珍しい大物。',
    sellPrice: 300,
    type: ItemType.fish,
  ),

  // --- 動物の生産物 ---
  Item(
    code: 'egg',
    name: '卵',
    description: 'ニワトリが産んだ新鮮な卵。',
    sellPrice: 40,
    type: ItemType.animalProduct,
  ),
  Item(
    code: 'milk',
    name: 'ミルク',
    description: 'ウシから搾った新鮮なミルク。',
    sellPrice: 100,
    type: ItemType.animalProduct,
  ),

  // --- 動物の餌 ---
  Item(
    code: 'animal_feed',
    name: '動物の餌',
    description: '動物が喜んで食べる餌。',
    sellPrice: 20,
    type: ItemType.misc, // またはItemType.feedなど新しいタイプを定義しても良い
  ),
  // TODO: 他の種や作物、道具、魚、料理などのアイテム定義をここに追加していきます。
];
