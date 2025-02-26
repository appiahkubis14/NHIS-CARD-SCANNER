// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:nhis_card_scanner/screens/detect_view.dart';
import 'package:nhis_card_scanner/utils/text_detector_painter.dart';

// import 'painters/text_detector_painter.dart';

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final _script = TextRecognitionScript.latin;
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'ID CARD SCANNER',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        
      ]),
    );
  }

  
  Future<void> _processImage(InputImage inputImage) async {
  if (!_canProcess) return;
  if (_isBusy) return;
  _isBusy = true;

  setState(() {
    _text = '';
  });

  final recognizedText = await _textRecognizer.processImage(inputImage);

  if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
    final painter = TextRecognizerPainter(
      recognizedText,
      inputImage.metadata!.size,
      inputImage.metadata!.rotation,
      _cameraLensDirection,
    );
    _customPaint = CustomPaint(painter: painter);
  } else {
    List<String> recognizedTextList =
        recognizedText.blocks.map((e) => e.text.toUpperCase()).toList();

    List<String> processedList = [];
    for (int i = 0; i < recognizedTextList.length; i++) {
      if (recognizedTextList[i] == "NAME:" ||
          recognizedTextList[i] == "SEX:" ||
          recognizedTextList[i] == "DATE OF BIRTH." ||
          recognizedTextList[i] == "DATE OF ISSUE:" ||
          recognizedTextList[i] == "MEMBERSHIP NO.") { // New Condition
        if (recognizedTextList[i] == "SEX:" && i + 1 < recognizedTextList.length) {
          processedList.add('${recognizedTextList[i]} ${recognizedTextList[i + 1]}');
          i++;
        } else if (recognizedTextList[i] == "DATE OF BIRTH." && i + 1 < recognizedTextList.length) {
          processedList.add('${recognizedTextList[i]} ${recognizedTextList[i + 1]}');
          i++;
        } else if (recognizedTextList[i] == "DATE OF ISSUE:" && i + 1 < recognizedTextList.length) {
          processedList.add('${recognizedTextList[i]} ${recognizedTextList[i + 1]}');
          i++;
        } else if (recognizedTextList[i] == "MEMBERSHIP NO." && i + 1 < recognizedTextList.length) { // Handle MEMBERSHIP NO.
          processedList.add('${recognizedTextList[i]} ${recognizedTextList[i + 1]}');
          i++;
        } else {
          processedList.add('${recognizedTextList[i]} ${recognizedTextList[i + 1]}');
          i++;
        }
      } else {
        processedList.add(recognizedTextList[i]);
      }
    }
    _text = 'YOUR CARD INFORMATION:\n\n${processedList.join('\n')}';

    // Navigate to the display page with the processed list
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecognizedTextDisplay(
          recognizedTextList: processedList,
        ),
      ),
    );

    

    // Print the processed list and combined string
    print("Processed Recognized Text List: $processedList");
    print("Combined Recognized Text:\n$_text");

    _customPaint = null;
  }

  _isBusy = false;
  if (mounted) {
    setState(() {});
  }
}



}

class RecognizedTextDisplay extends StatelessWidget {
  final List<String> recognizedTextList;

  const RecognizedTextDisplay({super.key, required this.recognizedTextList});

  void _syncDataToDatabase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecognizedTextDisplay(
          recognizedTextList: recognizedTextList,
        ),
      ),
    );
    print("Syncing data to the database...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 158, 157, 157),
      appBar: AppBar(
        title: const Text(
          'USER NHIS CARD DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.greenAccent.shade700,
        actions: [
              IconButton(
                icon: Icon(
                   Icons.sync_outlined,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecognizedTextDisplay(recognizedTextList: recognizedTextList))),
              ),
            ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: recognizedTextList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: IntrinsicHeight(
                      child: TextField(
                        controller: TextEditingController(
                          text: recognizedTextList[index],
                        ),
                        readOnly: true,
                        maxLines: null, // Allows the TextField to expand to fit all text
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Make the text bold
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          // labelText: 'Field ${index + 1}',
                          labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 2, 26, 8),
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: Colors.greenAccent.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.text_fields,
                            color: Colors.greenAccent.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Sync Button
            // Padding(
            //   padding: const EdgeInsets.only(top: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () => _syncDataToDatabase(context),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.greenAccent.shade700, // Button background color
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            //     ),
            //     child: const Text(
            //       'Sync NHIS Card Info',
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
