import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'windows_disk_utils_platform_interface.dart';
import 'windows_disk_utils.dart';

/// An implementation of [WindowsDiskUtilsPlatform] that uses method channels.
///
/// This class forwards all API calls from Dart to the native Windows implementation
/// via a platform channel. It supports disk, folder, and file operations.
///
/// Example usage:
/// ```dart
/// final diskUtils = WindowsDiskUtils();
/// final disks = await diskUtils.getDisks();
/// final folderContents = await diskUtils.listFolder('C:\\');
/// final fileContent = await diskUtils.readFile('C:\\myfile.txt');
/// ```
class MethodChannelWindowsDiskUtils extends WindowsDiskUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('windows_disk_utils');

  /// Returns the Windows platform version as a string.
  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Returns a list of available disks on the system.
  @override
  Future<List<DiskInfo>> getDisks() async {
    final List disks = await methodChannel.invokeMethod('getDisks');
    return disks
        .map((e) => DiskInfo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Lists the contents of a folder (files and subfolders).
  @override
  Future<List<FileSystemEntityInfo>> listFolder(String path) async {
    final List entities = await methodChannel.invokeMethod('listFolder', {'path': path});
    return entities.map((e) => FileSystemEntityInfo.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  /// Creates a folder at the given path.
  @override
  Future<bool> createFolder(String path) async {
    return await methodChannel.invokeMethod('createFolder', {'path': path});
  }

  /// Deletes a folder at the given path.
  @override
  Future<bool> deleteFolder(String path) async {
    return await methodChannel.invokeMethod('deleteFolder', {'path': path});
  }

  /// Lists files in a folder.
  @override
  Future<List<FileSystemEntityInfo>> listFiles(String path) async {
    final List entities = await methodChannel.invokeMethod('listFiles', {'path': path});
    return entities.map((e) => FileSystemEntityInfo.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  /// Creates a file at the given path, optionally with content.
  @override
  Future<bool> createFile(String path, [String? content]) async {
    return await methodChannel.invokeMethod('createFile', {'path': path, 'content': content});
  }

  /// Deletes a file at the given path.
  @override
  Future<bool> deleteFile(String path) async {
    return await methodChannel.invokeMethod('deleteFile', {'path': path});
  }

  /// Reads the contents of a file as a string.
  @override
  Future<String?> readFile(String path) async {
    return await methodChannel.invokeMethod('readFile', {'path': path});
  }

  /// Writes content to a file at the given path.
  @override
  Future<bool> writeFile(String path, String content) async {
    return await methodChannel.invokeMethod('writeFile', {'path': path, 'content': content});
  }

  /// Gets metadata for a file.
  @override
  Future<FileSystemEntityInfo?> getFileMetadata(String path) async {
    final map = await methodChannel.invokeMethod('getFileMetadata', {'path': path});
    if (map == null) return null;
    return FileSystemEntityInfo.fromMap(Map<String, dynamic>.from(map));
  }

  /// Gets metadata for a folder.
  @override
  Future<FileSystemEntityInfo?> getFolderMetadata(String path) async {
    final map = await methodChannel.invokeMethod('getFolderMetadata', {'path': path});
    if (map == null) return null;
    return FileSystemEntityInfo.fromMap(Map<String, dynamic>.from(map));
  }
}
