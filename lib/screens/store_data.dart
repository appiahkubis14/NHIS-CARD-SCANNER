import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecognizedTextDisplay extends StatefulWidget {
  final List<String> recognizedTextList;

  const RecognizedTextDisplay({super.key, required this.recognizedTextList});

  @override
  _RecognizedTextDisplayState createState() => _RecognizedTextDisplayState();
}

class _RecognizedTextDisplayState extends State<RecognizedTextDisplay> {
  late List<String> storedTextList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> loadedTextList = prefs.getStringList('recognizedText') ?? [];
    setState(() {
      storedTextList = loadedTextList.isEmpty ? widget.recognizedTextList : loadedTextList;
    });
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recognizedText', storedTextList);
  }

  // Sync data to the database (or local storage)
  void _syncDataToDatabase() {
    // Implement your sync logic here, e.g., sending data to the database
    print("Syncing data to the database...");
    

    // Save data locally after sync
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'USER NHIS CARD DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.greenAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: storedTextList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: IntrinsicHeight(
                      child: TextField(
                        controller: TextEditingController(
                          text: storedTextList[index],
                        ),
                        readOnly: true,
                        maxLines: null, // Allows the TextField to expand to fit all text
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Make the text bold
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Sync Button
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _syncDataToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700, // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text(
                  'Sync Data to Database',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
