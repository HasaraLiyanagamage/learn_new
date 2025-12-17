import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';

class LessonViewerScreen extends StatefulWidget {
  final String lessonId;
  final String courseId;

  const LessonViewerScreen({
    super.key,
    required this.lessonId,
    required this.courseId,
  });

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().fetchLessonById(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final authProvider = context.watch<AuthProvider>();
    final lesson = lessonProvider.currentLesson;

    if (lessonProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Not Found')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download lesson for offline viewing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lesson downloaded for offline viewing')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player (if video URL exists)
            if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        'Video Player',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Lesson duration
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text('${lesson.duration} minutes'),
              ],
            ),
            const SizedBox(height: 16),

            // Lesson content
            Text(
              'Lesson Content',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              lesson.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Attachments
            if (lesson.attachments.isNotEmpty) ...[
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...lesson.attachments.map((attachment) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.attach_file),
                      title: Text(attachment),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Download attachment
                        },
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 32),

            // Mark as complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final userId = authProvider.currentUser?.id;
                  if (userId != null) {
                    await context.read<ProgressProvider>().updateProgress(
                          userId,
                          widget.courseId,
                          widget.lessonId,
                          true,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lesson marked as complete!')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
