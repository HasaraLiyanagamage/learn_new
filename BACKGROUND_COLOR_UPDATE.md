# Background Color Applied to All Pages

## Overview
Added consistent background colors to all pages in the app for both light and dark themes.

---

## Changes Made

### File: `lib/providers/theme_provider.dart`

#### Light Theme
**Added:**
- **Scaffold Background:** `#F5F5FF` (Light purple-tinted background)
- **Card Background:** `#FFFFFF` (White cards)
- **Input Fill Color:** `#FFFFFF` (White input fields)

```dart
scaffoldBackgroundColor: const Color(0xFFF5F5FF), // Light purple-tinted background
cardTheme: CardThemeData(
  elevation: 2,
  color: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
),
inputDecorationTheme: InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  filled: true,
  fillColor: Colors.white,
),
```

---

#### Dark Theme
**Added:**
- **Scaffold Background:** `#1A1A2E` (Dark purple-tinted background)
- **Card Background:** `#2D2D44` (Dark purple cards)
- **Input Fill Color:** `#2D2D44` (Dark purple input fields)

```dart
scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark purple-tinted background
cardTheme: CardThemeData(
  elevation: 2,
  color: const Color(0xFF2D2D44),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
),
inputDecorationTheme: InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  filled: true,
  fillColor: const Color(0xFF2D2D44),
),
```

---

## Color Palette

### Light Theme Colors
| Element | Color | Hex | Description |
|---------|-------|-----|-------------|
| **Background** | 🟪 | #F5F5FF | Light purple-tinted |
| **Cards** | ⬜ | #FFFFFF | White |
| **Input Fields** | ⬜ | #FFFFFF | White |
| **Primary** | 🟣 | #8E94F2 | Purple (seed color) |

### Dark Theme Colors
| Element | Color | Hex | Description |
|---------|-------|-----|-------------|
| **Background** | ⬛ | #1A1A2E | Dark purple-tinted |
| **Cards** | ⬛ | #2D2D44 | Dark purple |
| **Input Fields** | ⬛ | #2D2D44 | Dark purple |
| **Primary** | 🟣 | #8E94F2 | Purple (seed color) |

---

## Visual Impact

### Light Theme

**Before:**
```
┌─────────────────────────┐
│   App Bar               │ ← Purple
├─────────────────────────┤
│                         │
│  ⬜ Card                │ ← White on white
│                         │
│  ⬜ Card                │
│                         │
└─────────────────────────┘
   ⬜ White background
```

**After:**
```
┌─────────────────────────┐
│   App Bar               │ ← Purple
├─────────────────────────┤
│                         │
│  ⬜ Card                │ ← White on purple-tinted
│                         │
│  ⬜ Card                │
│                         │
└─────────────────────────┘
   🟪 Light purple background
```

---

### Dark Theme

**Before:**
```
┌─────────────────────────┐
│   App Bar               │ ← Purple
├─────────────────────────┤
│                         │
│  ⬛ Card                │ ← Dark on dark
│                         │
│  ⬛ Card                │
│                         │
└─────────────────────────┘
   ⬛ Black background
```

**After:**
```
┌─────────────────────────┐
│   App Bar               │ ← Purple
├─────────────────────────┤
│                         │
│  ⬛ Card                │ ← Dark purple on darker purple
│                         │
│  ⬛ Card                │
│                         │
└─────────────────────────┘
   ⬛ Dark purple background
```

---

## Benefits

### 1. **Visual Consistency**
- All pages have the same background color
- Cohesive design throughout the app
- Professional appearance

### 2. **Better Contrast**
- Cards stand out from background
- Improved readability
- Clear visual hierarchy

### 3. **Theme Integration**
- Background color matches purple theme
- Subtle purple tint in light mode
- Deep purple tint in dark mode

### 4. **Material Design**
- Follows Material 3 guidelines
- Proper elevation and depth
- Modern, clean look

---

## Pages Affected

All pages in the app now have the background color:

