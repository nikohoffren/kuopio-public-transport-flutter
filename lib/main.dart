import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kuopio_public_transport_flutter/widgets/route_search_bar.dart';
import 'bus_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(
    const MaterialApp(
      home: Map(),
    ),
  );
}

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late String _mapStyle;
  Set<Marker> _markers = {};
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });
    _timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _updateBusLocations());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateBusLocations() async {
    var markers = await BusService.getBusLocations();
    setState(() {
      _markers = Set.of(markers);
    });
  }

  static const CameraPosition _kuopioCity = CameraPosition(
    target: LatLng(62.898310, 27.678131),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kuopioCity,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              controller.setMapStyle(_mapStyle);
              var markers = await BusService.getBusLocations();
              setState(() {
                _markers = Set.of(markers);
              });
            },
            markers: _markers,
          ),
          const Positioned(
            top: 16.0,
            left: 0,
            right: 0,
            child: RouteSearchBar(),
          ),
        ],
      ),
    );
  }
}
