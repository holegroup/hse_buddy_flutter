import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class DraftController extends GetxController {
  var drafts = <Map>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
  }

  void loadDrafts() async {
    var draftBox = await Hive.openBox('draftBox');
    drafts.value = draftBox.values.cast<Map>().toList();
  }

  Future<void> deleteDraftByIndex(int index) async {
    try {
      var draftBox = await Hive.openBox('draftBox');

      // Check if the index is valid
      if (index >= 0 && index < draftBox.length) {
        await draftBox
            .deleteAt(index); // Delete the draft at the specified index
        drafts.value =
            draftBox.values.cast<Map>().toList(); // Update the observable list

        Get.snackbar(
          "",
          'Draft deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(20),
        );
        Get.offAllNamed('/');
      } else {
        Get.snackbar(
          "ERROR",
          "Invalid index!",
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(20),
        );
      }
    } catch (e) {
      Get.snackbar(
        "ERROR",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(20),
      );
      print(e);
    }
  }

  Future<void> deleteAllDrafts() async {
    try {
      var draftBox = await Hive.openBox('draftBox');
      await draftBox.clear();
      Get.offAllNamed('/');
      Get.snackbar(
        "",
        'Your drafts has been deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(20),
      );
    } catch (e) {
      Get.snackbar(
        "ERROR",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(20),
      );
      print(e);
    }
  }
}
