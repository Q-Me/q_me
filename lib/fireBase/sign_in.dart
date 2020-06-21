import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
handleSignOut() {
  _googleSignIn.disconnect();
  _googleSignIn.signOut();
}
signInWithGoogle() async {
  try {
    var data = await _googleSignIn.signIn();
    return data;
  } catch (error) {
    print(error);
  }
// final FirebaseAuth _auth = FirebaseAuth.instance;
// final GoogleSignIn googleSignIn = GoogleSignIn();
//   print("step-1");
//   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//   final GoogleSignInAuthentication googleSignInAuthentication =
//       await googleSignInAccount.authentication;
//   print("step-2-1 ${googleSignInAuthentication}");

//   final AuthCredential credential = GoogleAuthProvider.getCredential(
//     accessToken: googleSignInAuthentication.accessToken,
//     idToken: googleSignInAuthentication.idToken,
//   );
// final FirebaseUser user = await _auth.signInWithCredential(credential);
//   print("step-3");
//   print(user);

//   //final AuthResult authResult = await _auth.signInWithCredential(credential);
//   //final FirebaseUser user = authResult.user;

//   assert(!user.isAnonymous);
//   assert(await user.getIdToken() != null);

//     assert(user.email != null);
//   assert(user.displayName != null);
//   assert(user.photoUrl != null);
//   name = user.displayName;
//   email = user.email;
//   imageUrl = user.photoUrl;
//   if (name.contains(" ")) {
//    name = name.substring(0, name.indexOf(" "));
// }
//   // final FirebaseUser currentUser = await _auth.currentUser();
//   // assert(user.uid == currentUser.uid);

//   return 'signInWithGoogle succeeded: $user';
}

// void signOutGoogle() async{
//   await googleSignIn.signOut();
//    googleSignIn.disconnect();
//   print("User Sign Out");
// }
 
