import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../shared/theme/theme.dart';
import '../chatbot/chippy_chatbot.dart';
import '../../services/download_service.dart';
import '../../shared/widgets/ar_button.dart';

class ModuleContentPage extends StatelessWidget {
  final String courseTitle;
  final String moduleTitle;
  final String backgroundImage;
  final String subtopicTitle;
  final double progress; // 0.0 - 1.0
  final int currentPage;
  final int totalPages;

  const ModuleContentPage({
    super.key,
    required this.courseTitle,
    required this.moduleTitle,
    required this.backgroundImage,
    required this.subtopicTitle,
    required this.progress,
    this.currentPage = 1,
    this.totalPages = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),
          // subtle gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moduleTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtopicTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0, 1),
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _AssetIconButton(
                            assetPath: 'assets/help icon.png',
                            tooltip: 'Help',
                            size: 80,
                            backgroundColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChippyChatbotPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          ARButton(
                            size: 70,
                            iconColor: Colors.black,
                            backgroundColor: Colors.transparent,
                            tooltip: 'AR Experience',
                          ),
                          const SizedBox(width: 6),
                          _AssetIconButton(
                            assetPath: 'assets/download icon.png',
                            tooltip: 'Download',
                            size: 70,
                            backgroundColor: Colors.transparent,
                            onTap: () async {
                              await _downloadLessonAsPdf(
                                context,
                                title: moduleTitle,
                                subtopic: subtopicTitle,
                                content: _dummyContent(moduleTitle),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moduleTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _dummyContent(moduleTitle),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                _AssetIconButton(
                  assetPath: 'assets/back icon.png',
                  tooltip: 'Previous',
                  size: 48,
                  backgroundColor: Colors.transparent,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentPage/$totalPages',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                _AssetIconButton(
                  assetPath: 'assets/next icon.png',
                  tooltip: 'Next',
                  size: 48,
                  backgroundColor: Colors.transparent,
                  onTap: () {
                    if (currentPage >= totalPages) {
                      _showCompletionDialog(context, moduleTitle);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _dummyContent(String moduleTitle) {
  return 'Dummy content...\n\n'
      'What is Python?\n'
      'Python is a popular programming language. It was created by Guido van Rossum, and released in 1991.\n\n'
      'What can Python do?\n'
      '- Web development (server-side)\n'
      '- Software development\n'
      '- Mathematics\n'
      '- System scripting\n\n'
      'Dummy content...\n\n'
      'What is Python?\n'
      'Python is a popular programming language. It was created by Guido van Rossum, and released in 1991.\n\n'
      'What can Python do?\n'
      '- Web development (server-side)\n'
      '- Software development\n'
      '- Mathematics\n'
      '- System scripting\n\n'
      'This is placeholder text. Replace with your lesson content later.';
}

Future<void> _downloadLessonAsPdf(
  BuildContext context, {
  required String title,
  required String subtopic,
  required String content,
}) async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating PDF...'),
                  ],
                ),
              ),
            ),
          ),
    );

    // Generate PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(24)),
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(subtopic, style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 12),
              pw.Text(
                content,
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.left,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString()}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
      ),
    );

    // Get storage directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    final fileName = '${title.replaceAll(' ', '_')}_lesson.pdf';
    final String filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Save PDF
    await file.writeAsBytes(await pdf.save());

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show success dialog with options
    if (context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Download Complete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text('PDF saved successfully!'),
                  const SizedBox(height: 8),
                  Text('File: $fileName'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await DownloadService.showNativeOpenOptions(file);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${e.toString()}'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Install PDF Reader',
                              textColor: Colors.white,
                              onPressed: () async {
                                try {
                                  await DownloadService.openAppStoreForPDFReader();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not open app store: ${e.toString()}',
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open with Device App'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await DownloadService.showNativeShareOptions(
                        file,
                        fileName,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to share: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share via Device'),
                ),
              ],
            ),
      );
    }
  } catch (e) {
    // Close loading dialog if open
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Download failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

void _showCompletionDialog(BuildContext context, String moduleTitle) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/chickBook.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Congratulations!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You have completed Module 1\n"$moduleTitle"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: InkWell(
                onTap: () => Navigator.of(ctx).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _AssetIconButton extends StatelessWidget {
  final String assetPath;
  final String? tooltip;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;

  const _AssetIconButton({
    required this.assetPath,
    this.tooltip,
    required this.onTap,
    this.size = 36,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTransparent =
        backgroundColor == null || backgroundColor == Colors.transparent;
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color:
              isTransparent
                  ? Colors.transparent
                  : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow:
              isTransparent
                  ? null
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
        ),
        padding: EdgeInsets.all(size * 0.06),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
