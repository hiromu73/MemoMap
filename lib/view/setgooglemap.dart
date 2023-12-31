import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_crudapp/model.dart/mapinitialized_model.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/latitude.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/longitude.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/autocomplete_search.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/selectitem.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/textpredictions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

final mapInitLatitudePosition = StateProvider.autoDispose<double>((ref) => 0.0);
final mapInitLongitudePosition =
    StateProvider.autoDispose<double>((ref) => 0.0);
final _googlePlace = GooglePlace(Api.apiKey);
final cameraPositionProvider = StateProvider<CameraPosition>((ref) {
  return const CameraPosition(
    target: LatLng(34.702809862535936, 135.49666833132505),
    zoom: 15.0,
  );
});
final selectedGenreProvider = StateProvider<String?>((ref) => null);
final isSelectItem = StateProvider<List<String?>>((ref) => []);

class MapSample extends ConsumerWidget {
  MapSample({super.key});
  final apiKey = Api.apiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectItems = ref.watch(selectItemsProvider);

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                // 初回のみ実行かどうか
                _initializeOnes(ref);
                // 初回にマップが作成されたときに初期位置を設定する
                controller.moveCamera(CameraUpdate.newCameraPosition(
                  ref.watch(cameraPositionProvider),
                ));
              },
              mapType: MapType.normal,
              initialCameraPosition: ref.watch(cameraPositionProvider),
              // markers: buildMarkers(ref),
              myLocationEnabled: true,
              onTap: (LatLng latLang) {},
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              // markers: Marker(),
            ),
            // モーダル表示
            Align(
              alignment: const Alignment(0.8, -0.85),
              child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 50,
                    height: 40,
                    child: const Icon(
                      Icons.dehaze_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.6),
                        builder: (context) {
                          return ShowModal();
                        });
                  }),
            ),
            //テキスト検索候補表示
            Align(
                alignment: const Alignment(-0.6, -0.85),
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    controller: TextEditingController(text: selectItems),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      iconColor: Colors.grey,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: "検索したい場所",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onTap: () async {
                      await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          enableDrag: true,
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (context) {
                            return ShowTextModal();
                          });
                    },
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                )),
            // 登録ボタン
            Align(
                alignment: const Alignment(0.94, 0.8),
                child: FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => {Navigator.pop(context)}))
          ],
        ),
      ),
    );
  }
}

// 現在位置を取得するメソッド
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // isLocationServiceEnabledはロケーションサービスが有効かどうかを確認
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('ロケーションサービスが無効です。');
  }

  // ユーザーがデバイスの場所を取得するための許可をすでに付与しているかどうかを確認
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    // デバイスの場所へのアクセス許可をリクエストする
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('デバイスの場所を取得するための許可がされていません。');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('デバイスの場所を取得するための許可してください');
  }
  // デバイスの現在の場所を返す。
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return position;
}

Future _initializeOnes(WidgetRef ref) async {
  // 初回のみ実行する非同期処理
  if (ref.watch(mapInitializedModelProvider)) {
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    final initCameraPosition = LatLng(latitude, longitude);
    final newCameraPosition =
        CameraPosition(target: initCameraPosition, zoom: 15.0);
    ref.watch(cameraPositionProvider.notifier).state = newCameraPosition;
    ref.read(mapInitializedModelProvider.notifier).changeInit();
    print(newCameraPosition);
  }
}

// 検索処理
// void autoCompleteSearch(String value, WidgetRef ref) async {
//   final result = await _googlePlace.autocomplete.get(value);
//   if (result != null && result.predictions != null) {
//     ref.read(predictions).state = result.predictions!;
//   }
// }
// Set<Marker> buildMarkers(WidgetRef ref) {
//   final markers = <Marker>{};

//   // 現在地のマーカー
// markers.add(Marker(
//   markerId: MarkerId('currentLocation'),
//   position: LatLng(
//     ref.watch(latitudeProvider),
//     ref.watch(longitudeProvider),
//   ),
//   infoWindow: InfoWindow(title: 'Current Location'),
// ));

// 選択された場所のマーカー
// final selectedPlace = ref.watch(selectedPlaceProvider);
// if (selectedPlace != "") {
//   markers.add(Marker(
//     markerId: MarkerId(selectedPlace),
//     position: LatLng(
//       selectedPlace.location.lat,
//       selectedPlace.geometry.location.lng,
//     ),
//     infoWindow: InfoWindow(title: selectedPlace.name),
//   ));
// }

// return markers;

// Future<void> addMarker(String genre, WidgetRef ref) async {
//   // 選択された場所の座標を取得
//   // final place = await _getLocationForGenre(genre);
//   final details = await _googlePlace.details.get(genre);
//   final location = details?.result?.geometry?.location;
//   if (location != null) {
//     final newCameraPosition = CameraPosition(
//       target: LatLng(10.0, 10.0),
//       zoom: 15.0,
//     );
//     ref.read(cameraPositionProvider.notifier).state = newCameraPosition;

