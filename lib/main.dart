import 'package:clickcollect/PastOrders.dart';
import 'package:clickcollect/ShakeScreen.dart';
import 'package:clickcollect/components/startScreen.dart';
import 'package:clickcollect/register.dart';
import 'package:clickcollect/services/authService.dart';
import 'package:clickcollect/setOrders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';
import 'login_screen.dart';
import 'main_menu.dart';
import 'mybag.dart';
import 'product.dart';
import 'components/user.dart';


void main() => runApp(new MaterialApp(home:MyApp(),));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SplashScreen(
        seconds: 5,
        backgroundColor: Colors.deepOrange,
        image: Image.asset('images/Logo.png'),
        loaderColor: Colors.white,
        navigateAfterSeconds: Routes(),
        photoSize: 200,
      ),
    );
  }
}
class Routes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        initialRoute: StartScreen.id,
        routes: {
          ShakeScreen.id: (context) => ShakeScreen(),
          StartScreen.id: (context) => StartScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          Register.id: (context) => Register(),
          MainMenu.id: (context) => MainMenu(),
          MyProduct.id: (context) => MyProduct(),
          MyBag.id: (context) => MyBag(),
          PastOrders.id: (context)=> PastOrders(),
          PrepedOrders.id : (context) => PrepedOrders(),
          SetOrders.id : (context) => SetOrders(),
        },
      ),
    );
  }
}
