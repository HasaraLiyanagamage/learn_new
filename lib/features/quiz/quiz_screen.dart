import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String courseId;
  final Function(String quizId, double score)? onQuizComplete;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.courseId,
    this.onQuizComplete,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<String, int> _selectedAnswers = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchQuizById(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final authProvider = context.watch<AuthProvider>();
    final quiz = quizProvider.currentQuiz;

    if (quizProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Quiz...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizProvider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${quizProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<QuizProvider>().fetchQuizById(widget.quizId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Quiz not found'),
              const SizedBox(height: 8),
              Text('Quiz ID: ${widget.quizId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        title: Text(quiz.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 20),
                        const SizedBox(width: 8),
                        Text('Duration: ${quiz.duration} minutes'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 20),
                        const SizedBox(width: 8),
                        Text('Passing Score: ${quiz.passingScore}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Questions
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Options
                      ...question.options.asMap().entries.map((optionEntry) {
                        final optionIndex = optionEntry.key;
                        final option = optionEntry.value;
                        final isSelected = _selectedAnswers[question.id] == optionIndex;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: _isSubmitted
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswers[question.id] = optionIndex;
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(option)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Submit button
            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswers.length == quiz.questions.length
                      ? () => _submitQuiz(context, quiz.id, authProvider.currentUser?.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Submit Quiz'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz(BuildContext context, String quizId, String? userId) async {
    if (userId == null) return;

    setState(() => _isSubmitted = true);

    final result = await context.read<QuizProvider>().submitQuiz(
          quizId,
          {'userId': userId, 'answers': _selectedAnswers},
        );

    if (context.mounted && result != null) {
      // Mark quiz as complete if passed and callback is provided
      if (result.passed && widget.onQuizComplete != null) {
        await widget.onQuizComplete!(quizId, result.percentage);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(result.passed ? 'Congratulations!' : 'Try Again'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: ${result.score}/${result.totalScore}'),
              Text('Percentage: ${result.percentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              Text(
                result.passed ? 'You passed the quiz!' : 'You need to score higher to pass.',
                style: TextStyle(
                  color: result.passed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(result.passed);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
