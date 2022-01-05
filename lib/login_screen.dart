import 'package:clickcollect/components/startScreen.dart';
import 'package:clickcollect/services/authService.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController controller1 = new TextEditingController();
  final TextEditingController controller2 = new TextEditingController();
  bool test = false;
  String email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image(image: AssetImage('images/Logo.png'),height: 160,),
          TextFormField(
            controller: controller1,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.center,
            onChanged: (input) => email = input,
            onTap: (){},
            decoration: InputDecoration(
              hintText: 'Enter email',
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white,width: 40.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),

            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          TextFormField(
            controller: controller2,
            textAlign: TextAlign.center,
            obscureText: true,
            onChanged: (input) => password = input,
            decoration: InputDecoration(
              hintText: 'Enter password',
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white,width: 40.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                color: Colors.cyan,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.cyanAccent,
                onPressed: () async{
                  try{
                    if(email == null || password==null)
                    {
                      _showDialog('Enter Details', 'No details have been entered', 'Okay');
                    }
                    else if(email != null && password != null){
                      dynamic user = await _auth.signInWithEmailAndPassword(email.trim(),password.trim());
                      if (user is PlatformException) {
                        if (user.code == 'ERROR_USER_NOT_FOUND') {
                          _showDialog('Email not found', 'please registered an account', 'Okay');
                        }
                        else if(user.code == 'ERROR_WRONG_PASSWORD'){
                          _showDialog('Invalid Password', 'The entered password is wrong', 'Okay');
                          controller2.clear();
                        }
                        else if(user.code == 'ERROR_INVALID_EMAIL'){
                          _showDialog('Invalid Email', "please check the format", "Okay");
                          controller1.clear();
                        }
                        else if (user.code == 'ERROR_NETWORK_REQUEST_FAILED'){
                          _showDialog('No internet connection', "Make sure you are connected to internet", "Okay");
                        }
                      }
                      else{
                        controller1.clear();
                        controller2.clear();
                        Navigator.popAndPushNamed(context, StartScreen.id);
                      }
                    }
                  }
                  catch(e){
                    print(e.message);
                  }
                },
                child: Text(
                    'Login'
                ),
              ),
              SizedBox(width: 60,),
              FlatButton(
                color: Colors.cyan,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.cyanAccent,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Register.id);
                },
                child: Text(
                    'Register'
                ),
              )
            ],
          ),
        FlatButton(
          child: Text('Forgot password',style: TextStyle(color: Colors.red),),
          onPressed: ()async{

            dynamic result = await _auth.resetPassword(email);
            if(email != null) {
              if (result is PlatformException) {
                if (result.code == 'ERROR_USER_NOT_FOUND') {
                  _showDialog(
                      'Email not found', 'please registered an account',
                      'Okay');
                }
                else if (result.code == 'ERROR_INVALID_EMAIL') {
                  _showDialog('Email not correct', 'please enter correct email',
                      'Okay');
                }
                else if (result.code == 'ERROR_MISSING_EMAIL') {
                  _showDialog(
                      'Email not entered', 'please enter the email', 'Okay');
                }
              }
            }
          },
        )
        ],
      ),
    );
  }
  void _showDialog(String Title,String Content,String text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(Title),
          content: new Text(Content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(text),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

