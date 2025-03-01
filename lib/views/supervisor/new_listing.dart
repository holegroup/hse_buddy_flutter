import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/new_listing_controller.dart';

class NewListing extends StatefulWidget {
  NewListing({super.key});

  @override
  State<NewListing> createState() => _NewListingState();
}

class _NewListingState extends State<NewListing> {
  final NewListingController newListingController =
      Get.put(NewListingController());
  List<dynamic> items = []; // To store API data for items
  List<dynamic> parts = []; // To store API data for parts

  Future<void> fetchData() async {
    final fetchedItems = await newListingController.getItems(); // Fetch items
    final fetchedParts = await newListingController.getParts(); // Fetch parts
    setState(() {
      items = fetchedItems; // Update the items list
      parts = fetchedParts; // Update the parts list
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Listings"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: items.isEmpty && parts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Stack(children: [
                ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    // Display items
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ...items.map((item) => buildItemCard(item)).toList(),
                    // Display parts
                    if (parts.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, bottom: 5, top: 5),
                        child: Text(
                          "Parts",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ...parts.map((part) => buildPartCard(part)).toList(),
                  ],
                ),
                Obx(() {
                  if (newListingController.isLoadingGlobal.value) {
                    return Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Center(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.3,
                          height: MediaQuery.sizeOf(context).width * 0.3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                              child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircularProgressIndicator(),
                              Text("Working"),
                            ],
                          )),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                }),
              ]),
      ),
    );
  }

  // Widget to display each item
  Widget buildItemCard(dynamic item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Site Name: ${item['siteId']['site_name']}",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              "Equipment Name: ${item['productId']['equip_name']}",
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Serial Number: ${item['serial_number']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Added By: ${item['added_by']['name']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Status: ${item['status']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      newListingController.itemStatus(
                          itemId: item['_id'], status: 'Rejected');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Reject"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      newListingController.itemStatus(
                          itemId: item['_id'], status: 'Approved');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display each part
  Widget buildPartCard(dynamic part) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Equipment Name: ${part['productId']['equip_name']}",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              "Item Name: ${part['itemId']['item_name']}",
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Part Name: ${part['part_name']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Part Number: ${part['part_number']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Added By: ${part['added_by']['name']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "Status: ${part['status']}",
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("Rejected: ${part['_id']}");
                      newListingController.partStatus(
                          partId: part['_id'], status: 'Rejected');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Reject"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("Accepted: ${part['_id']}");
                      newListingController.partStatus(
                          partId: part['_id'], status: 'Approved');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
