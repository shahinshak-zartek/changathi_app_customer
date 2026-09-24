class DurationFormatter {
  static String format(int seconds) {
    if (seconds < 60) {
      return "$seconds sec";
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (remainingSeconds == 0) {
      return "$minutes min";
    }

    return "$minutes min $remainingSeconds sec";
  }
}