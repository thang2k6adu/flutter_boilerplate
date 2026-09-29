import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pp191225/core/core.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  final GoogleSignIn _gsi = GoogleSignIn.instance;

  final String webClientId = ApiConstants.webClientId;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _gsi.initialize(clientId: kIsWeb ? null : webClientId);
    _initialized = true;
  }

  Future<String?> signInWithGoogle() async {
    await _ensureInitialized();
    try {
      if (!_gsi.supportsAuthenticate()) return null;
      // Isolate heavy logic to light isolate
      return await Future.microtask(() async {
        final GoogleSignInAccount account = await _gsi.authenticate();

        final googleAuth = account.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) return null;

        final credential = GoogleAuthProvider.credential(idToken: idToken);
        final userCred = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        return await userCred.user?.getIdToken(true);
      });
    } on GoogleSignInException catch (e) {
      throw Exception('Google Sign-In failed: $e');
    } catch (e) {
      throw Exception('Unexpected Google Sign-In error: $e');
    }
  }

  Future<String> signInWithEmailAndPassword({
    required String username,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: username, password: password);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Không thể đăng nhập: Firebase user rỗng.');
      }
      // Lấy Firebase ID Token
      final idToken = await user.getIdToken(true);
      if (idToken == null) {
        throw Exception('Không thể đăng nhập: Firebase user rỗng.');
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e, 'Đăng nhập thất bại, vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định khi đăng nhập: $e');
    }
  }

  /// Tạo tài khoản email/password trên Firebase và trả về Firebase ID Token.
  Future<String> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Không thể đăng ký: Firebase user rỗng.');
      }

      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      // Refresh để token mang theo tên vừa cập nhật
      final idToken = await user.getIdToken(true);
      if (idToken == null) {
        throw Exception('Không thể đăng ký: không lấy được ID Token.');
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e, 'Đăng ký thất bại, vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định khi đăng ký: $e');
    }
  }

  FirebaseAuthException _mapAuthError(FirebaseAuthException e, String fallback) {
    final message = switch (e.code) {
      'user-not-found' => 'Không tìm thấy người dùng với email này.',
      'wrong-password' ||
      'invalid-credential' => 'Email hoặc mật khẩu không đúng.',
      'invalid-email' => 'Email không hợp lệ.',
      'user-disabled' => 'Tài khoản này đã bị vô hiệu hóa.',
      'email-already-in-use' => 'Email này đã được đăng ký.',
      'weak-password' => 'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
      'too-many-requests' => 'Thao tác quá nhiều lần, vui lòng thử lại sau.',
      'network-request-failed' => 'Không có kết nối mạng.',
      _ => e.message ?? fallback,
    };
    return FirebaseAuthException(code: e.code, message: message);
  }

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google
      await _gsi.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }
}
