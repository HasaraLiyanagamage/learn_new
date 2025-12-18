import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/firestore_service.dart';
import '../../providers/course_provider.dart';
import '../../core/models/lesson_model.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passingScoreController = TextEditingController();
  final _durationController = TextEditingController();
  
  String? _selectedCourseId;
  String? _selectedLessonId;
  List<LessonModel> _lessons = [];
  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  bool _loadingLessons = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCoursesStream();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passingScoreController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons(String courseId) async {
    setState(() {
      _loadingLessons = true;
      _selectedLessonId = null;
      _lessons = [];
    });

    try {
      final snapshot = await FirestoreService.getLessonsByCourse(courseId);
      _lessons = snapshot.docs
          .map((doc) => LessonModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lessons: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingLessons = false;
        });
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': 0,
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLessonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a lesson')),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    // Validate questions
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i]['question'].toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} is empty')),
        );
        return;
      }
      for (int j = 0; j < 4; j++) {
        if (_questions[i]['options'][j].toString().trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question ${i + 1}, Option ${j + 1} is empty')),
          );
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Format questions properly to ensure options are saved as arrays
      final formattedQuestions = _questions.map((q) {
        return {
          'id': const Uuid().v4(),
          'question': q['question'].toString().trim(),
          'options': List<String>.from(q['options']), // Ensure it's a proper List
          'correctAnswer': q['correctAnswer'] as int,
          'points': 1,
        };
      }).toList();
      
      final quizData = {
        'lessonId': _selectedLessonId!,
        'courseId': _selectedCourseId!,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'passingScore': int.parse(_passingScoreController.text.trim()),
        'duration': int.parse(_durationController.text.trim()),
        'questions': formattedQuestions,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      await FirestoreService.createQuiz(quizData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Quiz'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Selection
                  Text(
                    'Select Course',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourseId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Choose a course',
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: courseProvider.courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourseId = value;
                      });
                      if (value != null) {
                        _loadLessons(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a course';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lesson Selection
                  Text(
                    'Select Lesson',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLessonId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Choose a lesson',
                      prefixIcon: Icon(Icons.book),
                    ),
                    items: _lessons.map((lesson) {
                      return DropdownMenuItem(
                        value: lesson.id,
                        child: Text(lesson.title),
                      );
                    }).toList(),
                    onChanged: _loadingLessons
                        ? null
                        : (value) {
                            setState(() {
                              _selectedLessonId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a lesson';
                      }
                      return null;
                    },
                  ),
                  if (_loadingLessons)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(),
                    ),
                  const SizedBox(height: 24),

                  // Quiz Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.quiz),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter quiz title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quiz Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Passing Score and Duration
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passingScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Passing Score (%)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.grade),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final score = int.tryParse(value);
                            if (score == null || score < 0 || score > 100) {
                              return '0-100';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration (min)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Questions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Questions List
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return _QuestionCard(
                      questionNumber: index + 1,
                      question: question,
                      onRemove: () => _removeQuestion(index),
                      onQuestionChanged: (value) {
                        setState(() {
                          _questions[index]['question'] = value;
                        });
                      },
                      onOptionChanged: (optionIndex, value) {
                        setState(() {
                          _questions[index]['options'][optionIndex] = value;
                        });
                      },
                      onCorrectAnswerChanged: (value) {
                        setState(() {
                          _questions[index]['correctAnswer'] = value;
                        });
                      },
                    );
                  }),

                  if (_questions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No questions added yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _addQuestion,
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Question'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveQuiz,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final Map<String, dynamic> question;
  final VoidCallback onRemove;
  final ValueChanged<String> onQuestionChanged;
  final Function(int, String) onOptionChanged;
  final ValueChanged<int> onCorrectAnswerChanged;

  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.onRemove,
    required this.onQuestionChanged,
    required this.onOptionChanged,
    required this.onCorrectAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $questionNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Question Text
            TextFormField(
              initialValue: question['question'],
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: onQuestionChanged,
            ),
            const SizedBox(height: 16),

            // Options
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: question['correctAnswer'],
                      onChanged: (value) => onCorrectAnswerChanged(value!),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: question['options'][index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => onOptionChanged(index, value),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 8),
            Text(
              'Select the correct answer by clicking the radio button',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
