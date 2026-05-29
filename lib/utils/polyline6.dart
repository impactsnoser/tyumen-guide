import 'package:latlong2/latlong.dart';

/// Декодирование polyline6 (Google polyline algorithm, precision=1e6).
List<LatLng> decodePolyline6(String encoded) {
  var index = 0;
  var lat = 0;
  var lng = 0;
  final coords = <LatLng>[];

  while (index < encoded.length) {
    final latChange = _decodeValue(encoded, () => index++);
    final lngChange = _decodeValue(encoded, () => index++);
    lat += latChange;
    lng += lngChange;
    coords.add(LatLng(lat / 1e6, lng / 1e6));
  }

  return coords;
}

int _decodeValue(String encoded, int Function() nextIndex) {
  var result = 0;
  var shift = 0;
  int b;

  while (true) {
    b = encoded.codeUnitAt(nextIndex()) - 63;
    result |= (b & 0x1f) << shift;
    shift += 5;
    if (b < 0x20) break;
  }

  final delta = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  return delta;
}

