import 'package:flutter_test/flutter_test.dart';
import 'package:windows_disk_utils/windows_disk_utils.dart';
import 'package:windows_disk_utils/windows_disk_utils_platform_interface.dart';
import 'package:windows_disk_utils/windows_disk_utils_method_channel.dart';
import 'package:windows_disk_utils/disk_size_formatter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowsDiskUtilsPlatform
    with MockPlatformInterfaceMixin
    implements WindowsDiskUtilsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<DiskInfo>> getDisks() => Future.value([
    DiskInfo(
      name: 'C:',
      totalBytes: 104857600,
      freeBytes: 52428800,
      availableBytes: 52428800,
    ),
  ]);

  @override
  Future<List<FileSystemEntityInfo>> listFolder(String path) => Future.value([
    FileSystemEntityInfo(path: '${path}folder1', isDirectory: true, size: null),
    FileSystemEntityInfo(
      path: '${path}file1.txt',
      isDirectory: false,
      size: 1234,
    ),
  ]);

  @override
  Future<bool> createFile(String path, [String? content]) {
    // TODO: implement createFile
    throw UnimplementedError();
  }

  @override
  Future<bool> createFolder(String path) {
    // TODO: implement createFolder
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteFile(String path) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteFolder(String path) {
    // TODO: implement deleteFolder
    throw UnimplementedError();
  }

  @override
  Future<FileSystemEntityInfo?> getFileMetadata(String path) {
    // TODO: implement getFileMetadata
    throw UnimplementedError();
  }

  @override
  Future<FileSystemEntityInfo?> getFolderMetadata(String path) {
    // TODO: implement getFolderMetadata
    throw UnimplementedError();
  }

  @override
  Future<List<FileSystemEntityInfo>> listFiles(String path) {
    // TODO: implement listFiles
    throw UnimplementedError();
  }

  @override
  Future<String?> readFile(String path) {
    // TODO: implement readFile
    throw UnimplementedError();
  }

  @override
  Future<bool> writeFile(String path, String content) {
    // TODO: implement writeFile
    throw UnimplementedError();
  }
}

void main() {
  final WindowsDiskUtilsPlatform initialPlatform =
      WindowsDiskUtilsPlatform.instance;

  test('$MethodChannelWindowsDiskUtils is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowsDiskUtils>());
  });

  test('getPlatformVersion', () async {
    WindowsDiskUtils windowsDiskUtilsPlugin = WindowsDiskUtils();
    MockWindowsDiskUtilsPlatform fakePlatform = MockWindowsDiskUtilsPlatform();
    WindowsDiskUtilsPlatform.instance = fakePlatform;

    expect(await windowsDiskUtilsPlugin.getPlatformVersion(), '42');
  });

  test('getDisks returns mock disk', () async {
    WindowsDiskUtils windowsDiskUtilsPlugin = WindowsDiskUtils();
    MockWindowsDiskUtilsPlatform fakePlatform = MockWindowsDiskUtilsPlatform();
    WindowsDiskUtilsPlatform.instance = fakePlatform;
    final disks = await windowsDiskUtilsPlugin.getDisks();
    expect(disks, isNotEmpty);
    expect(disks.first.name, 'C:');
    expect(disks.first.totalBytes, 104857600);
  });

  test('listFolder returns mock folder and file', () async {
    WindowsDiskUtils windowsDiskUtilsPlugin = WindowsDiskUtils();
    MockWindowsDiskUtilsPlatform fakePlatform = MockWindowsDiskUtilsPlatform();
    WindowsDiskUtilsPlatform.instance = fakePlatform;
    final entities = await windowsDiskUtilsPlugin.listFolder('C:\\');
    expect(entities, isNotEmpty);
    expect(entities.first.isDirectory, true);
    expect(entities.last.isDirectory, false);
    expect(entities.last.size, 1234);
  });

  test('DiskSizeFormatter formats bytes correctly', () {
    expect(DiskSizeFormatter.formatBytes(1536), '1.54 KB');
    expect(DiskSizeFormatter.formatBytes(1536, binary: true), '1.50 KiB');
    expect(DiskSizeFormatter.formatBytes(1048576), '1.05 MB');
    expect(DiskSizeFormatter.formatBytes(1048576, binary: true), '1.00 MiB');
  });
}
