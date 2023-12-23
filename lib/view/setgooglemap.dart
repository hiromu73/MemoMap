import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/googlemap_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

// GoogleMapの表示
class MapSample extends ConsumerWidget {
  MapSample({super.key});

  Position? currentPosition;
  final apiKey = Api.apiKey;
  final _placeController = TextEditingController();
  String? isSelectMenu = "";
  Uri? mapURL;
  bool? isExist;

  @override
  void initState() {
    // initState()はFutureできないのでメソッドを格納。
    initialize();
  }

  // 初期位置
  static const _cameraPosition = CameraPosition(
    target: LatLng(34.758663, 135.4971856623888),
    zoom: 15,
  );

  // 位置情報とマーカーIDを指定してマーカーを表示する関数
  Set<Marker> _createMaker(LatLng latLng, String markerId) {
    return {
      Marker(
        markerId: MarkerId(markerId),
        position: latLng,
      ),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapPosition = ref.watch(googlemapModelProvider);
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {},
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              markers: _createMaker(mapPosition, 'Marker1'),
              myLocationEnabled: true,
              onTap: (LatLng latLang) {
                ref
                    .read(googlemapModelProvider.notifier)
                    .changePosition(latLang);
                _createMaker(ref.watch(googlemapModelProvider), 'Marker1');
              },
            ),
            Align(
                alignment: const Alignment(-0.6, -0.85),
                child: SizedBox(
                    width: 200,
                    height: 40,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      controller: _placeController,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        iconColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        hintText: "検索したい場所",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fillColor: Colors.black,
                        filled: true,
                      ),
                    ))),
            Align(
                alignment: const Alignment(0.94, 0.8),
                child: FloatingActionButton(
                    child: const Icon(Icons.add), onPressed: () => {}))
          ],
        ),
      ),
    );
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future initialize() async {
    // 現在位置を取得するメソッドの結果を取得する。
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    // googlemapと同じAPIキーを指定
    final googlePlace = GooglePlace(apiKey);

    // 検索処理 googlePlace.search.getNearBySearch() 近くの検索
    final response = await googlePlace.search.getNearBySearch(
        Location(lat: latitude, lng: longitude), 1000,
        language: 'ja', keyword: isSelectMenu, rankby: RankBy.Distance);

    print(response);
    final results = response!.results;
    final isExist = results?.isNotEmpty ?? false;

    if (!isExist) {
      return;
    }

    final firstResult = results?.first;
    final selectLocation = firstResult?.geometry?.location;
    final selectLocationLatitude = selectLocation?.lat;
    final selectLocationLongitude = selectLocation?.lng;

    String urlString = '';
    if (Platform.isAndroid) {
      urlString =
          'https://www.google.co.jp/maps/dir/$latitude,$longitude/$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
    } else if (Platform.isIOS) {
      urlString =
          'comgooglemaps://?saddr=$latitude,$longitude&daddr=$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
    }

    mapURL = Uri.parse(urlString);
  }
}