import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/firestore_service.dart';
import '../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    
    if (isLoggedIn) {
      final userId = prefs.getString(AppConstants.keyUserId);
      if (userId != null) {
        await _loadUserData(userId);
      }
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await FirestoreService.getUser(userId);
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Refresh user data from Firestore
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.id);
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    UserCredential? userCredential;
    
    try {
      // Firebase Authentication
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          // Get user data from Firestore
          final doc = await FirestoreService.getUser(userCredential.user!.uid);
          
          if (doc.exists) {
            _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          } else {
            // If user document doesn't exist, create it with basic info
            final now = DateTime.now();
            final userData = UserModel(
              id: userCredential.user!.uid,
              email: email,
              name: userCredential.user!.displayName ?? email.split('@')[0],
              role: 'student',
              createdAt: now,
              updatedAt: now,
            );
            
            await FirestoreService.createUser(
              userCredential.user!.uid,
              userData.toJson(),
            );
            
            _currentUser = userData;
          }
          
          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);
          await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
          await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          
          // Set auth token for API calls (wrapped in try-catch to handle plugin issues)
          try {
            final token = await userCredential.user!.getIdToken();
            if (token != null) {
              ApiService.setAuthToken(token);
            }
          } catch (tokenError) {
            print('Warning: Could not get ID token: $tokenError');
            // Continue anyway - token is not critical for basic functionality
          }
        } catch (postAuthError) {
          print('Warning: Error after authentication: $postAuthError');
          // Even if there's an error loading user data, authentication succeeded
          // Create a basic user object
          if (_currentUser == null) {
            final now = DateTime.now();
            _currentUser = UserModel(
              id: userCredential.user!.uid,
              email: email,
              name: email.split('@')[0],
              role: 'student',
              createdAt: now,
              updatedAt: now,
            );
            
            // Save login state
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // If authentication succeeded but there was an error after, still return success
      if (userCredential?.user != null) {
        print('Login succeeded despite error: $e');
        // Ensure we have a user object
        if (_currentUser == null) {
          final now = DateTime.now();
          _currentUser = UserModel(
            id: userCredential!.user!.uid,
            email: email,
            name: email.split('@')[0],
            role: 'student',
            createdAt: now,
            updatedAt: now,
          );
          
          // Save login state
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          } catch (_) {}
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      print('Login error: $e');
      _errorMessage = 'An error occurred during login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'student',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    UserCredential? userCredential;

    try {
      // Create Firebase Auth user
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          // Create user document in Firestore
          final now = DateTime.now();
          final userData = UserModel(
            id: userCredential.user!.uid,
            email: email,
            name: name,
            role: role,
            phone: phone,
            createdAt: now,
            updatedAt: now,
          );

          await FirestoreService.createUser(
            userCredential.user!.uid,
            userData.toJson(),
          );

          _currentUser = userData;

          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);
          await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
          await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);

          // Set auth token (wrapped in try-catch to handle plugin issues)
          try {
            final token = await userCredential.user!.getIdToken();
            if (token != null) {
              ApiService.setAuthToken(token);
            }
          } catch (tokenError) {
            print('Warning: Could not get ID token: $tokenError');
            // Continue anyway - token is not critical for basic functionality
          }
        } catch (postAuthError) {
          print('Warning: Error after registration: $postAuthError');
          // Even if there's an error saving user data, registration succeeded
          // Create a basic user object
          if (_currentUser == null) {
            final now = DateTime.now();
            _currentUser = UserModel(
              id: userCredential.user!.uid,
              email: email,
              name: name,
              role: role,
              phone: phone,
              createdAt: now,
              updatedAt: now,
            );
            
            // Save login state
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to create user';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // If authentication succeeded but there was an error after, still return success
      if (userCredential?.user != null) {
        print('Registration succeeded despite error: $e');
        // Ensure we have a user object
        if (_currentUser == null) {
          final now = DateTime.now();
          _currentUser = UserModel(
            id: userCredential!.user!.uid,
            email: email,
            name: name,
            role: role,
            phone: phone,
            createdAt: now,
            updatedAt: now,
          );
          
          // Save login state
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          } catch (_) {}
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      print('Registration error: $e');
      _errorMessage = 'An error occurred during registration: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    UserCredential? userCredential;

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        try {
          // Get user data from Firestore
          final doc = await FirestoreService.getUser(userCredential.user!.uid);
          
          if (doc.exists) {
            _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          } else {
            // If user document doesn't exist, create it with Google account info
            final now = DateTime.now();
            final userData = UserModel(
              id: userCredential.user!.uid,
              email: userCredential.user!.email ?? '',
              name: userCredential.user!.displayName ?? 'User',
              role: 'student',
              photoUrl: userCredential.user!.photoURL,
              createdAt: now,
              updatedAt: now,
            );
            
            await FirestoreService.createUser(
              userCredential.user!.uid,
              userData.toJson(),
            );
            
            _currentUser = userData;
          }
          
          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);
          await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
          await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          
          // Set auth token for API calls
          try {
            final token = await userCredential.user!.getIdToken();
            if (token != null) {
              ApiService.setAuthToken(token);
            }
          } catch (tokenError) {
            print('Warning: Could not get ID token: $tokenError');
          }
        } catch (postAuthError) {
          print('Warning: Error after Google authentication: $postAuthError');
          // Create a basic user object if there's an error
          if (_currentUser == null) {
            final now = DateTime.now();
            _currentUser = UserModel(
              id: userCredential.user!.uid,
              email: userCredential.user!.email ?? '',
              name: userCredential.user!.displayName ?? 'User',
              role: 'student',
              photoUrl: userCredential.user!.photoURL,
              createdAt: now,
              updatedAt: now,
            );
            
            // Save login state
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Google Sign-In failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // If authentication succeeded but there was an error after, still return success
      if (userCredential?.user != null) {
        print('Google Sign-In succeeded despite error: $e');
        if (_currentUser == null) {
          final now = DateTime.now();
          _currentUser = UserModel(
            id: userCredential!.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'User',
            role: 'student',
            photoUrl: userCredential.user!.photoURL,
            createdAt: now,
            updatedAt: now,
          );
          
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.keyIsLoggedIn, true);
            await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
            await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
          } catch (_) {}
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      print('Google Sign-In error: $e');
      _errorMessage = 'An error occurred during Google Sign-In: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      ApiService.clearAuthToken();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );

      await FirestoreService.updateUser(
        _currentUser!.id,
        updatedUser.toJson(),
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
