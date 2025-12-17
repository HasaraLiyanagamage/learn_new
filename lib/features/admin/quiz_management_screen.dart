import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../core/models/quiz_model.dart';

class QuizManagementScreen extends StatefulWidget {
  final String lessonId;

  const QuizManagementScreen({super.key, required this.lessonId});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lessonId.isNotEmpty) {
        context.read<QuizProvider>().fetchQuizzesByLesson(widget.lessonId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final quizzes = quizProvider.lessonQuizzes;

    // Check if lessonId is empty
    if (widget.lessonId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Quizzes'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Invalid lesson ID'),
              const SizedBox(height: 8),
              const Text('Please select a lesson first'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quizzes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuizDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: quizProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${quizProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizProvider>().fetchQuizzesByLesson(widget.lessonId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : quizProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : quizzes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.quiz, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No quizzes yet'),
                          const SizedBox(height: 8),
                          const Text('Tap + to add a quiz'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<QuizProvider>().fetchQuizzesByLesson(widget.lessonId);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.quiz),
                        ),
                        title: Text(quiz.title),
                        subtitle: Text('${quiz.questions.length} questions • ${quiz.duration} min'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showQuizDialog(context, quiz),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuiz(context, quiz.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showQuizDialog(BuildContext context, QuizModel? quiz) {
    final titleController = TextEditingController(text: quiz?.title ?? '');
    final descriptionController = TextEditingController(text: quiz?.description ?? '');
    final durationController = TextEditingController(text: quiz?.duration.toString() ?? '');
    final passingScoreController = TextEditingController(text: quiz?.passingScore.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(quiz == null ? 'Add Quiz' : 'Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passingScoreController,
                decoration: const InputDecoration(labelText: 'Passing Score (%)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newQuiz = QuizModel(
                id: quiz?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                lessonId: widget.lessonId,
                title: titleController.text,
                description: descriptionController.text,
                questions: quiz?.questions ?? [],
                duration: int.tryParse(durationController.text) ?? 0,
                passingScore: int.tryParse(passingScoreController.text) ?? 70,
                createdAt: quiz?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              bool success;
              if (quiz == null) {
                success = await context.read<QuizProvider>().createQuiz(newQuiz);
              } else {
                success = await context.read<QuizProvider>().updateQuiz(quiz.id, newQuiz);
              }

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(quiz == null ? 'Quiz created' : 'Quiz updated')),
                  );
                  context.read<QuizProvider>().fetchQuizzesByLesson(widget.lessonId);
                }
              }
            },
            child: Text(quiz == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteQuiz(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<QuizProvider>().deleteQuiz(quizId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz deleted')),
                  );
                  context.read<QuizProvider>().fetchQuizzesByLesson(widget.lessonId);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
