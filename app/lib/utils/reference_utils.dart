// In lib/utils/reference_utils.dart
String generateReferenceNumber() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final random = now.microsecond % 1000;
  return "#SF$year$month$day$random";
}
