/// Decodes an encoded polyline string from Google Maps API into a list of [Map<String, double>]
/// containing 'lat' and 'lng' keys.
List<Map<String, double>> decodePolyline(String encoded) {
  final List<Map<String, double>> points = [];
  int index = 0;
  int lat = 0, lng = 0;

  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add({'lat': lat / 1e5, 'lng': lng / 1e5});
  }
  return points;
}
