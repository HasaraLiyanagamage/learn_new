# Course Rating System Implementation

## Overview

A comprehensive course rating and feedback system has been implemented, allowing students who complete courses to leave ratings (1-5 stars) and optional reviews. All ratings are displayed on the course details page for any user to view.

## Features Implemented

### 1. Rating Model (`lib/core/models/rating_model.dart`)
- **Fields:**
  - `id`: Unique identifier (format: `{userId}_{courseId}`)
  - `userId`: ID of the student who rated
  - `courseId`: ID of the rated course
  - `rating`: Star rating (1.0 to 5.0)
  - `review`: Optional text review (max 500 characters)
  - `userName`: Display name of the reviewer
  - `createdAt`: Timestamp when rating was created
  - `updatedAt`: Timestamp when rating was last updated

### 2. Firestore Service Methods (`lib/core/services/firestore_service.dart`)

Added the following rating-related methods:

- `createRating()`: Create a new rating
- `updateRating()`: Update an existing rating
- `getRating()`: Get a specific rating by ID
- `deleteRating()`: Delete a rating
- `getRatingsByCourseStream()`: Stream of all ratings for a course (real-time)
- `getRatingsByCourse()`: Get all ratings for a course (one-time fetch)
- `getUserRatingForCourse()`: Check if a user has rated a specific course
- `updateCourseRating()`: Calculate and update the course's average rating

### 3. Rating Dialog Widget (`lib/widgets/course_rating_dialog.dart`)

A beautiful, user-friendly dialog for submitting/updating ratings:

**Features:**
- Interactive 5-star rating selector
- Dynamic rating text (Excellent, Very Good, Good, Fair, Poor)
- Optional review text field (500 character limit)
- Support for both new ratings and updating existing ones
- Loading state during submission
- Error handling with user feedback

### 4. Course Details Page Updates (`lib/features/courses/course_detail_screen.dart`)

**Enhanced with:**

#### Rating Submission
- Prompt to rate course after completion
- "Rate This Course" button for completed courses
- Shows existing rating if user has already rated
- "Update Your Rating" option with current rating display

#### Ratings Display Section
- **Header:** Shows "Course Ratings" with average rating badge
- **Empty State:** Friendly message when no ratings exist
- **Rating Cards:** Display all course ratings with:
  - User avatar and name
  - Star rating visualization
  - Review text (if provided)
  - Relative timestamp (e.g., "2h ago", "3d ago")
- **Real-time Updates:** Uses StreamBuilder for live rating updates

## User Experience Flow

### For Students Completing a Course:

1. **Complete all lessons and quizzes**
2. **Click "Mark Course as Complete"**
3. **Congratulations dialog appears** with two options:
   - "Maybe Later" - Skip rating for now
   - "Rate Course" - Open rating dialog
4. **If "Rate Course" selected:**
   - Rating dialog opens
   - Select 1-5 stars
   - Optionally write a review
   - Click "Submit"
5. **Rating is saved** and course average is updated
6. **Can update rating later** via "Update Your Rating" button

### For Any User Viewing Course Details:

1. **Scroll to "Course Ratings" section** (below quizzes)
2. **See average rating** in header badge (if ratings exist)
3. **View all ratings** with:
   - Student names
   - Star ratings
   - Reviews
   - Timestamps
4. **Empty state shown** if no ratings yet

## Data Structure

### Firestore Collection: `ratings`

```
ratings/
  {userId}_{courseId}/
    id: string
    userId: string
    courseId: string
    rating: number (1.0-5.0)
    review: string (optional)
    userName: string
    createdAt: timestamp
    updatedAt: timestamp
```

### Course Document Updates

The `rating` field in the `courses` collection is automatically updated whenever:
- A new rating is submitted
- An existing rating is updated
- A rating is deleted

The average is calculated from all ratings for that course.

## Key Implementation Details

### Unique Rating ID
- Format: `{userId}_{courseId}`
- Ensures one rating per user per course
- Allows easy updates and retrieval

### Real-time Updates
- Uses Firestore StreamBuilder
- Ratings appear instantly for all users
- No page refresh needed

### Rating Calculation
- Average calculated from all course ratings
- Automatically updates course document
- Displayed with 1 decimal place (e.g., 4.5)

### Permissions
- **Only students who completed the course** can rate
- **All users** can view ratings
- **Users can update** their own ratings anytime

### UI/UX Highlights
- Star rating with visual feedback
- Character counter for reviews
- Loading states during submission
- Success/error messages
- Responsive design
- Relative timestamps for better context

## Firestore Security Rules (Recommended)

Add these rules to your `firestore.rules`:

```javascript
// Ratings collection
match /ratings/{ratingId} {
  // Anyone can read ratings
  allow read: if true;
  
  // Only authenticated users can create ratings
  allow create: if request.auth != null 
    && request.resource.data.userId == request.auth.uid;
  
  // Only the rating author can update their rating
  allow update: if request.auth != null 
    && resource.data.userId == request.auth.uid;
  
  // Only the rating author can delete their rating
  allow delete: if request.auth != null 
    && resource.data.userId == request.auth.uid;
}
```

## Firestore Indexes Required

Create a composite index for efficient queries:

**Collection:** `ratings`
**Fields:**
- `courseId` (Ascending)
- `createdAt` (Descending)

You can create this index by:
1. Running the app and triggering the query
2. Clicking the link in the error message
3. Or manually creating it in Firebase Console

## Testing Checklist

- [ ] Complete a course as a student
- [ ] Rate the course with 5 stars and a review
- [ ] Verify rating appears on course details page
- [ ] Update the rating to 4 stars
- [ ] Verify updated rating is reflected
- [ ] View course as another user (not enrolled)
- [ ] Verify ratings are visible to all users
- [ ] Add multiple ratings from different users
- [ ] Verify average rating is calculated correctly
- [ ] Test with no ratings (empty state)
- [ ] Test review with 500 characters
- [ ] Test rating without review (optional field)

## Future Enhancements (Optional)

1. **Rating Analytics:**
   - Show rating distribution (how many 5-star, 4-star, etc.)
   - Display total number of ratings

2. **Helpful Votes:**
   - Allow users to mark reviews as helpful
   - Sort by most helpful

3. **Admin Moderation:**
   - Flag inappropriate reviews
   - Admin dashboard to moderate ratings

4. **Rich Reviews:**
   - Add photos to reviews
   - Pros and cons sections

5. **Verified Completion Badge:**
   - Show badge for verified course completers

## Files Modified/Created

### Created:
- `lib/core/models/rating_model.dart`
- `lib/widgets/course_rating_dialog.dart`
- `COURSE_RATING_SYSTEM.md` (this file)

### Modified:
- `lib/core/services/firestore_service.dart`
- `lib/features/courses/course_detail_screen.dart`

## Summary

The course rating system is now fully functional, providing a complete feedback loop for students and valuable information for all users browsing courses. The implementation follows best practices with real-time updates, proper error handling, and a polished user experience.
