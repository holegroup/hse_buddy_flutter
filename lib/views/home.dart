import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/search_controller.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hole_hse_inspection/views/all_tasks.dart';
import 'package:hole_hse_inspection/views/draft_report.dart';
import 'package:hole_hse_inspection/views/profile.dart';
import 'package:hole_hse_inspection/views/view_sites.dart';
import 'package:hole_hse_inspection/widgets/drawer_button.dart';
import 'package:hole_hse_inspection/widgets/footer.dart';
import 'package:hole_hse_inspection/widgets/search.dart';
import 'package:hole_hse_inspection/widgets/todo_calender.dart';
import '../controllers/draft_controller.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DraftController draftController = Get.put(DraftController());
  final SearchWidgetController searchBarController =
      Get.put(SearchWidgetController());
  final TaskController taskController = Get.put(TaskController());

  Future<void> _refreshData() async {
    // Add your refresh logic here
    print("Refreshing data...");
    await taskController.getTask();
    draftController.loadDrafts();
    print("Data refreshed!");
  }

  @override
  void initState() {
    super.initState();
    taskController.getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            SizedBox(
              // height: 30,
              width: 40,
              child: Image.asset(
                'assets/images/icon.png',
                filterQuality: FilterQuality.low,
              ),
            ),
            SizedBox(
              width: 30,
            )
          ]),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constrains) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/icon.png',
                    filterQuality: FilterQuality.low,
                    width: constrains.maxWidth * 0.5,
                  ),
                  SizedBox(height: 80),
                  CustomDrawerButton(
                    icon: Icons.settings,
                    label: "Profile Settings",
                    onPressed: () {
                      Get.to(() => Profile());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.data_usage,
                    label: "View site data",
                    onPressed: () {
                      Get.to(() => ViewSites());
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        TodoCalendar(),
                        SizedBox(height: 20),
                        const Text(
                          "Assigned tasks",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF242424),
                          ),
                        ),
                        Obx(() {
                          if (taskController.getTaskIsLoading.value) {
                            return const Center(
                              child: Text("Loading..."),
                            );
                          }
                          if (taskController.tasks.isEmpty) {
                            return const Center(
                              child: Text("No tasks available."),
                            );
                          }
                          final tasksToShow = taskController.tasks.length > 3
                              ? taskController.tasks.sublist(0, 3)
                              : taskController.tasks;

                          return Column(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: tasksToShow.length,
                                itemBuilder: (context, index) {
                                  final task = tasksToShow[index];
                                  return Stack(
                                    children: [
                                      Card(
                                        margin: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: Text(
                                            task['product'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Part number: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                      '${task['part_number']}'),
                                                ],
                                              ),
                                              Text(
                                                'Note: ${task['note']}',
                                                maxLines: 6,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                  "Due Date: ${DateTime.parse(task['due_date']).toLocal()}"),
                                              SizedBox(height: 4),
                                              Text(
                                                "${task['status']}",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            taskController.getTrailingIcon(
                                                task['status']),
                                            color: taskController
                                                .getTrailingIconColor(
                                                    task['status']),
                                          ),
                                        ),
                                      ),
                                      task['critical'] == true
                                          ? Positioned(
                                              right: 0,
                                              child: Container(
                                                margin: EdgeInsets.all(8),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Critical Task",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Icon(
                                                      Icons.warning_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  );
                                },
                              ),
                              if (taskController.tasks.length > 0)
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => AllTasks());
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Show More",
                                        style: TextStyle(
                                            color: ColorPalette.primaryColor),
                                      ),
                                      Icon(Icons.arrow_right_rounded),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                        const Text(
                          "Your inspections",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF242424),
                          ),
                        ),
                        Obx(() {
                          if (draftController.drafts.isEmpty) {
                            return SizedBox(
                              height: 100,
                              width: double.maxFinite,
                              child: Center(
                                child: const Text("No drafts available."),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: draftController.drafts.length,
                              itemBuilder: (context, index) {
                                final draft = draftController.drafts[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => DraftReport(
                                          draftIndex: index,
                                          name: draft['inspectorName'],
                                          location: draft['location'],
                                          lat: draft['latitude'],
                                          long: draft['longitude'],
                                          images: draft['images'],
                                          equipmentName: draft['equipmentName'],
                                          partNumber: draft['partNumber'],
                                          serialNumber: draft['serialNumber'],
                                          description: draft['description'],
                                          taskId: draft['taskId'],
                                          maintananceFreq:
                                              draft['maintananceFreq'],
                                        ));
                                  },
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: draft['images'].isNotEmpty &&
                                              File(draft['images'][0])
                                                  .existsSync()
                                          ? DecorationImage(
                                              image: FileImage(
                                                  File(draft['images'][0])),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: Colors.grey,
                                    ),
                                    child: Stack(children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.black.withOpacity(0.8),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${(draft['equipmentName'] == "" || draft['equipmentName'] == null) ? "Untitled" : draft['equipmentName']}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${draft['date']}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        AppFooter(),
                        const SizedBox(height: 20),
                      ],
                    ),
                    Obx(() {
                      if (searchBarController.filteredSites.isEmpty) {
                        return const SizedBox();
                      } else {
                        return Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Container(),
                          ),
                        );
                      }
                    }),
                    SearchBox(
                      isGoToReport: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
