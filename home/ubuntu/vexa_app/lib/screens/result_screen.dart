import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> apiResult;

  const ResultScreen({super.key, required this.apiResult});

  @override
  Widget build(BuildContext context) {
    // Extract data from the API result, provide defaults if keys are missing
    final String verdict = apiResult['final_verdict'] ?? 'Unknown';
    final double confidence = (apiResult['confidence_level'] ?? 0.0).toDouble();
    // Assuming the API might return other details shown in the PDF like model predictions
    // final double xceptionProb = (apiResult['xception_prob'] ?? 0.0).toDouble();
    // final double capsuleProb = (apiResult['capsule_prob'] ?? 0.0).toDouble();
    // final double dspFwaProb = (apiResult['dsp_fwa_prob'] ?? 0.0).toDouble();

    // Determine colors and icons based on the verdict
    final bool isFake = verdict.toUpperCase() == 'FAKE';
    final Color resultColor = isFake ? Colors.redAccent : Colors.green;
    final IconData resultIcon = isFake ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    final String resultText = isFake ? 'Deepfake Detected' : 'Authentic Video';

    const Color backgroundColor = Color(0xFFF0F4F8);
    const Color primaryColor = Color(0xFF0052CC);
    const Color textColor = Colors.black87;
    const Color cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(), // Go back to HomeScreen
        ),
        title: const Text('Detection Result', style: TextStyle(color: textColor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Result Summary Card
            Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(resultIcon, size: 60, color: resultColor),
                    const SizedBox(height: 15),
                    Text(
                      resultText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Confidence Level: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Detailed Analysis Section (Based on PDF page 4)
            const Text(
              'Detailed Analysis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 15),
            Card(
              color: cardColor,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Example: Displaying individual model predictions if available
                    // _buildDetailRow('Xception Model:', '${(xceptionProb * 100).toStringAsFixed(1)}% Fake'),
                    // _buildDetailRow('Capsule Network:', '${(capsuleProb * 100).toStringAsFixed(1)}% Fake'),
                    // _buildDetailRow('DSP-FWA Model:', '${(dspFwaProb * 100).toStringAsFixed(1)}% Fake'),
                    
                    // Displaying raw API result for now
                    Text(
                      apiResult.toString(), // Display raw map for debugging/info
                      style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Action Button (e.g., Scan another video)
            ElevatedButton(
              onPressed: () {
                // Navigate back to home screen to allow scanning another video
                Navigator.of(context).pop(); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Scan Another Video',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying detail rows (optional)
  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
  //         Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
  //       ],
  //     ),
  //   );
  // }
}

