import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menuitemcheckbox.g.dart';

// テキスト検索一覧のチェックボックス
@riverpod
class MenuItemCheckBox extends _$MenuItemCheckBox {
  @override
  bool build() => false;

  Future<void> checkChange(bool value) async {
    print("checkChangeメソッドの値は$value");
    state = value;
    print("checkChangeメソッド後の値は$state");
  }
}
