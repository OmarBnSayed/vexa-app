import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';

import 'upload_interface.dart';
import 'upload_web.dart' if (dart.library.io) 'upload_stub.dart';
import 'result_screen.dart';

class VideoUploadScreen extends StatefulWidget {
  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final VideoPicker picker = UploadHandler();
  PickedVideo? _pickedVideo;
  String? _videoUrl;
  VideoPlayerController? _controller;
  bool _isDetecting = false;

  Future<void> _pickVideo() async {
    final result = await picker.pickVideo();
    if (result != null) {
      setState(() {
        _pickedVideo = result;
        _videoUrl = null;
        _controller?.dispose();
        _controller = null;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_pickedVideo == null) return;

    final uri = Uri.parse('http://127.0.0.1:8000/upload-video');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _pickedVideo!.video,
        filename: _pickedVideo!.name,
      ));
    } else {
      final file = _pickedVideo!.video as dynamic; // File from dart:io
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      final fullUrl = 'http://127.0.0.1:8000' + data['video_url'];
      setState(() {
        _videoUrl = fullUrl;
        _controller = VideoPlayerController.network(_videoUrl!)
          ..initialize().then((_) => setState(() {}));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed')),
      );
    }
  }

  Future<void> _runDetection() async {
  if (_videoUrl == null) return;

  setState(() {
    _isDetecting = true;
  });

  try {
    final uri = Uri.parse('http://127.0.0.1:8000/detect');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'video_url': _videoUrl}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(apiResult: result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detection failed')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }

  setState(() {
    _isDetecting = false;
  });
}


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload & Preview Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickVideo, child: Text('Pick Video')),
            if (_pickedVideo != null) Text('Selected: ${_pickedVideo!.name}'),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _uploadVideo, child: Text('Upload')),
            SizedBox(height: 20),
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            if (_controller != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            if (_videoUrl != null)
              Column(
                children: [
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isDetecting ? null : _runDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isDetecting ? 'Detecting...' : 'Detect',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
