// utils/ocr_helper.dart
import 'package:intl/intl.dart';

class OCRHelper {
  static String formatDate(String rawDate) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }
}
