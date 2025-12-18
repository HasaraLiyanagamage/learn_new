import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/services/firestore_service.dart';
import '../core/models/rating_model.dart';

class CourseRatingDialog extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final RatingModel? existingRating;

  const CourseRatingDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.existingRating,
  });

  @override
  State<CourseRatingDialog> createState() => _CourseRatingDialogState();
}

class _CourseRatingDialogState extends State<CourseRatingDialog> {
  late double _rating;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingRating?.rating ?? 0.0;
    _reviewController.text = widget.existingRating?.review ?? '';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;
      final userName = authProvider.currentUser?.name ?? 'Anonymous';

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final ratingId = '${userId}_${widget.courseId}';

      final ratingData = RatingModel(
        id: ratingId,
        userId: userId,
        courseId: widget.courseId,
        rating: _rating,
        review: _reviewController.text.trim().isEmpty 
            ? null 
            : _reviewController.text.trim(),
        userName: userName,
        createdAt: widget.existingRating?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existingRating != null) {
        // Update existing rating
        await FirestoreService.updateRating(ratingId, ratingData.toJson());
      } else {
        // Create new rating
        await FirestoreService.createRating(ratingId, ratingData.toJson());
      }

      // Update course average rating
      await FirestoreService.updateCourseRating(widget.courseId);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRating != null 
                  ? 'Rating updated successfully!' 
                  : 'Thank you for your feedback!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingRating != null ? 'Update Your Rating' : 'Rate This Course',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Star Rating
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      _rating >= starValue
                          ? Icons.star
                          : _rating >= starValue - 0.5
                              ? Icons.star_half
                              : Icons.star_border,
                      size: 40,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                  );
                }),
              ),
            ),
            
            if (_rating > 0)
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Review Text Field
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Write a review (optional)',
                hintText: 'Share your experience with this course...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingRating != null ? 'Update' : 'Submit'),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent!';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }
}
