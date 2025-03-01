import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _sendEmail() async {
    Uri emailUri = Uri(
      scheme: 'intent',
      path: 'mailto:darryl@holegroup.com',
      queryParameters: {
        'android.intent.data':
            Uri.encodeComponent('mailto:darryl@holegroup.com')
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Mailto not supported, so launch in browser
        final Uri browserUri = Uri.parse(
            'https://mail.google.com/mail/u/0/?fs=1&to=darryl@holegroup.com');
        await launchUrl(browserUri);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to launch email app: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        image: DecorationImage(
          fit: BoxFit.cover,
          opacity: 0.5,
          image: AssetImage(
            'assets/images/icon.png',
          ),
        ),
      ),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HSE Buddy",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Write a Feedback\ndarryl@holegroup.com",
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _sendEmail,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Email us"),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_outward),
                  ],
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}
