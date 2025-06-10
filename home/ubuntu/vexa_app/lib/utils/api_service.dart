import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Replace with the actual URL where the FastAPI backend is running
  // If running locally for testing, might be like 'http://127.0.0.1:8000'
  // If deployed, use the deployment URL.
  static const String _baseUrl = 'http://127.0.0.1:8000'; // Placeholder URL

  Future<Map<String, dynamic>> detectDeepfake(File videoFile) async {
    // Define the endpoint based on your FastAPI main.py
    final Uri uri = Uri.parse('$_baseUrl/predict/'); // Assuming '/predict/' is the endpoint

    try {
      // Create a multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add the video file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This key must match the parameter name in your FastAPI endpoint (UploadFile = File(...))
          videoFile.path,
          // You might need to specify the content type explicitly
          // contentType: MediaType('video', 'mp4'), // Adjust based on expected video types
        ),
      );

      print('Sending request to $uri');
      final streamedResponse = await request.send();

      print('Received response status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Successfully received response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print('API Response: $responseBody');
        return responseBody;
      } else {
        // Handle server errors
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to detect deepfake. Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error sending request: $e');
      throw Exception('Failed to connect to the server. Error: $e');
    }
  }
}

