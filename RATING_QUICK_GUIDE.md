# Course Rating System - Quick Reference

## How It Works

### For Students

**Step 1: Complete the Course**
- Complete all lessons and quizzes
- Click "Mark Course as Complete" button

**Step 2: Rate the Course**
- After completion, you'll see a congratulations dialog
- Choose "Rate Course" or "Maybe Later"
- If you skip, you can rate later using the "Rate This Course" button

**Step 3: Submit Your Rating**
- Select 1-5 stars
- Optionally write a review (up to 500 characters)
- Click "Submit"

**Step 4: Update Your Rating (Optional)**
- Click "Update Your Rating" button anytime
- Modify stars or review
- Click "Update"

### For All Users

**Viewing Ratings:**
- Open any course details page
- Scroll to "Course Ratings" section (at the bottom)
- See average rating in the header
- Read all student reviews

## Key Features

✅ **One rating per student per course**
- Each student can only rate a course once
- But can update their rating anytime

✅ **Real-time updates**
- Ratings appear instantly for all users
- No page refresh needed

✅ **Average rating calculation**
- Automatically calculated from all ratings
- Displayed on course header and ratings section

✅ **Optional reviews**
- Students can rate without writing a review
- Or add detailed feedback (max 500 chars)

✅ **Visible to everyone**
- All users can see ratings and reviews
- Even if not enrolled in the course

## Rating Scale

⭐ **1 Star** - Poor
⭐⭐ **2 Stars** - Fair
⭐⭐⭐ **3 Stars** - Good
⭐⭐⭐⭐ **4 Stars** - Very Good
⭐⭐⭐⭐⭐ **5 Stars** - Excellent

## Where to Find Ratings

### On Course Details Page:
1. **Course Header** - Shows average rating with star icon
2. **After Completion Badge** - "Rate This Course" button
3. **Course Ratings Section** - Full list of all ratings at bottom

## Technical Details

### Data Storage
- **Collection:** `ratings`
- **Document ID:** `{userId}_{courseId}`
- **Fields:** rating, review, userName, timestamps

### Permissions
- ✅ Anyone can **view** ratings
- ✅ Completed students can **create** ratings
- ✅ Rating authors can **update** their own ratings
- ❌ Cannot rate without completing the course

## Troubleshooting

**Q: I completed the course but can't rate it**
- Make sure you clicked "Mark Course as Complete"
- Check that all lessons and quizzes are marked as complete

**Q: My rating doesn't appear**
- Wait a few seconds for real-time sync
- Check your internet connection
- Try refreshing the page

**Q: Can I delete my rating?**
- Currently, you can only update your rating
- Contact admin if you need to remove it

**Q: Why can't I rate a course I'm viewing?**
- You must be enrolled AND complete the course first
- Ratings are only for students who finished the course

## For Developers

### Quick Integration Check
```dart
// 1. Rating model exists
import '../core/models/rating_model.dart';

// 2. Firestore methods available
FirestoreService.createRating(ratingId, data);
FirestoreService.getRatingsByCourseStream(courseId);

// 3. Dialog widget ready
CourseRatingDialog(
  courseId: courseId,
  courseTitle: title,
  existingRating: rating,
);
```

### Testing Commands
```bash
# Analyze rating files
flutter analyze lib/core/models/rating_model.dart
flutter analyze lib/widgets/course_rating_dialog.dart

# Run the app
flutter run
```

## Support

For issues or questions about the rating system:
1. Check `COURSE_RATING_SYSTEM.md` for detailed documentation
2. Review Firestore security rules
3. Verify Firestore indexes are created
4. Check Firebase Console for rating data
