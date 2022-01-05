import 'package:clickcollect/main_menu.dart';
import 'package:flutter/material.dart';

class Alert{
  alertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
          title: Text('Succesful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check,size: 50,color: Colors.teal,),
              Text('Registration Succesful'),
              FlatButton(
                child: Text('Continue'),
                onPressed: (){Navigator.pushNamed(context, MainMenu.id);},
              )
            ],
          )
      );
    });
  }
}