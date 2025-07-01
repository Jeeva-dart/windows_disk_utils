import 'windows_disk_utils.dart';

abstract class DiskUtilsApi {
  Future<List<DiskInfo>> getDisks();
}
