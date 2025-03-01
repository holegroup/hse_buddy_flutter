import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';

class Paginate extends StatefulWidget {
  const Paginate({super.key});

  @override
  State<Paginate> createState() => _PaginateState();
}

class _PaginateState extends State<Paginate> {
  final TaskController taskController = Get.put(TaskController());
  int selectedPage = 2;
  int maxPage = 2;

  @override
  void initState() {
    super.initState();
    selectedPage = taskController.pageNumber.value;
    maxPage = taskController.maxPage.value;
  }

  void goToPreviousPage() {
    if (selectedPage > 1) {
      setState(() {
        selectedPage--;
      });
      taskController.pageNumber.value = selectedPage;
      taskController.getTask(); // Fetch data for the new page
    }
  }

  void goToNextPage() {
    if (selectedPage < maxPage) {
      setState(() {
        selectedPage++;
      });
      taskController.pageNumber.value = selectedPage;
      taskController.getTask(); // Fetch data for the new page
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                  backgroundColor: selectedPage == 1
                      ? Colors.grey
                      : ColorPalette.primaryColor,
                  child: IconButton(
                      onPressed: goToPreviousPage,
                      icon: Icon(Icons.keyboard_arrow_left_rounded))),
              SizedBox(width: 8),
              Container(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: -10,
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ],
                  ),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: maxPage,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPage = index + 1;
                            });
                            taskController.pageNumber.value = index + 1;
                            taskController.getTask();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: selectedPage == index + 1 ? 3 : 0.0,
                                    color: selectedPage == index + 1
                                        ? ColorPalette.primaryColor
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: selectedPage == index + 1 ? 20 : 12,
                                  fontWeight: selectedPage == index + 1
                                      ? FontWeight.bold
                                      : null,
                                  color: selectedPage == index + 1
                                      ? ColorPalette.primaryColor
                                      : ColorPalette.light2,
                                ),
                              )),
                        );
                      })),
              SizedBox(width: 8),
              CircleAvatar(
                  backgroundColor: selectedPage == maxPage
                      ? Colors.grey
                      : ColorPalette.primaryColor,
                  child: IconButton(
                      onPressed: goToNextPage,
                      icon: Icon(Icons.keyboard_arrow_right_rounded))),
            ],
          ),
          SizedBox(height: 10),
          Obx(() {
            return Text(
                'showing ${taskController.tasks.length} results of ${taskController.totalResults}');
          }),
        ],
      ),
    );
  }
}
