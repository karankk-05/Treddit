import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String backgroundImage;
  final Color backgroundColor; // Color for the curved area

  CustomAppBar({
    required this.title,
    required this.backgroundImage,
    this.backgroundColor = Colors.white, // Default color for the background
  });

  @override
  Size get preferredSize => Size.fromHeight(200); // Increased height of AppBar

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image in curved area
        Positioned.fill(
          child: ClipPath(
            clipper: BottomCurvedClipper(),
            child: Container(
              color:
                  backgroundColor, // Fill the curved area with background color
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // AppBar with rounded bottom corners
        AppBar(
          title: Text(title),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor:
              Colors.transparent, // Make AppBar background transparent
          elevation: 0, // Remove shadow for better image visibility
          toolbarHeight: 250, // Increased height of AppBar
          centerTitle: true,
        ),
      ],
    );
  }
}

class BottomCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Define control points for the cubic Bezier curve
    final Offset startPoint =
        Offset(0, size.height); // Starting point of the curve
    final Offset controlPoint1 =
        Offset(size.width * 0.2, size.height - 50); // First control point
    final Offset controlPoint2 =
        Offset(size.width * 0.4, size.height - 50); // Second control point
    final Offset controlPoint3 =
        Offset(size.width * 0.6, size.height - 50); // Third control point
    final Offset controlPoint4 =
        Offset(size.width * 0.8, size.height - 50); // Fourth control point
    final Offset endPoint =
        Offset(size.width, size.height - 100); // Ending point of the curve

    // Draw the path
    path.lineTo(
        startPoint.dx, startPoint.dy); // Start from the bottom left corner
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy, // First control point
      controlPoint2.dx, controlPoint2.dy, // Second control point
      controlPoint3.dx, controlPoint3.dy, // Third control point
    );
    path.cubicTo(
        controlPoint4.dx,
        controlPoint4.dy, // Fourth control point
        endPoint.dx,
        endPoint.dy, // Ending point
        endPoint.dx,
        endPoint.dy // Ending point for smooth close
        );
    path.lineTo(size.width, 0); // Draw line to the top right corner
    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