### Student Pages
- ✅ Home Screen
- ✅ Courses Screen
- ✅ Course Detail Screen
- ✅ Lesson Screen
- ✅ Quiz Screen
- ✅ Progress Screen
- ✅ Notifications Screen
- ✅ Profile Screen
- ✅ Settings Screen

### Admin Pages
- ✅ Admin Dashboard
- ✅ Course Management
- ✅ Lesson Management
- ✅ Quiz Management
- ✅ User Management
- ✅ Reports Screen
- ✅ Send Notification Screen
- ✅ Admin Notifications Screen

### Auth Pages
- ✅ Login Screen
- ✅ Register Screen

---

## How It Works

### Scaffold Background Color
```dart
scaffoldBackgroundColor: const Color(0xFFF5F5FF),
```

This property sets the background color for all `Scaffold` widgets in the app. Since most screens use `Scaffold`, this applies to all pages automatically.

### Card Color
```dart
cardTheme: CardThemeData(
  color: Colors.white,
  // ...
),
```

This ensures cards have a distinct color from the background, creating visual separation.

### Input Field Color
```dart
inputDecorationTheme: InputDecorationTheme(
  fillColor: Colors.white,
  filled: true,
  // ...
),
```

This gives input fields a clear background, making them easy to identify.

---

## Testing

### To See Changes:
1. **Hot Restart** the app (press `R` in terminal)
2. **Or Stop and Rerun** the app

### What to Check:
- ✅ All pages have purple-tinted background (light mode)
- ✅ All pages have dark purple background (dark mode)
- ✅ Cards stand out from background
- ✅ Input fields are clearly visible
- ✅ Text is readable on background

---

## Customization

### To Change Background Color:

#### Light Theme
```dart
scaffoldBackgroundColor: const Color(0xFFF5F5FF), // Change this hex value
```

**Lighter:**
```dart
scaffoldBackgroundColor: const Color(0xFFFAFAFF), // Almost white
```

**More Purple:**
```dart
scaffoldBackgroundColor: const Color(0xFFEEEEFF), // More purple tint
```

#### Dark Theme
```dart
scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Change this hex value
```

**Lighter:**
```dart
scaffoldBackgroundColor: const Color(0xFF252540), // Lighter dark
```

**Darker:**
```dart
scaffoldBackgroundColor: const Color(0xFF0F0F1E), // Deeper dark
```

---

## Color Harmony

The background colors are chosen to complement the purple theme:

### Light Theme
- **Background:** #F5F5FF (Very light purple)
- **Primary:** #8E94F2 (Purple)
- **Cards:** #FFFFFF (White)

These colors create a soft, professional look with good contrast.

### Dark Theme
- **Background:** #1A1A2E (Dark purple-blue)
- **Primary:** #8E94F2 (Purple)
- **Cards:** #2D2D44 (Medium dark purple)

These colors create a modern, elegant dark mode with proper depth.

---

## Before & After Comparison

### Light Mode

| Aspect | Before | After |
|--------|--------|-------|
| Background | White (#FFFFFF) | Light Purple (#F5F5FF) |
| Cards | White on White | White on Purple-tinted |
| Contrast | Low | High ✅ |
| Visual Interest | Plain | Subtle & Professional ✅ |

### Dark Mode

| Aspect | Before | After |
|--------|--------|-------|
| Background | Black (#000000) | Dark Purple (#1A1A2E) |
| Cards | Dark on Black | Dark Purple on Darker Purple |
| Contrast | Low | High ✅ |
| Visual Interest | Plain | Elegant & Modern ✅ |

---

## Summary

✅ **Background Color Applied** - All pages have consistent background  
✅ **Light Theme** - #F5F5FF (Light purple-tinted)  
✅ **Dark Theme** - #1A1A2E (Dark purple-tinted)  
✅ **Card Colors** - White (light) / #2D2D44 (dark)  
✅ **Input Colors** - White (light) / #2D2D44 (dark)  
✅ **Better Contrast** - Cards stand out from background  
✅ **Theme Integration** - Matches purple color scheme  
✅ **Material Design** - Follows Material 3 guidelines  

**All pages now have a beautiful, consistent background color!** 🎨✨

Restart the app to see the new background colors!
