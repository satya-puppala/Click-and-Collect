import 'package:firebase_auth/firebase_auth.dart';
import 'package:clickcollect/services/database.dart';
import 'package:clickcollect/components/user.dart';

class AuthService{
final FirebaseAuth _auth = FirebaseAuth.instance;

User _FirebaseUser(FirebaseUser user)
{
  return user != null ? User(uid: user.uid, email: user.email) : null;
}

Stream<User> get user{
  return _auth.onAuthStateChanged.map(_FirebaseUser);
}
Future signInWithEmailAndPassword(String email, String password) async{
  try{
    AuthResult result = await _auth.signInWithEmailAndPassword
      (email: email, password: password);
    FirebaseUser user = result.user;
    return _FirebaseUser(user);
  }catch(e){
    print(e.toString());
    return e;
  }
}
Future registerWithEmailAndPassword(String email, String password,
    String firstName, String lastName, String phoneNumber,
    ) async{
  try{
    //creating a new user account on firebase with email and password.
    AuthResult result = await _auth.createUserWithEmailAndPassword
      (email: email, password: password);
    FirebaseUser user = result.user;

    //setting display name
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = firstName +' ' + lastName;
    await user.updateProfile(updateInfo);

    //create user on the database
    await DatabaseService(uid: user.uid)
        .updateUserInformation(firstName, lastName, email, phoneNumber);

    await DatabaseService(uid: user.uid).initialRatings();

    await _auth.signOut();


    return _FirebaseUser(user);
  }catch(e){
    print(e.toString());
    return e;
  }
}
// signOut function
Future signOutFunction () async {
  try{
    await FirebaseAuth.instance.signOut();
    return await _auth.signOut();
  }
  catch(e){
    print(e.toString());
    return null;
  }
}
Future resetPassword(String email) async
{try {
  return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
catch(e){
  return e;
}}
}