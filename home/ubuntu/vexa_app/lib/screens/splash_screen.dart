import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'home_screen.dart'; // Assuming home_screen.dart will be created

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3), // Adjust duration as needed
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(), // Navigate to HomeScreen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define background color based on UI design (assuming a light theme from PDF)
    const Color backgroundColor = Color(0xFFF0F4F8); // Example color, adjust based on exact UI
    const Color logoColor = Color(0xFF0052CC); // Example color for Vexa logo text if needed

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Use SVG logo if available and appropriate
            SvgPicture.asset(
              'assets/images/BLACK.svg', // Use the appropriate logo file
              height: 100, // Adjust size as needed
              // Optionally specify color if the SVG is monochrome and needs coloring
              // colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 20),
            // Add tagline if present on splash screen design
            // const Text(
            //   'The Guardian Against Digital Lies',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey, // Adjust color
            //   ),
            // ),
            // Optional: Add a loading indicator
            // const SizedBox(height: 30),
            // const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

