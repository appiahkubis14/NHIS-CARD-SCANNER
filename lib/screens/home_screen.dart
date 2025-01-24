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
  var _script = TextRecognitionScript.latin;
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
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
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        // Positioned(
        //     top: 30,
        //     left: 100,
        //     right: 100,
        //     child: Row(
        //       children: [
        //         Spacer(),
        //         Container(
        //             decoration: BoxDecoration(
        //               color: Colors.black54,
        //               borderRadius: BorderRadius.circular(10.0),
        //             ),
        //             child: Padding(
        //               padding: const EdgeInsets.all(4.0),
        //               child: _buildDropdown(),
        //             )),
        //         Spacer(),
        //       ],
        //     )),
      ]),
    );
  }

  // Widget _buildDropdown() => DropdownButton<TextRecognitionScript>(
  //       value: _script,
  //       icon: const Icon(Icons.arrow_downward),
  //       elevation: 16,
  //       style: const TextStyle(color: Colors.blue),
  //       underline: Container(
  //         height: 2,
  //         color: Colors.blue,
  //       ),
  //       onChanged: (TextRecognitionScript? script) {
  //         if (script != null) {
  //           setState(() {
  //             _script = script;
  //             _textRecognizer.close();
  //             _textRecognizer = TextRecognizer(script: _script);
  //           });
  //         }
  //       },
  //       items: TextRecognitionScript.values
  //           .map<DropdownMenuItem<TextRecognitionScript>>((script) {
  //         return DropdownMenuItem<TextRecognitionScript>(
  //           value: script,
  //           child: Text(script.name),
  //         );
  //       }).toList(),
  //     );
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = TextRecognizerPainter(
        recognizedText,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // Convert recognized text blocks to a list of strings
      List<String> recognizedTextList =
          recognizedText.blocks.map((e) => e.text.toUpperCase()).toList();

      // Combine the list elements into a single string and display it
      _text = 'Recognized text:\n\n${recognizedTextList.join('\n')}';
      Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecognizedTextDisplay(
        recognizedTextList: recognizedText.blocks.map((e) => e.text.toUpperCase()).toList(),
      ),
    ),
  );
      // Print both the list and the combined string
      print("Recognized Text List: $recognizedTextList");
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

  RecognizedTextDisplay({required this.recognizedTextList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognized Text Display',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        backgroundColor: Colors.greenAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: recognizedTextList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: TextEditingController(
                  text: recognizedTextList[index],
                ),
                readOnly: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Field ${index + 1}',
                  labelStyle: TextStyle(
                    color: Colors.greenAccent.shade700,
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
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12.0),
                  //   borderSide: BorderSide(
                  //     color: Colors.greenAccent.shade700,
                  //     width: 2.0,
                  //   ),
                  // ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

