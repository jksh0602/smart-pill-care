// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  AppUser? _currentUser;
  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _service.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _currentUser = await _service.getUser(firebaseUser.uid);

        if (_currentUser == null) {
          _status = AuthStatus.unknown;
        } else {
          _status = AuthStatus.authenticated;
        }
      }
      notifyListeners();
    });
  }

  // 어르신 회원가입
  Future<bool> registerElder({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _service.registerElder(
        email: email, password: password, name: name, age: age,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 보호자 회원가입
  Future<bool> registerGuardian({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _service.registerGuardian(
        email: email, password: password, name: name,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } catch (e, st) {
      debugPrint('registerGuardian error: $e');
      debugPrint('stackTrace: $st');
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _service.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // SNR 코드로 어르신 조회
  Future<AppUser?> findElderBySnrCode(String code) =>
      _service.getUserBySnrCode(code);

  // 보호자 - 어르신 연결
  Future<bool> linkElder(String elderSnrCode) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      await _service.linkElderToGuardian(
        guardianUid: _currentUser!.uid,
        elderSnrCode: elderSnrCode,
      );
      // 로컬 상태 업데이트
      _currentUser = _currentUser!.copyWith(
        linkedElderCodes: [..._currentUser!.linkedElderCodes, elderSnrCode],
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use')) return '이미 사용 중인 이메일입니다.';
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) return '이메일 또는 비밀번호가 올바르지 않습니다.';
    if (msg.contains('user-not-found')) return '등록되지 않은 이메일입니다.';
    if (msg.contains('weak-password')) return '비밀번호는 6자 이상이어야 합니다.';
    if (msg.contains('invalid-email')) return '이메일 형식이 올바르지 않습니다.';
    return '오류가 발생했습니다. 다시 시도해 주세요.';
  }
}
