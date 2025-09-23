import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadService {
  static final Dio _dio = Dio();

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  static Future<File?> downloadFile({
    required String url,
    required String fileName,
    required Function(double progress) onProgress,
    required Function(String message) onError,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        onError('Storage permission denied');
        return null;
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        onError('Could not access storage directory');
        return null;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Download file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      return file;
    } catch (e) {
      onError('Download failed: ${e.toString()}');
      return null;
    }
  }

  static Future<void> shareFile(File file, String fileName) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this lesson: $fileName',
        subject: 'Lesson: $fileName',
      );
    } catch (e) {
      throw Exception('Failed to share file: ${e.toString()}');
    }
  }

  static Future<void> openFile(File file) async {
    try {
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        // Try alternative opening methods if the first one fails
        if (result.type == ResultType.noAppToOpen) {
          throw Exception(
            'No app found to open this file. Please install a PDF reader.',
          );
        } else if (result.type == ResultType.fileNotFound) {
          throw Exception('File not found. Please try downloading again.');
        } else {
          throw Exception('Could not open file: ${result.message}');
        }
      }
    } catch (e) {
      throw Exception('Failed to open file: ${e.toString()}');
    }
  }

  // Enhanced method to show device's native share options
  static Future<void> showNativeShareOptions(File file, String fileName) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this lesson from Hello Chickgu: $fileName',
        subject: 'Lesson: $fileName',
      );
    } catch (e) {
      throw Exception('Failed to share file: ${e.toString()}');
    }
  }

  // Enhanced method to show device's native open options
  static Future<void> showNativeOpenOptions(File file) async {
    try {
      final result = await OpenFile.open(file.path);

      switch (result.type) {
        case ResultType.done:
          // Successfully opened
          break;
        case ResultType.noAppToOpen:
          throw Exception(
            'No app found to open this file. Please install a PDF reader app.',
          );
        case ResultType.fileNotFound:
          throw Exception('File not found. Please try downloading again.');
        case ResultType.permissionDenied:
          throw Exception('Permission denied. Please check app permissions.');
        default:
          throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Failed to open file: ${e.toString()}');
    }
  }

  // Method to open app store for PDF readers
  static Future<void> openAppStoreForPDFReader() async {
    try {
      String url;
      if (Platform.isAndroid) {
        // Open Google Play Store with PDF reader search
        url = 'https://play.google.com/store/search?q=pdf%20reader&c=apps';
      } else if (Platform.isIOS) {
        // Open App Store with PDF reader search
        url = 'https://apps.apple.com/search?term=pdf%20reader';
      } else {
        throw Exception('Platform not supported');
      }

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open app store');
      }
    } catch (e) {
      throw Exception('Failed to open app store: ${e.toString()}');
    }
  }

  // Method to show native file manager
  static Future<void> showInFileManager(File file) async {
    try {
      if (Platform.isAndroid) {
        // On Android, try to open the file manager at the file location
        final uri = Uri.parse(
          'content://com.android.externalstorage.documents/root/primary',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: just show the file path
          throw Exception('File saved to: ${file.path}');
        }
      } else if (Platform.isIOS) {
        // On iOS, open Files app
        final uri = Uri.parse('shareddocuments://');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('File saved to: ${file.path}');
        }
      }
    } catch (e) {
      throw Exception('Could not open file manager: ${e.toString()}');
    }
  }

  static Future<bool> isFileDownloaded(String fileName) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return false;

      final file = File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<List<File>> getDownloadedFiles() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return [];

      final files =
          directory
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.pdf'))
              .toList();

      return files;
    } catch (e) {
      return [];
    }
  }
}

class DownloadDialog extends StatefulWidget {
  final String url;
  final String fileName;
  final String title;

  const DownloadDialog({
    super.key,
    required this.url,
    required this.fileName,
    required this.title,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isCompleted = false;
  bool _hasError = false;
  String _errorMessage = '';
  File? _downloadedFile;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _hasError = false;
      _progress = 0.0;
    });

    final file = await DownloadService.downloadFile(
      url: widget.url,
      fileName: widget.fileName,
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
      onError: (error) {
        setState(() {
          _hasError = true;
          _errorMessage = error;
          _isDownloading = false;
        });
      },
    );

    if (file != null) {
      setState(() {
        _isDownloading = false;
        _isCompleted = true;
        _downloadedFile = file;
      });
    }
  }

  Future<void> _shareFile() async {
    if (_downloadedFile == null) return;

    try {
      await DownloadService.shareFile(_downloadedFile!, widget.fileName);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile() async {
    if (_downloadedFile == null) return;

    try {
      await DownloadService.openFile(_downloadedFile!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Downloading... ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress),
          ] else if (_isCompleted) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Download completed successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('File saved as: ${widget.fileName}'),
          ] else if (_hasError) ...[
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        if (_hasError) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _progress = 0.0;
              });
              _startDownload();
            },
            child: const Text('Retry'),
          ),
        ] else if (_isCompleted) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton.icon(
            onPressed: _openFile,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open'),
          ),
          TextButton.icon(
            onPressed: _shareFile,
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ] else if (_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }
}

class DownloadButton extends StatefulWidget {
  final String url;
  final String fileName;
  final String title;
  final String? iconPath;
  final VoidCallback? onDownloadComplete;

  const DownloadButton({
    super.key,
    required this.url,
    required this.fileName,
    required this.title,
    this.iconPath,
    this.onDownloadComplete,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await DownloadService.isFileDownloaded(
      widget.fileName,
    );
    setState(() {
      _isDownloaded = isDownloaded;
    });
  }

  Future<void> _handleDownload() async {
    // Check if already downloaded
    if (_isDownloaded) {
      _showDownloadedOptions();
      return;
    }

    // Show download dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DownloadDialog(
            url: widget.url,
            fileName: widget.fileName,
            title: widget.title,
          ),
    );

    // Refresh download status
    await _checkDownloadStatus();
    widget.onDownloadComplete?.call();
  }

  void _showDownloadedOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'File already downloaded',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Open File'),
                  onTap: () async {
                    Navigator.pop(context);
                    final directory =
                        Platform.isAndroid
                            ? await getExternalStorageDirectory()
                            : await getApplicationDocumentsDirectory();
                    if (directory != null) {
                      final file = File('${directory.path}/${widget.fileName}');
                      try {
                        await DownloadService.openFile(file);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to open file: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share File'),
                  onTap: () async {
                    Navigator.pop(context);
                    final directory =
                        Platform.isAndroid
                            ? await getExternalStorageDirectory()
                            : await getApplicationDocumentsDirectory();
                    if (directory != null) {
                      final file = File('${directory.path}/${widget.fileName}');
                      try {
                        await DownloadService.shareFile(file, widget.fileName);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to share file: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleDownload,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isDownloaded ? Colors.green.shade100 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isDownloaded ? Colors.green : Colors.blue,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isDownloaded ? Icons.check_circle : Icons.download,
              color: _isDownloaded ? Colors.green : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isDownloaded ? 'Downloaded' : 'Download',
              style: TextStyle(
                color:
                    _isDownloaded
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
