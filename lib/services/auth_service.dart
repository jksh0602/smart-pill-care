// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // 현재 로그인 유저 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------
  // SNR 고유 코드 생성: "SNR-XXXX" 형태 (대문자+숫자 4자리)
  // --------------------------------------------------
  String _generateSnrCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 헷갈리는 문자 제외
    final random = List.generate(4, (_) {
      final idx = DateTime.now().microsecondsSinceEpoch % chars.length;
      return chars[idx];
    });
    return 'SNR-${random.join()}';
  }

  // SNR 코드가 이미 존재하는지 확인 후 고유 코드 반환
  Future<String> _getUniqueSnrCode() async {
    String code;
    bool exists;
    do {
      code = _generateSnrCode();
      final query = await _db
        .collection('users')
        .where('snrCode', isEqualTo: code)
        .get();
      exists = query.docs.isNotEmpty;
    } while (exists);
    return code;
  }

  // --------------------------------------------------
  // 어르신 회원가입
  // --------------------------------------------------
  Future<AppUser> registerElder({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final snrCode = await _getUniqueSnrCode();

    final user = AppUser(
      uid: uid,
      email: email,
      name: name,
      role: UserRole.elder,
      snrCode: snrCode,
      age: age,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  // --------------------------------------------------
  // 보호자 회원가입
  // --------------------------------------------------
  Future<AppUser> registerGuardian({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final snrCode = await _getUniqueSnrCode();

    final user = AppUser(
      uid: uid,
      email: email,
      name: name,
      role: UserRole.guardian,
      snrCode: snrCode,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  // --------------------------------------------------
  // 로그인 (공통)
  // --------------------------------------------------
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await getUser(cred.user!.uid);
  }

  // --------------------------------------------------
  // 유저 정보 조회
  // --------------------------------------------------
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  // SNR 코드로 어르신 조회 (보호자가 환자 추가할 때 사용)
  Future<AppUser?> getUserBySnrCode(String snrCode) async {
    final query = await _db
      .collection('users')
      .where('snrCode', isEqualTo: snrCode.toUpperCase())
      .where('role', isEqualTo: 'elder')
      .get();
    if (query.docs.isEmpty) return null;
    return AppUser.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  // --------------------------------------------------
  // 보호자 → 어르신 연결 (SNR 코드 입력)
  // --------------------------------------------------
  Future<void> linkElderToGuardian({
    required String guardianUid,
    required String elderSnrCode,
  }) async {
    await _db.collection('users').doc(guardianUid).update({
      'linkedElderCodes': FieldValue.arrayUnion([elderSnrCode.toUpperCase()]),
    });
  }

  // --------------------------------------------------
  // 로그아웃
  // --------------------------------------------------
  Future<void> signOut() => _auth.signOut();
}
