import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nature_map/methods/enums.dart';

Future<GoogleSigninResults> signInWithGoogle() async {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  try {
    if (await _googleSignIn.isSignedIn()) {
      return GoogleSigninResults.alreadySignedIn;
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      var u = await FirebaseAuth.instance.signInWithCredential(credential);

      return GoogleSigninResults.signInCompleted;
    }
  } catch (e) {
    print("Error in Google sign in: $e");
    return GoogleSigninResults.signInNotCompleted;
  }
}

Future<bool> logOut() async {
  try {
    print('Google Log out');

    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  } catch (e) {
    print('Error in Google Log Out: ${e.toString()}');
    return false;
  }
}
