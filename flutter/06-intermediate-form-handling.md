# Flutter教科書 - 中級編 - 3. フォーム処理 (農場たとえ話・増量版)

農場を運営していると、様々な事務手続きが必要になります。新しい家畜の登録、種の発注、日々の作業報告など、これらはすべて「フォーム」への記入作業です。この章では、Flutterで正確かつ効率的に事務手続き（フォーム処理）を行う方法を学びます。

---

## 3.1 フォームの構成要素 ～事務手続きの道具一式～

農場で事務手続きを行うには、いくつかの道具が必要です。

- **`TextField` (記入用紙)**: 文字を書き込むための、一行の入力欄です。
- **`TextEditingController` (魔法のペン)**: このペンを使えば、用紙に書かれた内容を後から読み取ったり、あらかじめ名前を書いておいたり（初期値設定）できます。
- **`Form` (クリップボード)**: 複数の記入用紙を一つにまとめるためのクリップボードです。これを使えば、すべての用紙を一度にチェックしたり、提出したりできます。
- **`GlobalKey<FormState>` (クリップボードの持ち手)**: クリップボード全体を操作するための「持ち手」です。この持ち手を使って「チェックしろ！」「提出しろ！」と命令します。

```mermaid
graph TD
    A[クリップボード (Form)] -- "持ち手" --> B(GlobalKey);
    A --> C[記入用紙1 (TextFormField)];
    A --> D[記入用紙2 (TextFormField)];
    C -- "魔法のペン1" --> E(TextEditingController);
    D -- "魔法のペン2" --> F(TextEditingController);
    G[提出ボタン] -- "持ち手を使って命令" --> B;
```

---

## 3.2 家畜の登録フォームを作ろう

例として、新しい家畜を登録するためのフォームを作成してみましょう。

### 1. 道具の準備
まず、クリップボードの持ち手（`GlobalKey`）と、各種情報を書き込むための魔法のペン（`TextEditingController`）を用意します。

```dart
class AnimalRegistrationForm extends StatefulWidget {
  const AnimalRegistrationForm({Key? key}) : super(key: key);
  @override
  State<AnimalRegistrationForm> createState() => _AnimalRegistrationFormState();
}

class _AnimalRegistrationFormState extends State<AnimalRegistrationForm> {
  // クリップボードの持ち手を作成
  final _formKey = GlobalKey<FormState>();

  // 魔法のペンを準備
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _speciesController = TextEditingController();

  // ペンは使い終わったら片付けるのがマナー
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  // ... フォームの見た目と処理を記述 ...
}
```

### 2. フォームの組み立てとバリデーション（記入チェック）
`Form` Widgetで全体を囲み、各入力欄として`TextFormField`（`Form`で使うことに特化した`TextField`）を配置します。

`validator`は、**おせっかいな事務員**のようなものです。「名前が空欄ですよ！」「年齢は数字で入力してください！」と、記入漏れや間違いをチェックしてくれます。

```dart
@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey, // クリップボードに持ち手をセット
    child: Column(
      children: <Widget>[
        TextFormField(
          controller: _nameController, // 名前用のペンを渡す
          decoration: const InputDecoration(labelText: '家畜の名前'),
          validator: (value) { // 事務員によるチェック
            if (value == null || value.isEmpty) {
              return '名前を入力してください'; // 未入力はエラー
            }
            return null; // 問題なければnullを返す
          },
        ),
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(labelText: '年齢'),
          keyboardType: TextInputType.number, // 数字入力キーボードを表示
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '年齢を入力してください';
            }
            if (int.tryParse(value) == null) {
              return '有効な数字を入力してください'; // 数字以外はエラー
            }
            return null;
          },
        ),
        // ... 他の入力欄も同様 ...
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            onPressed: _submitForm, // 提出ボタン
            child: const Text('登録'),
          ),
        ),
      ],
    ),
  );
}
```

### 3. フォームの提出（事務手続きの完了）
提出ボタンが押されたら、`_submitForm`メソッドが呼ばれます。

```dart
void _submitForm() {
  // 1. 持ち手を使って、事務員(validator)に全項目をチェックさせる
  if (_formKey.currentState!.validate()) {
    // 2. チェックが通ったら、クリップボードを「保存」状態にする
    _formKey.currentState!.save();

    // 3. 各ペンから記入内容を読み取る
    final String name = _nameController.text;
    final int age = int.parse(_ageController.text);
    final String species = _speciesController.text;

    // 4. 読み取った情報を使って、家畜を登録する処理を行う
    // (例: RiverpodのNotifierを呼び出す、APIに送信するなど)
    print('新しい家畜を登録しました: 名前=$name, 年齢=$age, 種類=$species');

    // 5. 成功メッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('登録が完了しました')),
    );
  } else {
    // 6. チェックに引っかかったら、エラーメッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('入力内容に誤りがあります')),
    );
  }
}
```

この一連の流れにより、ユーザーが入力したデータを安全かつ確実に受け取り、処理することができます。

---

### まとめ

この章では、農場での事務手続きに例えて、Flutterのフォーム処理を学びました。

- **道具**: `Form`(クリップボード)、`TextFormField`(記入用紙)、`TextEditingController`(魔法のペン)、`GlobalKey`(持ち手)といった、フォーム処理の基本要素を理解しました。
- **バリデーション (記入チェック)**: `validator`というおせっかいな事務員を配置することで、入力データの品質を保証する方法を学びました。
- **提出処理**: クリップボードの持ち手(`_formKey`)を使い、`validate()`でチェックし、問題なければ`save()`してデータを読み取り、次の処理へ渡すという一連の流れを実装しました。

正確なデータ入力は、多くのアプリケーションにとって生命線です。この章で学んだ技術は、あなたの農場（アプリ）の信頼性を大きく向上させるでしょう。
