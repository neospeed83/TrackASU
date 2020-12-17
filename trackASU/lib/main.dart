import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Marker> busMarkers = new List();

  @override
  void initState() {
    super.initState();
    getBusCoordinates();
  }

  Future getBusCoordinates() async {
    Uri uri = Uri(
      scheme: 'https',
      host: 'arizonastate.ridesystems.net',
      path: '/Services/JSONPRelay.svc/GetMapVehiclePoints',
      queryParameters: {
        'apiKey': "8882812681",
      },
    );

    http.Response response;
    try {
      response = await http.get(uri);
    } on Exception catch (e) {
      print('Network Error: $e');
      throw e;
    }

    final jsonResponse = json.decode(response.body);

    List markers = new List();
    for (var bus in jsonResponse) {
      if (bus["RouteID"] == 5) {
        markers.add(bus);
      }
    }

    List<Marker> plotMarkers = new List();

    for (var marker in markers) {
      var lat = marker["Latitude"];
      var lng = marker["Longitude"];
      var turns = marker["Heading"] ~/ 90;

      var newMarker = new Marker(
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.width * 0.1,
        point: new LatLng(lat, lng),
        builder: (ctx) => new Container(
          child: RotatedBox(
              quarterTurns: turns,
              child: Icon(CupertinoIcons.arrowtriangle_down_circle_fill)),
        ),
      );

      plotMarkers.add(newMarker);
    }

    setState(() {
      busMarkers = plotMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: busMarkers.length == 0
            ? Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ))
            : new FlutterMap(
                options: new MapOptions(
                  center: new LatLng(33.3528, -111.7890),
                  zoom: 10.5,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  new MarkerLayerOptions(
                    markers: busMarkers,
                  ),
                ],
            )
    );
  }
}
