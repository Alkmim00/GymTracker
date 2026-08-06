import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Create account
  Future<User?> signUp(
    String email,
    String password,
  ) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  // Login
  Future<User?> login(
    String email,
    String password,
  ) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // guest
  Future<User?> signInGuest() async {
    UserCredential result = await _auth.signInAnonymously();

    return result.user;
  }

  /// Upgrades the current anonymous (guest) user to a full
  /// email/password account by linking credentials to the SAME uid.
  /// This is deliberately different from signUp() — signUp() creates
  /// a brand new uid, which would orphan any workouts the guest
  /// already created. linkWithCredential keeps the uid, so existing
  /// Firestore data under users/{uid} just carries over.
  ///
  /// Throws FirebaseAuthException on failure (e.g. email already in
  /// use, weak password) — caller is expected to catch and show a
  /// message.
  Future<User?> upgradeGuestAccount(
    String email,
    String password,
  ) async {
    final user = _auth.currentUser;

    if (user == null || !user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'no-guest-session',
        message: 'No guest session to upgrade.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    final result = await user.linkWithCredential(credential);

    return result.user;
  }

  // Auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}