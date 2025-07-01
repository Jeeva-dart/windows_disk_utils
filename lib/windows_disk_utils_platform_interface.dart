import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'windows_disk_utils_method_channel.dart';
import 'windows_disk_utils.dart';

abstract class WindowsDiskUtilsPlatform extends PlatformInterface {
  /// Constructs a WindowsDiskUtilsPlatform.
  WindowsDiskUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowsDiskUtilsPlatform _instance = MethodChannelWindowsDiskUtils();

  /// The default instance of [WindowsDiskUtilsPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowsDiskUtils].
  static WindowsDiskUtilsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowsDiskUtilsPlatform] when
  /// they register themselves.
  static set instance(WindowsDiskUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Returns a list of available disks on the system.
  Future<List<DiskInfo>> getDisks() {
    throw UnimplementedError('getDisks() has not been implemented.');
  }

  Future<List<FileSystemEntityInfo>> listFolder(String path) {
    throw UnimplementedError('listFolder() has not been implemented.');
  }

  Future<bool> createFolder(String path) {
    throw UnimplementedError('createFolder() has not been implemented.');
  }

  Future<bool> deleteFolder(String path) {
    throw UnimplementedError('deleteFolder() has not been implemented.');
  }

  Future<List<FileSystemEntityInfo>> listFiles(String path) {
    throw UnimplementedError('listFiles() has not been implemented.');
  }

  Future<bool> createFile(String path, [String? content]) {
    throw UnimplementedError('createFile() has not been implemented.');
  }

  Future<bool> deleteFile(String path) {
    throw UnimplementedError('deleteFile() has not been implemented.');
  }

  Future<String?> readFile(String path) {
    throw UnimplementedError('readFile() has not been implemented.');
  }

  Future<bool> writeFile(String path, String content) {
    throw UnimplementedError('writeFile() has not been implemented.');
  }

  Future<FileSystemEntityInfo?> getFileMetadata(String path) {
    throw UnimplementedError('getFileMetadata() has not been implemented.');
  }

  Future<FileSystemEntityInfo?> getFolderMetadata(String path) {
    throw UnimplementedError('getFolderMetadata() has not been implemented.');
  }
}
