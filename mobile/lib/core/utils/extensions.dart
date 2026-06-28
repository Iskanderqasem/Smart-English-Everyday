import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize)
      .join(' ');

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  int get wordCount => trim().isEmpty ? 0 : trim().split(RegExp(r'\s+')).length;

  String get removeExtraSpaces => trim().replaceAll(RegExp(r'\s+'), ' ');

  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => !isBlank;
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  bool get isNotNullOrBlank => !isNullOrBlank;
  String get orEmpty => this ?? '';
}

extension DateTimeExtensions on DateTime {
  String get formattedDate => DateFormat('MMM dd, yyyy').format(this);

  String get formattedTime => DateFormat('hh:mm a').format(this);

  String get formattedDateTime => DateFormat('MMM dd, yyyy • hh:mm a').format(this);

  String get shortDate => DateFormat('MMM dd').format(this);

  String get monthYear => DateFormat('MMMM yyyy').format(this);

  String get dayName => DateFormat('EEEE').format(this);

  String get shortDayName => DateFormat('EEE').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formattedDate;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isTablet => MediaQuery.of(this).size.width >= 768;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void hideKeyboard() => FocusScope.of(this).unfocus();

  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void pop<T>([T? result]) => Navigator.of(this).pop(result);
}

extension NumExtensions on num {
  String get withCommas => NumberFormat('#,##0').format(this);

  String get compactFormat {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toString();
  }

  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
}

extension DurationExtensions on Duration {
  String get formatted {
    if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    }
    if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    }
    return '${inSeconds}s';
  }

  String get mmss {
    final m = inMinutes.toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}
