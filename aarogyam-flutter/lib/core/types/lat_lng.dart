/// Thin wrapper around latitude/longitude, migrated from flutter_flow/lat_lng.dart.
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
