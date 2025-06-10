import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vexa_app/utils/api_service.dart'; // Import ApiService
import 'result_screen.dart'; // Import ResultScreen (will be created next)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService(); // Instantiate ApiService
  bool _isDetecting = false;
  String? _errorMessage;

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
          _errorMessage = null; // Clear previous errors
        });
        print("Video selected: ${video.path}");
      } else {
        print("No video selected.");
      }
    } catch (e) {
      print("Error picking video: $e");
      setState(() {
        _errorMessage = "Error picking video: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking video: $e")),
      );
    }
  }

  Future<void> _detectDeepfake() async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a video first.")),
      );
      return;
    }

    setState(() {
      _isDetecting = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      print("Sending video for detection: ${_selectedVideo!.path}");
      final Map<String, dynamic> result = await _apiService.detectDeepfake(_selectedVideo!);
      print("API call successful. Result: $result");

      // Navigate to ResultScreen with the result
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(apiResult: result),
        ),
      );

    } catch (e) {
      print("API call failed: $e");
      setState(() {
        _errorMessage = "Detection failed: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Detection failed: $e")),
      );
    } finally {
      // Ensure loading indicator stops even if navigation fails or isn't immediate
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  Widget _buildUploadArea() {
    const Color primaryColor = Color(0xFF0052CC);
    const Color hintColor = Colors.grey;

    if (_selectedVideo == null) {
      return Container(
        // ... (Upload area code remains the same)
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 50,
              color: primaryColor,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Drop video here or ',
                  style: TextStyle(color: hintColor, fontSize: 16),
                ),
                GestureDetector(
                  onTap: _pickVideo,
                  child: const Text(
                    'Browse video',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Show selected video information
      return Container(
        // ... (Selected video preview code remains the same)
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.video_file_outlined, size: 50, color: primaryColor),
            const SizedBox(height: 10),
            Text(
              _selectedVideo!.path.split('/').last,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            FutureBuilder<int>(
              future: _selectedVideo!.length(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  final sizeInMb = snapshot.data! / (1024 * 1024);
                  return Text(
                    '${sizeInMb.toStringAsFixed(1)} MB',
                    style: const TextStyle(fontSize: 12, color: hintColor),
                  );
                } else {
                  return const Text('Calculating size...', style: TextStyle(fontSize: 12, color: hintColor));
                }
              },
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Replace video'),
              onPressed: _pickVideo,
              style: TextButton.styleFrom(
                 foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF0F4F8);
    const Color primaryColor = Color(0xFF0052CC);
    const Color textColor = Colors.black87;
    const Color buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // ... (AppBar code remains the same)
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textColor),
          onPressed: () {
            print("Menu button clicked");
            // TODO: Implement drawer or menu functionality
          },
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.star_border, color: primaryColor, size: 18),
            label: const Text(
              'Upgrade',
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              print("Upgrade button clicked");
              // TODO: Handle upgrade action
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            SvgPicture.asset(
              'assets/images/BLACK.svg',
              height: 60,
            ),
            const SizedBox(height: 10),
            const Text(
              'The Guardian Against Digital Lies',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildUploadArea(),
            // Display error message if any
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton.icon(
                // ... (Button code remains the same, using _isDetecting)
                icon: _isDetecting
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: buttonTextColor,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.shield_outlined, color: buttonTextColor),
                label: Text(
                  _isDetecting ? 'Detecting...' : 'Detect Deepfake',
                  style: const TextStyle(fontSize: 16, color: buttonTextColor),
                ),
                onPressed: _isDetecting ? null : _detectDeepfake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  disabledBackgroundColor: primaryColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

