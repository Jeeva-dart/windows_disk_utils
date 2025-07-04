import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:windows_disk_utils/windows_disk_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<DiskInfo> _disks = [];
  final _windowsDiskUtilsPlugin = WindowsDiskUtils();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    fetchDisks();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _windowsDiskUtilsPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> fetchDisks() async {
    try {
      final disks = await _windowsDiskUtilsPlugin.getDisks();
      if (!mounted) return;
      setState(() {
        _disks = disks;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 16),
              const Text(
                'Available Disks:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _disks.length,
                  itemBuilder: (context, index) {
                    final disk = _disks[index];
                    return Card(
                      child: ListTile(
                        title: Text(disk.name),
                        subtitle: Text(
                          'Type: ${disk.driveType ?? 'unknown'}\n'
                          'Total: ${disk.totalBytes} bytes\n'
                          '      ${disk.totalKB.toStringAsFixed(2)} KB\n'
                          '      ${disk.totalGB.toStringAsFixed(2)} GB\n'
                          'Free: ${disk.freeBytes} bytes\n'
                          '      ${disk.freeKB.toStringAsFixed(2)} KB\n'
                          '      ${disk.freeGB.toStringAsFixed(2)} GB\n'
                          'Available: ${disk.availableBytes} bytes\n'
                          '      ${disk.availableKB.toStringAsFixed(2)} KB\n'
                          '      ${disk.availableGB.toStringAsFixed(2)} GB',
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FolderViewScreen(
                                rootPath: disk.name + r'\',
                                windowsDiskUtils: _windowsDiskUtilsPlugin,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderViewScreen extends StatefulWidget {
  final String rootPath;
  final WindowsDiskUtils windowsDiskUtils;
  const FolderViewScreen({
    required this.rootPath,
    required this.windowsDiskUtils,
    super.key,
  });

  @override
  State<FolderViewScreen> createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends State<FolderViewScreen> {
  late String _currentPath;
  List<FileSystemEntityInfo> _entities = [];
  bool _loading = true;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.rootPath;
    _history.add(_currentPath);
    _loadFolder(_currentPath);
  }

  Future<void> _loadFolder(String path) async {
    setState(() {
      _loading = true;
    });
    try {
      final entities = await widget.windowsDiskUtils.listFolder(path);
      setState(() {
        _entities = entities;
        _currentPath = path;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _entities = [];
        _loading = false;
      });
    }
  }

  void _navigateToFolder(String path) {
    _history.add(path);
    _loadFolder(path);
  }

  bool get _canGoBack => _history.length > 1;

  void _goBack() {
    if (_canGoBack) {
      _history.removeLast();
      final previous = _history.last;
      _loadFolder(previous);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _entities.length,
              itemBuilder: (context, index) {
                final entity = _entities[index];
                final name = entity.path
                    .split('\\')
                    .lastWhere((e) => e.isNotEmpty, orElse: () => entity.path);
                return ListTile(
                  leading: Icon(
                    entity.isDirectory ? Icons.folder : Icons.insert_drive_file,
                  ),
                  title: Text(name),
                  subtitle: entity.isDirectory
                      ? const Text('Folder')
                      : Text('File, Size: ${entity.size ?? 0} bytes'),
                  onTap: entity.isDirectory
                      ? () => _navigateToFolder(entity.path)
                      : null,
                );
              },
            ),
    );
  }
}
