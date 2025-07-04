# windows_disk_utils

A Flutter plugin for Windows that provides comprehensive disk, folder, and file utilities. Easily retrieve disk information, list folders and files, perform file operations, and format byte sizes for display.

## Features
- List all disks/partitions with detailed info (including drive type, space info, sectors/cluster, bytes/sector, clusters)
- List folder contents (files and subfolders)
- Create, rename, and delete files/folders
- Read and write file contents
- Get file/folder metadata (size, timestamps, etc.)
- Format byte sizes to human-readable strings (KB, MB, GB, etc.)

## Installation
Add to your `pubspec.yaml`:
```yaml
dependencies:
  windows_disk_utils: ^<latest_version>
```

## Usage Example
```dart
import 'package:windows_disk_utils/windows_disk_utils.dart';
import 'package:windows_disk_utils/disk_size_formatter.dart';

void main() async {
  final diskUtils = WindowsDiskUtils();

  // List all disks
  final disks = await diskUtils.getDisks();
  for (final disk in disks) {
    print('Drive: ${disk.name}');
    print('  Type: ${disk.driveType}');
    print('  Total: ${DiskSizeFormatter.formatBytes(disk.totalBytes)}');
    print('  Free:  ${DiskSizeFormatter.formatBytes(disk.freeBytes)}');
    print('  Used:  ${DiskSizeFormatter.formatBytes(disk.usedBytes ?? 0)}');
    print('  Sectors/Cluster: ${disk.sectorsPerCluster}');
    print('  Bytes/Sector: ${disk.bytesPerSector}');
    print('  Free Clusters: ${disk.numberOfFreeClusters}');
    print('  Total Clusters: ${disk.totalNumberOfClusters}');
    print('  Label: ${disk.volumeLabel}');
    print('  File System: ${disk.fileSystem}');
  }

  // List contents of C:\
  final folderContents = await diskUtils.listFolder('C:\\');
  for (final entity in folderContents) {
    print('${entity.isDirectory ? 'Folder' : 'File'}: ${entity.path}');
    if (!entity.isDirectory) {
      print('  Size: ${DiskSizeFormatter.formatBytes(entity.size ?? 0)}');
    }
  }

  // Read a file
  final content = await diskUtils.readFile('C:\\myfile.txt');
  print('File content: $content');

  // Write a file
  await diskUtils.writeFile('C:\\myfile.txt', 'Hello, world!');
}
```

## Formatting Byte Sizes
```dart
import 'package:windows_disk_utils/disk_size_formatter.dart';

void main() {
  print(DiskSizeFormatter.formatBytes(1536)); // 1.54 KB
  print(DiskSizeFormatter.formatBytes(1536, binary: true)); // 1.50 KiB
  print(DiskSizeFormatter.formatBytes(1048576)); // 1.05 MB
  print(DiskSizeFormatter.formatBytes(1048576, binary: true)); // 1.00 MiB
}
```

## Platform Support
- Windows (native implementation)

## License
[MIT](LICENSE)

