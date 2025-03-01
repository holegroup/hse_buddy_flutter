import 'package:flutter/material.dart';

class CustomDrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final bool centerText;

  const CustomDrawerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    Key? key,
    this.backgroundColor = Colors.black,
    this.centerText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: this.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: this.centerText
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SizedBox(width: 15),
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
