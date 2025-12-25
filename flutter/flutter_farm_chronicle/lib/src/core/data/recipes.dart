// ゲーム内の料理レシピを定義するファイルです。

// レシピの情報を保持するクラスです。
class Recipe {
  final String outputItemCode; // 完成する料理のアイテムコード
  final Map<String, int> ingredients; // 材料とその数量（アイテムコード: 数量）
  final double staminaCost; // 調理に必要なスタミナ
  final int timeCostMinutes; // 調理にかかるゲーム内時間（分）

  // コンストラクタ
  Recipe({
    required this.outputItemCode,
    required this.ingredients,
    required this.staminaCost,
    required this.timeCostMinutes,
  });
}

// ゲーム内で利用可能なすべてのレシピのリストです。
final List<Recipe> allRecipes = [
  // カブのスープのレシピ
  Recipe(
    outputItemCode: 'turnip_soup', // 完成品はカブのスープ
    ingredients: {
      'turnip_crop': 2, // 材料: カブ2個
      // TODO: 水などの汎用アイテムも追加する
    },
    staminaCost: 5.0, // スタミナ5消費
    timeCostMinutes: 30, // 30分かかる
  ),
  // TODO: 他の料理レシピをここに追加していきます。
];
