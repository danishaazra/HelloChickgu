import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';
import 'generated_quiz_page.dart';
import 'package:file_picker/file_picker.dart';

class UploadQuizPage extends StatefulWidget {
  const UploadQuizPage({super.key});

  @override
  State<UploadQuizPage> createState() => _UploadQuizPageState();
}

class _UploadQuizPageState extends State<UploadQuizPage> {
  bool isNotesSelected = true;
  String? selectedFileName;
  bool isUploading = false;

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
        selectedFileName = result.files.first.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    // Simulate upload and processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isUploading = false;
    });

    // Store the file name before resetting
    final uploadedFileName = selectedFileName!;

    // Generate questions and navigate to quiz page
    final List<Map<String, dynamic>> generated = _generateQuestionsFromFileName(
      uploadedFileName,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  GeneratedQuizPage(title: 'AI Quiz', questions: generated),
        ),
      );
    }

    // Reset file selection
    setState(() {
      selectedFileName = null;
    });
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
    ];

    for (int i = 0; i < 10; i++) {
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
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF4E342E),
                ),
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
