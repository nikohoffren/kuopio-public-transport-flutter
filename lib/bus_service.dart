import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/generated/gtfs-realtime.pb.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BusService {
  static Future<BitmapDescriptor> _getBusIcon() async {
    final imageData = await rootBundle.load('assets/bus-icon.png');
    final imageBytes = imageData.buffer.asUint8List();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 50,
      minHeight: 50,
      quality: 90,
    );
    return BitmapDescriptor.fromBytes(compressedBytes);
  }

  static Future<List<Marker>> getBusLocations() async {
    // Fetch the GTFS-realtime data from the API endpoint.
    var client = HttpClient();
    var request = await client.getUrl(Uri.parse(
        dotenv.env['GTFS_REALTIME_API_URL']!));
    request.headers.add(
        "authorization",
        "Basic ${base64Encode(utf8.encode(
                "${dotenv.env['GTFS_USERNAME']}:${dotenv.env['GTFS_PASSWORD']}"))}");
    var response = await request.close();
    var responseBodyBytes = await response.fold<List<int>>([], (a, b) => a..addAll(b));

    // Parse the GTFS-realtime data and extract the bus locations.
    var feedMessage = FeedMessage();
    feedMessage.mergeFromBuffer(responseBodyBytes);
    List<Marker> markers = [];

    // Load the custom bus icon
    BitmapDescriptor busIcon = await _getBusIcon();

    for (var entity in feedMessage.entity) {
      if (entity.vehicle != null) {
        var vehicle = entity.vehicle;
        var lat = vehicle.position.latitude;
        var lng = vehicle.position.longitude;
        var marker = Marker(
          markerId: MarkerId(vehicle.vehicle.id),
          position: LatLng(lat, lng),
          icon: busIcon,
        );
        markers.add(marker);
      }
    }

    return markers;
  }
}
