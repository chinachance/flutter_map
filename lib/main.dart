import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_seamap/map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sea Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sea Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String map_url = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  String sea_map_url =
      'http://m12.shipxy.com/tile.c?l=Na&m=o&x={x}&y={y}&z={z}.png';
  bool change_url = false;
  List<Marker> allMarkers = [];
  List<Marker> markers = [];

  @override
  void initState() {
    request();
  }

  void _changeMap() {
    setState(() {
      change_url = !change_url;
    });
  }

  Future<void> request() async {
    var httpClient = new HttpClient();
    var uri = Uri.parse(
        "https://www.lanshuimu.com/test_gis/gis/webgis-v1/ship//queryShipPositions?hsjgDm=060900");
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var data = jsonDecode(responseBody);
    List<Map<String, dynamic>> listMap =
        new List<Map<String, dynamic>>.from(data);
    print(listMap.toString());

    listMap.forEach((m) => allMarkers.add(Marker(
        width: 5,
        height: 5,
        point: LatLng(m['lat'], m['lon']),
        builder: (ctx) => Container(
              child: Container(
                width: 5,
                height: 5,
                color: Colors.red,
              ),
            ))));

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    // allMarkers.add(Marker(
    //     width: 20,
    //     height: 35,
    //     point: LatLng(30.3638, 120.852965),
    //     builder: (ctx) => Container(
    //           child: Image(
    //             image: AssetImage("assets/images/ic_map_board_member.png"),
    //           ),
    //         )));
    //
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          alignment: Alignment.bottomRight,
          // fit: StackFit.expand, //未定位widget占满Stack整个空间
          children: [
            FlutterMap(
              options: MapOptions(
                center: LatLng(30.3638, 120.852965),
                zoom: 10.0,
                //设置可旋转、拖动等属性
                interactiveFlags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.pinchMove,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: change_url ? map_url : sea_map_url,
                  subdomains: ['a', 'b', 'c'],
                  tileProvider: NonCachingNetworkTileProvider(),
                ),
                MarkerLayerOptions(markers: allMarkers)
              ],
            ),
            Positioned(
              bottom: 18,
              right: 18,
              child: FloatingActionButton(
                onPressed: _changeMap,
                child: Text('切换'),
              ),
            ),
          ],
        ));
  }
}
