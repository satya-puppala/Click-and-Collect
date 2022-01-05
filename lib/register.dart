import 'package:clickcollect/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/startScreen.dart';
import 'login_screen.dart';
import 'services/authService.dart';
import 'package:clickcollect/login_screen.dart';

class Register extends StatefulWidget {
  static const id = 'register';

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //key for form validation
  final _formKey = GlobalKey<FormState>();

  //instance of AuthServices to allow the use of method in the class
  final AuthService _auth = AuthService();

  //variables for this page
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool _autoValidate = false;

  //Function for Textfield used multiple times
  TextFormField regTextField(TextEditingController input, String hint,
      Function validator, TextInputType keyboard, bool obscure) {
    return TextFormField(
        textAlign: TextAlign.center,
        keyboardType: keyboard,
        decoration: InputDecoration(hintText: hint),
        obscureText: obscure,
        validator: validator,
        onChanged: (String value) {
          setState(() => input.text = value.trim());
        });
  }

  Text reusableText (String text, double fontSize){
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: Colors.white),
    );
  }

  // Form validation methods
  String validateName(String value) {
    if (value.isEmpty)
      return 'Enter name';
    else
      return null;
  }

  String validateMobile(String value) {
    if (value.length < 11)
      return 'Mobile numbers must be 11 digit';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+'
        r'(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.'
        r'[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value.trim()))
      return 'Enter a valid email';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return 'Invalid password format';
    else
      return null;
  }

  String validatePasswordMatch(String value) {
    if (value != password.text) {
      return 'Password is not matching';
    } else if (confirmPassword.text.isEmpty)
      return 'Invalid Password Format';
    else
      return null;
  }

  //method to register the user
  void register() async {
    //checking if textfields are entered correctly, using validator,
    // if they are then calling register methods to create user.
    if (_formKey.currentState.validate()) {
      //starting load screen while user is registered
      dynamic result = await _auth.registerWithEmailAndPassword(
        email.text,
        password.text,
        firstName.text,
        lastName.text,
        phoneNumber.text,
      );

      // if register fails, end load screen and show error message
      if (result is PlatformException) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text('Email Already in use'),
              content: new Text('Try logging in or user different email to register'),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        //when user is created take them back to home screen.
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text('Account Registered'),
              content: new Text('Account has been succesfully registered.'),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text('Login'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        Navigator.popAndPushNamed(context, LoginScreen.id);
      }
    } else {
      _autoValidate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
          leading: IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, StartScreen.id);
              },
              icon: Icon(Icons.arrow_back_ios),color: Colors.cyan,),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(LoginScreen.id);
                },
                child: Text('Login',style: TextStyle(color: Colors.lightBlue),))
          ],
          title: Text('Register Account',style: TextStyle(
            color: Colors.black
          ),)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: Column(
              children: <Widget>[
                Card(
                  child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          regTextField(firstName, 'First Name', validateName,
                              TextInputType.text, false),
                          regTextField(lastName, 'Last Name', validateName,
                              TextInputType.text, false),
                          regTextField(phoneNumber, 'Phone Number',
                              validateMobile, TextInputType.phone, false),
                          regTextField(email, 'Email', validateEmail,
                              TextInputType.emailAddress, false),
                          regTextField(password, 'Password', validatePassword,
                              TextInputType.text, true),
                          regTextField(confirmPassword, 'Confirm Password',
                              validatePasswordMatch, TextInputType.text, true),
                        ],
                      )),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  child: Text('Register',),
                  color: Colors.cyan,
                  onPressed: () async {
                    register();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
