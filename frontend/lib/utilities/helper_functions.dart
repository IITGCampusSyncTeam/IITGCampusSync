String convertToIST(String utcDateTime) {
  DateTime utcDate = DateTime.parse(utcDateTime).toUtc();
  DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30)); // IST offset
  return '${_formatDate(istDate)} at ${_formatTime(istDate)}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
