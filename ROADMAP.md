# windows_disk_utils Roadmap

## ✅ Completed Features

- List all logical drives (C:, D:, etc.)
- Show drive type (fixed, removable, network, CD-ROM, RAM disk, unknown)
- Show total, free, available, and used space for each drive
- Show volume label, file system, serial number, and file system flags
- User-friendly byte formatting (KB, MB, GB, etc.)
- Sectors per cluster, bytes per sector, number of free clusters, total number of clusters
- Example app with disk/folder navigation
- Well-documented API and usage examples
- Pub.dev compliance and formatting
- Comprehensive test suite

## 🚧 Upcoming Features

- Drive letter to volume GUID/path mapping (e.g., C: → \\?\Volume{GUID}\)
- Physical disk/partition info (disk number, partition info, etc.)
- SMART data and health status
- Bus/interface type (SATA, NVMe, USB, etc.)
- WMI-based advanced disk info (where available)
- Disk performance counters (read/write speed, queue, etc.)
- More advanced file/folder operations (move, copy, permissions)
- Cross-platform (Linux/Mac) support (where possible)
- More example app features and UI improvements

---

For the latest status and to request features, see the [GitHub repository](https://github.com/Jeeva-dart/windows_disk_utils).
