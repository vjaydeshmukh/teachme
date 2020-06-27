import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:teachme/models/user.dart';
import 'package:teachme/services/auth_service.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }

    return User(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        isVerified: user.isEmailVerified);
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  @override
  Future<User> signInAnonymously() async {
    final AuthResult authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final AuthResult authResult = await _firebaseAuth
        .signInWithCredential(EmailAuthProvider.getCredential(
      email: email,
      password: password,
    ));
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    final AuthResult authResult = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    // Sending email verification
    if (authResult.user != null) await authResult.user.sendEmailVerification();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<User> signInWithEmailAndLink({String email, String link}) async {
    final AuthResult authResult =
        await _firebaseAuth.signInWithEmailAndLink(email: email, link: link);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<bool> isSignInWithEmailLink(String link) async {
    return await _firebaseAuth.isSignInWithEmailLink(link);
  }

  @override
  Future<void> sendSignInWithEmailLink({
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleID,
    @required String androidPackageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) async {
    return await _firebaseAuth.sendSignInWithEmailLink(
      email: email,
      url: url,
      handleCodeInApp: handleCodeInApp,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: androidInstallIfNotAvailable,
      androidMinimumVersion: androidMinimumVersion,
    );
  }

  @override
  Future<User> signInWithGoogle() async {}

  @override
  Future<User> signInWithFacebook() async {
    // final FacebookLogin facebookLogin = FacebookLogin();
    // final FacebookLoginResult result = await facebookLogin.logIn(<String>['public_profile']);
    // if (result.accessToken != null) {
    //   final AuthResult authResult = await _firebaseAuth.signInWithCredential(
    //     FacebookAuthProvider.getCredential(accessToken: result.accessToken.token),
    //   );
    //   return _userFromFirebase(authResult.user);
    // } else {
    //   throw PlatformException(code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    // }
  }

  Future<void> verifyPhoneNumber(
          String phoneNumber, Function(String, [int]) smsOTPSent) =>
      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: (AuthCredential phoneAuthCredential) {
          print(phoneAuthCredential.toString() + "lets make this work");
        },
        verificationFailed: (AuthException exception) {
          print('${exception.message} + something is wrong');
        },
        codeSent: smsOTPSent,
        codeAutoRetrievalTimeout: (String verId) {
          //Starts the phone number verification process for the given phone number.
          //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
        },
      );

  @override
  Future<User> signInWithPhoneNumber(String verificationId, String otp) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }

  @override
  Future<void> signOut() async {
    //final GoogleSignIn googleSignIn = GoogleSignIn();
    //await googleSignIn.signOut();
    //final FacebookLogin facebookLogin = FacebookLogin();
    //await facebookLogin.logOut();
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}
}
