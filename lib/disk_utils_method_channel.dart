import 'package:flutter/services.dart';
import 'windows_disk_utils.dart';
import 'disk_utils_api.dart';

class MethodChannelDiskUtils extends DiskUtilsApi {
  static const _channel = MethodChannel('windows_disk_utils');

  @override
  Future<List<DiskInfo>> getDisks() async {
    final List disks = await _channel.invokeMethod('getDisks');
    return disks
        .map((e) => DiskInfo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
