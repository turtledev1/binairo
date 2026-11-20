const List<int> availableBoardSizes = [6, 8, 10, 12];

String formatElapsedTime(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String capitalize(String word) =>
    word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);