//     // マーカーを追加
//     //ref.read(googlemapModelProvider.notifier).addMarker(place.name, location);
//   }
// }

// Future<void> _addMarkerForGenre(String genre, WidgetRef ref) async {
//   // ジャンルに対応する位置情報の取得
//   final location = await _getLocationForGenre(genre);
//   if (location != null) {
//     // マーカーを追加
//     ref.read(googlemapModelProvider.notifier).addMarker(genre, location);
//   }
// }

Future<void> getLocationForGenre(String genre) async {
  await _googlePlace.autocomplete.get(genre);
}

void updatePredictions(String value, WidgetRef ref) async {
  if (value.isEmpty) {
    ref.read(textPredictionsProvider.notifier).noneList();
    return;
  }

  final response = await _googlePlace.autocomplete.get(value);
  if (response != null && response.predictions != null) {
    ref.read(textPredictionsProvider.notifier).changeList(response);
  }
}

class ShowTextModal extends ConsumerWidget {
  final TextEditingController textController = TextEditingController();
  ShowTextModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoCompleteSearch = ref.watch(autoCompleteSearchProvider);
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      height: 700,
      child: Column(
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            controller: textController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              iconColor: Colors.grey,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              hintText: "検索したい場所",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) async {
              // updatePredictions(value, ref);
              print(value);
              if (value.isNotEmpty) {
                await ref
                    .read(autoCompleteSearchProvider.notifier)
                    .autoCompleteSearch(value, 34.758663, 135.497186);
              } else {
                if (value.isEmpty) {
                  ref.read(autoCompleteSearchProvider.notifier).state = [];
                }
              }
            },
          ),
          SizedBox(
            width: 350,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: autoCompleteSearch.length,
                itemBuilder: (context, index) {
                  return menuItem(autoCompleteSearch[index].toString());
                }),
          ),
        ],
      ),
    );
  }
}

Widget menuItem(String title) {
  return InkWell(
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: Row(
        children: <Widget>[
          Flexible(
            child: ListTile(
              title: Text(title),
              trailing: Text("距離"),
            ),
          )
        ],
      ),
    ),
    onTap: () {
      print(title);
    },
  );
}

// 簡易検索モーダル
class ShowModal extends ConsumerWidget {
  const ShowModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectItem = ref.watch(selectItemsProvider);
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      height: 250,
      child: Column(
        children: [
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: items.map((item) {
              return InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                onTap: () async {
                  print("選択=$item");
                  if (ref.watch(selectItemsProvider).contains(item)) {
                    await ref.read(selectItemsProvider.notifier).remove(item);
                  } else {
                    await ref.read(selectItemsProvider.notifier).add(item);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color:
                        selectItem.contains(item) ? Colors.blue : Colors.white,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                        color: selectItem.contains(item)
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
              child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(selectItemsProvider.notifier).none();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
  // Future<CameraPosition> _initPosition(latitude, longitude) async {
  //   // 現在位置を取得するメソッドの結果を取得する。
  //   final cameraPosition = await CameraPosition(
  //     target: LatLng(latitude, longitude),
  //     zoom: 15,
  //   );
  //   return cameraPosition;
  // }
  //   final latitude = position.latitude;
  //   final longitude = position.longitude;
  //   String? isSelectMenu = "";
  //   Uri? mapURL;

  //   // googlemapと同じAPIキーを指定
  //   final googlePlace = GooglePlace(apiKey);

  //   // 検索処理 googlePlace.search.getNearBySearch() 近くの検索
  //   final response = await googlePlace.search.getNearBySearch(
  //       Location(lat: latitude, lng: longitude), 1000,
  //       language: 'ja', keyword: isSelectMenu, rankby: RankBy.Distance);

  //   final results = response!.results;
  //   final isExist = results?.isNotEmpty ?? false;

  //   if (isExist) {
  //     return;
  //   }

  //   final firstResult = results?.first;
  //   final selectLocation = firstResult?.geometry?.location;
  //   final selectLocationLatitude = selectLocation?.lat;
  //   final selectLocationLongitude = selectLocation?.lng;

  //   String urlString = '';
  //   if (Platform.isAndroid) {
  //     urlString =
  //         'https://www.google.co.jp/maps/dir/$latitude,$longitude/$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
  //   } else if (Platform.isIOS) {
  //     urlString =
  //         'comgooglemaps://?saddr=$latitude,$longitude&daddr=$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
  //   }

  //   mapURL = Uri.parse(urlString);
  // }
// }
