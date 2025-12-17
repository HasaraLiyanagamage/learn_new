import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../core/models/lesson_model.dart';

class LessonManagementScreen extends StatefulWidget {
  final String courseId;

  const LessonManagementScreen({super.key, required this.courseId});

  @override
  State<LessonManagementScreen> createState() => _LessonManagementScreenState();
}

class _LessonManagementScreenState extends State<LessonManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().fetchLessonsByCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lessons = lessonProvider.courseLessons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Lessons'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLessonDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: lessonProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No lessons yet'),
                      SizedBox(height: 8),
                      Text('Tap + to add a lesson'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${lesson.order}'),
                        ),
                        title: Text(lesson.title),
                        subtitle: Text('${lesson.duration} min'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.quiz),
                              tooltip: 'Manage Quizzes',
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/admin/quizzes',
                                  arguments: lesson.id,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showLessonDialog(context, lesson),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLesson(context, lesson.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showLessonDialog(BuildContext context, LessonModel? lesson) {
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final contentController = TextEditingController(text: lesson?.content ?? '');
    final videoUrlController = TextEditingController(text: lesson?.videoUrl ?? '');
    final durationController = TextEditingController(text: lesson?.duration.toString() ?? '');
    final orderController = TextEditingController(text: lesson?.order.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson == null ? 'Add Lesson' : 'Edit Lesson'),
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
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(labelText: 'Video URL (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(labelText: 'Order'),
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
              final newLesson = LessonModel(
                id: lesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                courseId: widget.courseId,
                title: titleController.text,
                content: contentController.text,
                videoUrl: videoUrlController.text.isEmpty ? null : videoUrlController.text,
                duration: int.tryParse(durationController.text) ?? 0,
                order: int.tryParse(orderController.text) ?? 0,
                createdAt: lesson?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              bool success;
              if (lesson == null) {
                success = await context.read<LessonProvider>().createLesson(newLesson);
              } else {
                success = await context.read<LessonProvider>().updateLesson(lesson.id, newLesson);
              }

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lesson == null ? 'Lesson created' : 'Lesson updated')),
                  );
                  context.read<LessonProvider>().fetchLessonsByCourse(widget.courseId);
                }
              }
            },
            child: Text(lesson == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteLesson(BuildContext context, String lessonId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<LessonProvider>().deleteLesson(lessonId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson deleted')),
                  );
                  context.read<LessonProvider>().fetchLessonsByCourse(widget.courseId);
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
