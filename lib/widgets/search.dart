import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/search_controller.dart';

class SearchBox extends StatelessWidget {
  final bool isGoToReport;
  const SearchBox({super.key, this.isGoToReport = false});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    // final SearchController searchController = Get.put(SearchController());
    final SearchWidgetController searchBarController =
        Get.put(SearchWidgetController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search box with dropdown and clear option
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: -3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchBarController.searchController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed: () {
                    searchBarController.isVisible.value = false;
                  },
                  icon: Icon(Icons.close)),
              suffixIcon: Obx(() {
                if (searchBarController.isLoading == false) {
                  return IconButton(
                    onPressed: () {
                      // print(searchBarController.isSelected.value);
                      searchBarController.search();
                    },
                    icon: Icon(
                      Icons.search,
                      color: ColorPalette.primaryColor,
                      shadows: [
                        Shadow(
                          color: Colors.blue.shade900.withOpacity(0.9),
                          offset: Offset(0, 0),
                          blurRadius: 30,
                        )
                      ],
                    ),
                  );
                } else {
                  return Icon(Icons.search);
                }
              }),
              hintText: "Search...",
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),

        // Suggestions list
        Obx(() {
          if (searchBarController.filteredSites.isNotEmpty) {
            return Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: searchBarController.filteredSites.length < 4
                      ? searchBarController.filteredSites.length * 65
                      : 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: -3,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: searchBarController.filteredSites.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (isGoToReport) {
                            searchBarController.selectSiteAndOpenCamera(index);
                          } else {
                            searchBarController.selectSite(index);
                          }
                        },
                        child: Container(
                          height: 44,
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(
                              bottom: index + 1 ==
                                      searchBarController.filteredSites.length
                                  ? 0
                                  : 8),
                          decoration: BoxDecoration(
                              // color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (searchBarController.filteredSites[index]
                                                as Set)
                                            .first ==
                                        null
                                    ? ''
                                    : (searchBarController.filteredSites[index]
                                            as Set)
                                        .first,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                (searchBarController.filteredSites[index]
                                                as Set)
                                            .last ==
                                        null
                                    ? ''
                                    : (searchBarController.filteredSites[index]
                                            as Set)
                                        .last,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    searchBarController.clearSuggestions();
                    searchBarController.isVisible.value = false;
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(0, 6),
                          blurRadius: 14,
                          spreadRadius: -5,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        }),
      ],
    );
  }
}
