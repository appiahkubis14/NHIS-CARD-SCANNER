// ignore_for_file: deprecated_member_use

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
class CardScannerService {
  static CameraController? _cameraController;
  static bool _isCameraInitialized = false;

  // Scanning the card and extracting details
  static Future<Map<String, String>?> scanCard() async {
    if (!_isCameraInitialized) {
      // Initialize the camera
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(firstCamera, ResolutionPreset.high);

      await _cameraController!.initialize();
      _isCameraInitialized = true;
    }

    // Capture the image
    final image = await _cameraController!.takePicture();
    final inputImage = InputImage.fromFile(File(image.path));

    // Perform OCR using Google ML Kit
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;

    // Parse the extracted text to extract card details
    return _parseCardDetails(extractedText);
  }

  // Parsing the card details from the extracted OCR text
  static Map<String, String>? _parseCardDetails(String text) {
    Map<String, String> cardDetails = {};
    final lines = text.split('\n');

    // Iterating through the text lines to extract details
    for (var line in lines) {
      // Checking for Name
      if (line.toLowerCase().contains('name') && !cardDetails.containsKey('name')) {
        cardDetails['name'] = _extractDetail(line);
      }

      // Checking for Date of Birth (DOB)
      if (line.toLowerCase().contains('dob') && !cardDetails.containsKey('dob')) {
        cardDetails['dob'] = _extractDetail(line);
      }

      // Checking for Membership No.
      if (line.toLowerCase().contains('membership') && !cardDetails.containsKey('membership_no')) {
        cardDetails['membership_no'] = _extractDetail(line);
      }

      // Checking for Date of Issue
      if (line.toLowerCase().contains('issue') && !cardDetails.containsKey('date_of_issue')) {
        cardDetails['date_of_issue'] = _extractDetail(line);
      }

      // Checking for Sex (Gender)
      if (line.toLowerCase().contains('sex') && !cardDetails.containsKey('sex')) {
        cardDetails['sex'] = _extractDetail(line);
      }

      // Checking for Expiry Date
      if (line.toLowerCase().contains('expiry') && !cardDetails.containsKey('expiry_date')) {
        cardDetails['expiry_date'] = _extractDetail(line);
      }
    }

    // Return the card details if not empty
    return cardDetails.isNotEmpty ? cardDetails : null;
  }

  // Helper function to clean and extract the detail from a line
  static String _extractDetail(String line) {
    // Trim any unwanted spaces or non-alphanumeric characters
    return line.replaceAll(RegExp(r'[^a-zA-Z0-9\s,:/-]'), '').trim();
  }

  // Disposing the camera controller properly
  static Future<void> disposeCamera() async {
    if (_isCameraInitialized) {
      await _cameraController?.dispose();
      _isCameraInitialized = false;
    }
  }
}
