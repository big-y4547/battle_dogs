import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authServies = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChnages => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> changePassword({
    required String email,
    required String currentpassword,
    required String newPassword,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentpassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
