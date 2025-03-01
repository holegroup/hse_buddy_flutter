import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/site_controller.dart';

class SiteDetailPage extends StatefulWidget {
  final String siteName;
  final String siteId;
  final String address;

  SiteDetailPage({
    super.key,
    required this.siteName,
    required this.siteId,
    required this.address,
  });

  @override
  State<SiteDetailPage> createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage> {
  final SiteController siteController = Get.put(SiteController());
  late List<dynamic> data;
  String? selectedEquipName;
  String? selectedEquipId;

  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    data = siteController.selectedSiteData['data'] ?? [];

    print(data);
    if (data.isNotEmpty) {
      selectedEquipName = data[0]['equip_name'];
      selectedEquipId = data[0]['product_id'];
      items = data[0]['items'];

      print(selectedEquipId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.siteName),
            Text(
              widget.address,
              maxLines: 3,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for selecting equipment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Select Product",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    siteController.addNewProduct();
                  },
                  child: const Text("Add Product   +"),
                ),
              ],
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedEquipName,
              onChanged: (value) {
                setState(() {
                  selectedEquipName = value;
                  items = data.firstWhere(
                      (element) => element['equip_name'] == value)['items'];
                  selectedEquipId = data.firstWhere((element) =>
                      element['equip_name'] == value)['product_id'];

                  print(selectedEquipId);
                });
              },
              items: data
                  .map<DropdownMenuItem<String>>(
                    (equipment) => DropdownMenuItem(
                      value: equipment['equip_name'],
                      child: Text(equipment['equip_name']),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            if (items.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Items",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => siteController.addNewItem(
                            productId: selectedEquipId.toString(),
                            SiteId: widget.siteId,
                          ),
                          child: Row(
                            children: [
                              Text("Add Item"),
                              SizedBox(width: 6),
                              Icon(
                                Icons.add,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final parts = item['parts'];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ExpansionTile(
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                "Serial Number: ${item['serial_number']}",
                              ),
                              children: [
                                if (parts.isNotEmpty)
                                  ...parts.map<Widget>((part) {
                                    return ListTile(
                                      title: Text(part['part_name']),
                                      subtitle: Text(
                                          "Part Number: ${part['part_number']}"),
                                    );
                                  }).toList()
                                else
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "No parts available.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.5,
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.blue.withOpacity(0.1)),
                                    ),
                                    onPressed: () => siteController.addNewPart(
                                      // serialNumber: item['serial_number'],
                                      productId: selectedEquipId.toString(),
                                      itemId: item['_id'],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Add Part"),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.add,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                "No items available for the selected Product.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
