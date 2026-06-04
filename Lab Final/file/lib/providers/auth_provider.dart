import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/helpers.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _authError;
  String? _authMessage;

  AuthProvider() {
    loadCurrentUser();
  }

  bool get isLoading => _isLoading;
  String? get authError => _authError;
  String? get authMessage => _authMessage;
  User? get currentUser => _currentUser;

  String get displayName {
    final name =
        _profileData?['full_name'] ?? _currentUser?.userMetadata?['full_name'];
    if (name != null && name.toString().isNotEmpty) {
      return name.toString();
    }
    final email = _currentUser?.email;
    if (email != null && email.contains('@gmail.com')) {
      return email.split('@gmail.com').first;
    }
    return 'New Player';
  }

  String get email => _currentUser?.email ?? '';
  int get points =>
      int.tryParse(_profileData?['points']?.toString() ??
          _currentUser?.userMetadata?['points']?.toString() ??
          '0') ??
      0;
  int get level =>
      int.tryParse(_profileData?['level']?.toString() ??
          _currentUser?.userMetadata?['level']?.toString() ??
          '1') ??
      1;
  int get streak =>
      int.tryParse(_profileData?['streak']?.toString() ??
          _currentUser?.userMetadata?['streak']?.toString() ??
          '0') ??
      0;
  int get solved =>
      int.tryParse(_profileData?['solved']?.toString() ??
          _currentUser?.userMetadata?['solved']?.toString() ??
          '0') ??
      0;
  int get badges =>
      int.tryParse(_profileData?['badges']?.toString() ??
          _currentUser?.userMetadata?['badges']?.toString() ??
          '0') ??
      0;
  String get avatarUrl =>
      _profileData?['avatar_url']?.toString() ??
      _currentUser?.userMetadata?['avatar_url']?.toString() ??
      '';

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = Supabase.instance.client.auth.currentUser;
      _profileData = null;

      if (_currentUser != null) {
        _profileData = await _authService.getProfile(_currentUser!.id);
      }
    } catch (e) {
      print('Error loading current user: $e');
    }

    notifyListeners();
  }

  Future<void> updateUserStats({
    int? points,
    int? level,
    int? streak,
    int? badges,
    int? solved,
  }) async {
    final data = <String, dynamic>{};
    if (points != null) data['points'] = points;
    if (level != null) data['level'] = level;
    if (streak != null) data['streak'] = streak;
    if (badges != null) data['badges'] = badges;
    if (solved != null) data['solved'] = solved;

    if (data.isEmpty) return;

    await _authService.updateUserMetadata(data);
    await loadCurrentUser();
  }

  int _calculateBadgeCount(int solvedQuestions) {
    const badgeThresholds = [10, 20, 50, 70, 100, 120, 150];
    return badgeThresholds
        .where((threshold) => solvedQuestions >= threshold)
        .length;
  }

  Future<void> addSolvedQuestions(int count) async {
    final newSolved = solved + count;
    final newBadges = _calculateBadgeCount(newSolved);
    await updateUserStats(solved: newSolved, badges: newBadges);
  }

  Future<void> addXp(int xp) async {
    final newPoints = points + xp;
    final newLevel = calculateLevel(newPoints);
    await updateUserStats(points: newPoints, level: newLevel);
  }

  Future<bool> signUp(
      {required String email,
      required String password,
      required String name}) async {
    _authError = null;
    _authMessage = null;
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.signUp(email, password, name);
      await loadCurrentUser();

      if (response == null) {
        _authError = 'Unable to create account. Please try again.';
        return false;
      }

      if (response.session == null) {
        _authMessage =
            'Account created! You can now log in or wait a few minutes to confirm your email.';
      } else {
        _authMessage = 'Account created successfully! Logging you in...';
      }
      return true;
    } on AuthApiException catch (e) {
      if (e.code == 'over_email_send_rate_limit' ||
          e.message.contains('over_email_send_rate_limit')) {
        _authMessage =
            'Email confirmation temporarily unavailable. You can still create an account - try logging in. If that doesn\'t work, please wait a few minutes and try again.';
        _authError = null; // Don't show as error, just info
        // Try to create account anyway
        return true;
      } else if (e.code == 'user_already_exists') {
        _authMessage = 'Account already exists! Trying to log you in...';
        return true;
      } else {
        _authError = e.message;
      }
      return false;
    } on AuthException catch (e) {
      _authError = e.message;
      return false;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _authError = null;
    _authMessage = null;
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.signIn(email, password);
      await loadCurrentUser();

      if (response == null || response.session == null) {
        _authError = 'Unable to login. Please check your credentials.';
        return false;
      }
      return true;
    } on AuthApiException catch (e) {
      _authError = e.message;
      return false;
    } on AuthException catch (e) {
      _authError = e.message;
      return false;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _authError = null;
    _authMessage = null;
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.resetPassword(email);
      _authMessage = 'Password reset link sent to $email.';
      return true;
    } on AuthApiException catch (e) {
      _authError = e.message;
      return false;
    } on AuthException catch (e) {
      _authError = e.message;
      return false;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({required String password}) async {
    _authError = null;
    _authMessage = null;
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updatePassword(password);
      _authMessage = 'Password updated successfully.';
      return true;
    } on AuthApiException catch (e) {
      _authError = e.message;
      return false;
    } on AuthException catch (e) {
      _authError = e.message;
      return false;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
      {required String name, String avatarUrl = ''}) async {
    _authError = null;
    _authMessage = null;
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateProfile(name, avatarUrl);
      await loadCurrentUser();
      _authMessage = 'Profile updated successfully.';
      return true;
    } on AuthApiException catch (e) {
      _authError = e.message;
      return false;
    } on AuthException catch (e) {
      _authError = e.message;
      return false;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
