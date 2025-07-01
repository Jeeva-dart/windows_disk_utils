import 'windows_disk_utils_platform_interface.dart';
import 'disk_utils_api.dart';
import 'disk_utils_method_channel.dart';

/// Main entry point for Windows Disk Utils plugin.
class WindowsDiskUtils {
  /// Returns the Windows platform version.
  Future<String?> getPlatformVersion() {
    return WindowsDiskUtilsPlatform.instance.getPlatformVersion();
  }

  /// Returns a list of available disks on the system.
  Future<List<DiskInfo>> getDisks() async {
    return WindowsDiskUtilsPlatform.instance.getDisks();
  }

  /// Lists the contents of a folder (files and subfolders).
  Future<List<FileSystemEntityInfo>> listFolder(String path) async {
    return WindowsDiskUtilsPlatform.instance.listFolder(path);
  }

  /// Creates a folder at the given path.
  Future<bool> createFolder(String path) async {
    return WindowsDiskUtilsPlatform.instance.createFolder(path);
  }

  /// Deletes a folder at the given path.
  Future<bool> deleteFolder(String path) async {
    return WindowsDiskUtilsPlatform.instance.deleteFolder(path);
  }

  /// Lists files in a folder.
  Future<List<FileSystemEntityInfo>> listFiles(String path) async {
    return WindowsDiskUtilsPlatform.instance.listFiles(path);
  }

  /// Creates a file at the given path, optionally with content.
  Future<bool> createFile(String path, [String? content]) async {
    return WindowsDiskUtilsPlatform.instance.createFile(path, content);
  }

  /// Deletes a file at the given path.
  Future<bool> deleteFile(String path) async {
    return WindowsDiskUtilsPlatform.instance.deleteFile(path);
  }

  /// Reads the contents of a file as a string.
  Future<String?> readFile(String path) async {
    return WindowsDiskUtilsPlatform.instance.readFile(path);
  }

  /// Writes content to a file at the given path.
  Future<bool> writeFile(String path, String content) async {
    return WindowsDiskUtilsPlatform.instance.writeFile(path, content);
  }

  /// Gets metadata for a file.
  Future<FileSystemEntityInfo?> getFileMetadata(String path) async {
    return WindowsDiskUtilsPlatform.instance.getFileMetadata(path);
  }

  /// Gets metadata for a folder.
  Future<FileSystemEntityInfo?> getFolderMetadata(String path) async {
    return WindowsDiskUtilsPlatform.instance.getFolderMetadata(path);
  }
}

class DiskUtilsPlatform {
  static DiskUtilsApi instance = MethodChannelDiskUtils();
}

/// Model representing disk information.
class DiskInfo {
  final String name; // e.g., "C:"
  final int totalBytes;
  final int freeBytes;
  final int availableBytes;
  final String? volumeLabel;
  final String? fileSystem;
  final int? serialNumber;
  final int? fileSystemFlags;

  DiskInfo({
    required this.name,
    required this.totalBytes,
    required this.freeBytes,
    required this.availableBytes,
    this.volumeLabel,
    this.fileSystem,
    this.serialNumber,
    this.fileSystemFlags,
  });

  double get totalKB => totalBytes / 1024;
  double get totalGB => totalBytes / (1024 * 1024 * 1024);
  double get freeKB => freeBytes / 1024;
  double get freeGB => freeBytes / (1024 * 1024 * 1024);
  double get availableKB => availableBytes / 1024;
  double get availableGB => availableBytes / (1024 * 1024 * 1024);

  factory DiskInfo.fromMap(Map<String, dynamic> map) {
    return DiskInfo(
      name: map['name'] as String,
      totalBytes: map['totalBytes'] as int,
      freeBytes: map['freeBytes'] as int,
      availableBytes: map['availableBytes'] as int,
      volumeLabel: map['volumeLabel'] as String?,
      fileSystem: map['fileSystem'] as String?,
      serialNumber: map['serialNumber'] as int?,
      fileSystemFlags: map['fileSystemFlags'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'totalBytes': totalBytes,
    'freeBytes': freeBytes,
    'availableBytes': availableBytes,
    'volumeLabel': volumeLabel,
    'fileSystem': fileSystem,
    'serialNumber': serialNumber,
    'fileSystemFlags': fileSystemFlags,
  };
}

/// Model representing file and folder metadata.
class FileSystemEntityInfo {
  final String path;
  final bool isDirectory;
  final int? size;
  final DateTime? created;
  final DateTime? modified;
  final DateTime? accessed;

  FileSystemEntityInfo({
    required this.path,
    required this.isDirectory,
    this.size,
    this.created,
    this.modified,
    this.accessed,
  });

  factory FileSystemEntityInfo.fromMap(Map<String, dynamic> map) {
    return FileSystemEntityInfo(
      path: map['path'] as String,
      isDirectory: map['isDirectory'] as bool,
      size: map['size'] as int?,
      created: map['created'] != null
          ? DateTime.tryParse(map['created'])
          : null,
      modified: map['modified'] != null
          ? DateTime.tryParse(map['modified'])
          : null,
      accessed: map['accessed'] != null
          ? DateTime.tryParse(map['accessed'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'path': path,
    'isDirectory': isDirectory,
    'size': size,
    'created': created?.toIso8601String(),
    'modified': modified?.toIso8601String(),
    'accessed': accessed?.toIso8601String(),
  };
}
