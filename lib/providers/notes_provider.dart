import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/models/note_model.dart';
import '../core/services/firestore_service.dart';

class NotesProvider with ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch notes for a user with real-time updates (Offline-enabled)
  void fetchNotesStream(String userId) {
    _isLoading = true;
    notifyListeners();

    FirestoreService.getNotesByUserStream(userId).listen(
      (snapshot) {
        _notes = snapshot.docs
            .map((doc) => NoteModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load notes: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Create a new note (Offline-enabled)
  Future<bool> createNote({
    required String userId,
    required String title,
    required String content,
    String? lessonId,
    String? courseId,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final noteId = const Uuid().v4();
      final now = DateTime.now();

      final note = NoteModel(
        id: noteId,
        userId: userId,
        title: title,
        content: content,
        lessonId: lessonId,
        courseId: courseId,
        tags: tags ?? [],
        createdAt: now,
        updatedAt: now,
      );

      await FirestoreService.createNote(noteId, note.toJson());

      _notes.insert(0, note);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a note (Offline-enabled)
  Future<bool> updateNote(String noteId, {
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index == -1) {
        _errorMessage = 'Note not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedNote = _notes[index].copyWith(
        title: title ?? _notes[index].title,
        content: content ?? _notes[index].content,
        tags: tags ?? _notes[index].tags,
        updatedAt: DateTime.now(),
      );

      await FirestoreService.updateNote(noteId, updatedNote.toJson());

      _notes[index] = updatedNote;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a note (Offline-enabled)
  Future<bool> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirestoreService.deleteNote(noteId);
      _notes.removeWhere((n) => n.id == noteId);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get a single note by ID
  NoteModel? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((n) => n.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // Search notes
  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Filter notes by course
  List<NoteModel> filterByCourse(String courseId) {
    return _notes.where((note) => note.courseId == courseId).toList();
  }

  // Filter notes by lesson
  List<NoteModel> filterByLesson(String lessonId) {
    return _notes.where((note) => note.lessonId == lessonId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
