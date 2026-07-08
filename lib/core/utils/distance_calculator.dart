import 'package:latlong2/latlong.dart' as ll;
import 'package:tekushare/domain/entities/lat_lng.dart';

double calcDistanceKm(List<LatLng> points) {
  if (points.length < 2) return 0;
  const d = ll.Distance();
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    total += d.as(
      ll.LengthUnit.Kilometer,
      ll.LatLng(points[i].latitude, points[i].longitude),
      ll.LatLng(points[i + 1].latitude, points[i + 1].longitude),
    );
  }
  return total;
}

String formatDistanceKm(double km) {
  if (km == 0) return '-';
  if (km < 1.0) return '${(km * 1000).round()}m';
  return '${km.toStringAsFixed(1)}km';
}
