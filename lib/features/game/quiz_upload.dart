import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';
import 'generated_quiz_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math';

class UploadQuizPage extends StatefulWidget {
  const UploadQuizPage({super.key});

  @override
  State<UploadQuizPage> createState() => _UploadQuizPageState();
}

class _UploadQuizPageState extends State<UploadQuizPage> {
  bool isNotesSelected = true;
  String? selectedFileName;
  PlatformFile? _selectedFile;
  bool isUploading = false;

  String _getBaseUrl() {
    // If testing on a physical device, hardcode your Mac LAN IP here:
    const String? lanIp = 'http://192.168.0.105:8000';
    if (lanIp != null) return lanIp;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<void> _ensureReachable(Dio dio, String baseUrl) async {
    try {
      await dio.get('$baseUrl/docs');
    } catch (_) {
      throw Exception(
        'Cannot reach backend at $baseUrl. Is the server running and accessible?',
      );
    }
  }

  Future<Response<dynamic>> _postWithRetry(
    Dio dio,
    String url,
    Future<FormData> Function() makeForm,
  ) async {
    DioException? lastErr;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final form = await makeForm();
        return await dio.post(
          url,
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );
      } on DioException catch (e) {
        lastErr = e;
        final delay = 400 * pow(2, attempt).toInt();
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    throw lastErr ?? DioException(requestOptions: RequestOptions(path: url));
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions:
          isNotesSelected
              ? ['pdf', 'ppt', 'pptx', 'png', 'jpg', 'jpeg']
              : ['mp4', 'mov', 'mkv'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        selectedFileName = _selectedFile!.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final baseUrl = _getBaseUrl();
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
          receiveDataWhenStatusError: true,
        ),
      );

      await _ensureReachable(dio, baseUrl);

      final String? filePath = _selectedFile!.path;
      if (filePath == null) {
        throw Exception(
          'Selected file has no path. Please pick a file from device storage.',
        );
      }

      Future<FormData> makeForm() async {
        return FormData.fromMap({
          'file': await MultipartFile.fromFile(
            filePath,
            filename: _selectedFile!.name,
          ),
        });
      }

      final resp = await _postWithRetry(
        dio,
        '$baseUrl/generate_quiz',
        makeForm,
      );

      dynamic body = resp.data;
      if (body is String) {
        body = jsonDecode(body);
      }

      final quiz = body['quiz'];
      if (quiz == null) {
        final raw = body['raw'] ?? 'Model did not return JSON.';
        throw Exception('Quiz generation failed. $raw');
      }

      final List<Map<String, dynamic>> questions = _mapBackendQuizToClient(
        quiz,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  GeneratedQuizPage(title: 'AI Quiz', questions: questions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        isUploading = false;
      });
    }
  }

  // Convert backend JSON [{question, options:[...], answer:"A"}] => client format
  List<Map<String, dynamic>> _mapBackendQuizToClient(List<dynamic> quiz) {
    int _letterToIndex(String s) {
      final up = s.trim().toUpperCase();
      const letters = ['A', 'B', 'C', 'D'];
      final idx = letters.indexOf(up);
      return idx >= 0 ? idx : 0;
    }

    return quiz.map<Map<String, dynamic>>((q) {
      final List answers = (q['options'] as List?) ?? const [];
      final String ansLetter = (q['answer'] ?? 'A').toString();
      return {
        'question': q['question'] ?? '',
        'answers': answers.map((e) => e.toString()).toList(),
        'correctAnswer': _letterToIndex(ansLetter),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _generateQuestionsFromFileName(String name) {
    final List<Map<String, dynamic>> qs = [];
    final String baseName = name.split('.').first;

    // Generate more realistic questions based on file type
    final List<String> questionTemplates = [
      'What is the main topic discussed in $baseName?',
      'Which of the following is most relevant to $baseName?',
      'Based on $baseName, what would be the best approach?',
      'What key concept is highlighted in $baseName?',
      'Which statement best summarizes $baseName?',
      'What is the primary objective described in $baseName?',
      'Based on $baseName, which method is most effective?',
      'What important detail is mentioned in $baseName?',
      'Which of the following applies to $baseName?',
      'What conclusion can be drawn from $baseName?',
      'How does $baseName relate to current industry practices?',
      'What are the main challenges addressed in $baseName?',
      'Which technology is most prominently featured in $baseName?',
      'What is the recommended solution in $baseName?',
      'How would you implement the concepts from $baseName?',
      'What are the key benefits mentioned in $baseName?',
      'Which approach is suggested for beginners in $baseName?',
      'What tools are recommended in $baseName?',
      'How does $baseName improve efficiency?',
      'What are the prerequisites for understanding $baseName?',
    ];

    final List<List<String>> answerOptions = [
      [
        'A) Technical implementation',
        'B) User experience design',
        'C) Project management',
        'D) Quality assurance',
      ],
      [
        'A) Innovation and creativity',
        'B) Efficiency and optimization',
        'C) Security and reliability',
        'D) Scalability and performance',
      ],
      [
        'A) Iterative development',
        'B) Waterfall methodology',
        'C) Agile framework',
        'D) DevOps practices',
      ],
      [
        'A) Problem-solving approach',
        'B) Data analysis method',
        'C) Communication strategy',
        'D) Risk management',
      ],
      [
        'A) Comprehensive overview',
        'B) Detailed analysis',
        'C) Strategic planning',
        'D) Implementation guide',
      ],
      [
        'A) Improve performance',
        'B) Enhance security',
        'C) Increase usability',
        'D) Optimize resources',
      ],
      [
        'A) Systematic approach',
        'B) Creative thinking',
        'C) Collaborative work',
        'D) Continuous improvement',
      ],
      [
        'A) Performance metrics',
        'B) User feedback',
        'C) Technical specifications',
        'D) Best practices',
      ],
      [
        'A) Industry standard',
        'B) Emerging trend',
        'C) Best practice',
        'D) Common solution',
      ],
      [
        'A) Successful implementation',
        'B) Positive outcomes',
        'C) Improved efficiency',
        'D) Better results',
      ],
      [
        'A) Modern frameworks',
        'B) Legacy systems',
        'C) Cloud computing',
        'D) Mobile development',
      ],
      [
        'A) Resource constraints',
        'B) Technical complexity',
        'C) User adoption',
        'D) Integration issues',
      ],
      [
        'A) Python and JavaScript',
        'B) Java and C++',
        'C) React and Angular',
        'D) Node.js and Django',
      ],
      [
        'A) Step-by-step guide',
        'B) Best practices',
        'C) Automation tools',
        'D) Code examples',
      ],
      [
        'A) Following tutorials',
        'B) Reading documentation',
        'C) Hands-on practice',
        'D) Seeking mentorship',
      ],
      [
        'A) Visual Studio Code',
        'B) Git version control',
        'C) Docker containers',
        'D) Testing frameworks',
      ],
      [
        'A) Faster development',
        'B) Better code quality',
        'C) Reduced errors',
        'D) All of the above',
      ],
      [
        'A) Beginner-friendly',
        'B) Expert-level',
        'C) Intermediate',
        'D) Advanced concepts',
      ],
      [
        'A) Version control',
        'B) Code editors',
        'C) Testing tools',
        'D) All of the above',
      ],
      [
        'A) Programming fundamentals',
        'B) Domain knowledge',
        'C) Problem-solving skills',
        'D) All of the above',
      ],
    ];

    for (int i = 0; i < 20; i++) {
      qs.add({
        'question':
            'Q${i + 1}) ${questionTemplates[i % questionTemplates.length]}',
        'answers': answerOptions[i % answerOptions.length],
        'correctAnswer': i % 4,
      });
    }
    return qs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/quiz.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4E342E)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Upload for Quiz',
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  color: Color(0xFF4E342E),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF4E342E)),
            ),
            body: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Upload Your File',
                      style: TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Content Type Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isNotesSelected = true;
                                  selectedFileName =
                                      null; // Reset file when switching
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isNotesSelected
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Notes',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isNotesSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isNotesSelected = false;
                                  selectedFileName =
                                      null; // Reset file when switching
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      !isNotesSelected
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Video',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.bold,
                                    color:
                                        !isNotesSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // File Upload Zone
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:
                            selectedFileName != null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isNotesSelected
                                          ? Icons.quiz
                                          : Icons.video_file,
                                      size: 60,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      selectedFileName!,
                                      style: const TextStyle(
                                        fontFamily: 'Baloo2',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Tap to change file',
                                      style: TextStyle(
                                        fontFamily: 'Baloo2',
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload,
                                      size: 60,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      isNotesSelected
                                          ? 'Select Your Notes File (PDF/PPT/Images)'
                                          : 'Select Your Video File',
                                      style: const TextStyle(
                                        fontFamily: 'Baloo2',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUploading ? null : _uploadFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child:
                            isUploading
                                ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Uploading...',
                                      style: TextStyle(fontFamily: 'Baloo2'),
                                    ),
                                  ],
                                )
                                : const Text(
                                  'Upload to Generate Quiz',
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
