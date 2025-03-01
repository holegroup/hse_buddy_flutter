import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraControllerX extends GetxController {
  CameraController? controller;
  List<XFile> capturedImages = [];
  String? errorMessage;
  int cameraIndex = 0; // Track the current camera index
  List<CameraDescription> cameras = []; // List of available cameras
  double currentZoomLevel = 1.0; // Initialize zoom level
  double maxZoomLevel = 1.0; // This will be set after initializing the camera

  Future<void> initializeCamera([int? index]) async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = "No cameras available on this device";
        update();
        return;
      }
      cameraIndex = index ?? 0;
      controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
      await controller!.initialize();

      // Set the max zoom level after camera initialization
      maxZoomLevel = await controller!.getMaxZoomLevel();
      update();
    } catch (e) {
      errorMessage = "Camera error: $e";
      update();
    }
  }

  void setZoomLevel(double zoom) {
    currentZoomLevel = zoom;
    controller?.setZoomLevel(currentZoomLevel);
    update(); // Update to reflect the zoom level change
  }

  Future<void> switchCamera() async {
    if (cameras.length > 1) {
      cameraIndex = (cameraIndex + 1) % cameras.length;
      await controller?.dispose();
      await initializeCamera(cameraIndex);
      setZoomLevel(1);
    }
  }
  

  Future<void> captureImage() async {
    if (controller != null && controller!.value.isInitialized) {
      final image = await controller!.takePicture();
      capturedImages.add(image); // Store each captured image
      update(); // Notify listeners
    }
  }

  void deleteImage(int index) {
    if (index >= 0 && index < capturedImages.length) {
      capturedImages.removeAt(index); // Remove image at the given index
      update();
    }
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
}
