import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var googleMapsLink = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentPosition();
  }

  Future<void> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permissions not granted");
      await Geolocator.requestPermission();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      googleMapsLink.value = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      print("Lat: ${latitude.value}, Long: ${longitude.value}");
      print("Google Maps Link: ${googleMapsLink.value}");
    } catch (e) {
      print("Error fetching location: $e");
    }
  }
}
