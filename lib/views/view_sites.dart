import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:hole_hse_inspection/controllers/site_controller.dart';
import 'package:hole_hse_inspection/views/site_detail.dart';

class ViewSites extends StatefulWidget {
  const ViewSites({
    super.key,
  });

  @override
  State<ViewSites> createState() => _ViewSitesState();
}

class _ViewSitesState extends State<ViewSites> {
  final SiteController siteController = Get.put(SiteController());
  final LoginController loginController = Get.put(LoginController());
  String userRole = '';
  var userData;

  @override
  void initState() {
    super.initState();
    siteController.fetchAllSites();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      final data = await loginController.getUserData();
      if (data != null) {
        setState(() {
          userData = data;
        });
        userRole = userData!['role'];
        print(userRole); // Safely access `name` after data is fetched
      } else {
        loginController.logout();
      }
    } catch (e) {
      loginController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Data'),
        actions: [
          TextButton(
            onPressed: () {
              siteController.addNewSite();
            },
            child: userRole == 'supervisor'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Add Site"),
                      SizedBox(width: 4),
                      Icon(Icons.add),
                    ],
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: Obx(() {
        if (siteController.isloadingSite.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (siteController.sites.isEmpty) {
          return const Center(
            child: Text('No sites available.'),
          );
        }

        return ListView.builder(
          itemCount: siteController.sites.length,
          itemBuilder: (context, index) {
            final site = siteController.sites[index];
            final siteId = site['_id'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() {
                return ListTile(
                  title: Text(site['site_name']),
                  subtitle: Text(site['location']),
                  trailing: siteController.loadingStates[siteId] == true
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        )
                      : Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await siteController.fetchSiteById(siteId);
                    Get.to(() => SiteDetailPage(
                          siteName: site['site_name'],
                          address: site['location'],
                          siteId: siteId,
                        ));
                  },
                );
              }),
            );
          },
        );
      }),
    );
  }
}
