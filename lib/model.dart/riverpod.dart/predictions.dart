import 'package:flutter_crudapp/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_place/google_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'predictions.g.dart';

@riverpod
class Predictions extends _$Predictions {
  final _googlePlace = GooglePlace(Api.apiKey);

  @override
  List<AutocompletePrediction?> build() => [];

  // 検索処理
  Future<void> autoCompleteSearch(String value) async {
    final result = await _googlePlace.autocomplete.get(value);
    print(result);
    if (result != null && result.predictions != null) {
      state = result.predictions!;
    }
  }
}
