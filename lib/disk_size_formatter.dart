import 'dart:math';

/// Utility functions for formatting byte sizes into human-readable strings.
///
/// Example usage:
/// ```dart
/// import 'package:windows_disk_utils/disk_size_formatter.dart';
///
/// void main() {
///   print(DiskSizeFormatter.formatBytes(1536)); // 1.54 KB
///   print(DiskSizeFormatter.formatBytes(1536, binary: true)); // 1.50 KiB
///   print(DiskSizeFormatter.formatBytes(1048576)); // 1.05 MB
///   print(DiskSizeFormatter.formatBytes(1048576, binary: true)); // 1.00 MiB
/// }
/// ```
class DiskSizeFormatter {
  /// Converts a byte value to a human-readable string (e.g., KB, MB, GB).
  ///
  /// [bytes]: The size in bytes.
  /// [decimals]: Number of decimal places to show (default: 2).
  /// [binary]: If true, uses binary units (KiB, MiB, GiB). If false, uses SI units (KB, MB, GB).
  ///
  /// Returns a formatted string, e.g. '1.50 KiB' or '1.54 KB'.
  static String formatBytes(
    int bytes, {
    int decimals = 2,
    bool binary = false,
  }) {
    if (bytes < 0) return '0 B';
    const suffixesSI = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
    const suffixesBinary = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB'];
    final k = binary ? 1024 : 1000;
    final suffixes = binary ? suffixesBinary : suffixesSI;
    if (bytes < k) return '$bytes B';
    int i = (bytes > 0) ? (log(bytes) / log(k)).floor() : 0;
    double size = bytes / pow(k, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
