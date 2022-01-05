import 'package:clickcollect/ShakeScreen.dart';
import 'package:clickcollect/mybag.dart';
import 'package:clickcollect/components/BagObj.dart';
import 'package:clickcollect/components/ProductObj.dart';
import 'package:clickcollect/product.dart';
import 'package:clickcollect/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user.dart';
import 'package:clickcollect/login_screen.dart';
import 'package:clickcollect/main_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clickcollect/services/authService.dart';
import 'package:intl/intl.dart';

class StartScreen extends StatefulWidget {
  static const String id = 'startScreen';
  @override
  _StartScreenState createState() => _StartScreenState();
}
List<PresentData> completed = new List();
String orders = '';
String tot = '';
bool check = false;
class _StartScreenState extends State<StartScreen> {
  String hour = new DateFormat.H().format(new DateTime.now());
  String minutes = new DateFormat.m().format(new DateTime.now());
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    List<PresentData> presentData = new List();
    final AuthService _auth = AuthService();
    if(user != null && user.uid == '4pIhgjy6M8dySpBaCfJvUsQyeLG3')
    {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          leading: Container(),
          title: Center(child: Text('Orders',style: TextStyle(
              color: Colors.black54
          ),)),
          actions: [
            FlatButton(
              onPressed: (){
                _auth.signOutFunction();
                Navigator.popAndPushNamed(context, LoginScreen.id);
              },
              child: Text('Logout'),
            )
          ],
        ),
        body: StreamBuilder(
            stream: Firestore.instance.collection('Orders').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column();
              }
              final cloud = snapshot.data.documents;
              for(var items in cloud)
              {
                PresentData value = new PresentData(imgPath: items.data['Items']['imgPath'],
                    name: items.data['Items']['names'],
                    quantity: items.data['Items']['quantity'],
                    price: items.data['Items']['price'],
                    time: items.data['timestamp'],total: items.data['totalPrice'],uid: items.data['uid']
                    ,hour: items.data['hour'],min: items.data['minute']);
                if(presentData.length < cloud.length && !presentData.contains(value))
                  presentData.add(value);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: presentData.length,
                      itemBuilder: (context, index) {
                        int ind = index +1;
                        orders = '';
                        for(int k = 0; k< presentData.elementAt(index).name.length;k++) {
                          int j = k +1;
                          orders = orders + '$j) ' + 'Item: ' + presentData
                              .elementAt(index)
                              .name
                              .elementAt(k)
                              + ', Price: ' + presentData
                              .elementAt(index)
                              .price
                              .elementAt(k) + ', Quantity: ' +
                              presentData
                                  .elementAt(index)
                                  .quantity
                                  .elementAt(k) + '\n';
                        }
                        tot = presentData.elementAt(index).total.toString();
                        return Card(
                          child: ListTile(
                            leading: Text(ind.toString()+') ')
                            ,title: Text(presentData.elementAt(index).time.toDate().day.toString()+
                              '/'+ presentData.elementAt(index).time.toDate().month.toString()+'/'+
                              presentData.elementAt(index).time.toDate().year.toString()),
                            subtitle: Column(
                              children: [
                                Text(orders +'\n' +'Total Price: ' +tot)
                              ],
                            ),
                            trailing: FlatButton.icon(icon: Icon(Icons.add),
                              label: Text('Completed'),
                              color: Colors.black54,
                              onPressed: () async{
                                 DatabaseService(uid: user.uid).CompletedOrders(presentData.elementAt(index).imgPath
                                    ,presentData.elementAt(index).name,presentData.elementAt(index).price,
                                    presentData.elementAt(index).quantity,presentData.elementAt(index).time,
                                    presentData.elementAt(index).hour,presentData.elementAt(index).min,
                                    presentData.elementAt(index).total,presentData.elementAt(index).uid);
                               await Firestore.instance.collection('User')
                                    .document(presentData.elementAt(index).uid).collection('pastOrders')
                                    .document(presentData.elementAt(index).hour
                                    +':'+presentData.elementAt(index).min).setData({
                                  'Items' :{
                                    'imgPath': presentData.elementAt(index).imgPath,
                                    'names': presentData.elementAt(index).name,
                                    'price': presentData.elementAt(index).price,
                                    'quantity': presentData.elementAt(index).quantity,
                                  },
                                  'hour': presentData.elementAt(index).hour,
                                  'minute': presentData.elementAt(index).min,
                                  'timestamp': presentData.elementAt(index).time,
                                  'totalPrice': double.parse(tot),
                                  'status': "Order is ready to collect"});
                               await Firestore.instance.runTransaction((transaction) =>
                                   transaction.delete(snapshot.data.documents[index].reference));
                               presentData.removeAt(index);
                              },),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
        ),
        persistentFooterButtons: <Widget>[
          FlatButton.icon(
            label: Text('Current Orders'),
            icon: Icon(Icons.fastfood),
            onPressed: () {
              Navigator.popAndPushNamed(context, StartScreen.id);
            },
          ),
          FlatButton.icon(
            label: Text('Prepared Orders'),
            icon: Icon(Icons.beenhere),
            onPressed: () {
              print(completed.length);
              Navigator.popAndPushNamed(context, PrepedOrders.id);
            },
          ),
        ],
      );
    }

    //if user is not logged in go to the Login screen
    else if (user == null){
      return LoginScreen();
    }
    else if(user.uid != '4pIhgjy6M8dySpBaCfJvUsQyeLG3'){
        return MainMenu();
    }
  }
  getOrderData(String uid) async{
    BagObj object;
    var cloud = await Firestore.instance.collection('User').document(uid).collection('setFood').getDocuments();
    final orderData = cloud.documents;
    for(var items in orderData)
      {
        if(items.data['hour'] == hour) {
          check = true;
        }
      }
  }
}

class PresentData{
  final List<dynamic> imgPath;
  final List<dynamic> name;
  final List<dynamic> quantity;
  final List<dynamic> price;
  final Timestamp time;
  final double total;
  final String uid;
  final String hour;
  final String min;
  PresentData({this.imgPath,this.name,this.quantity,this.price,
    this.time,this.total,this.uid,this.hour,this.min});
}

class PrepedOrders extends StatefulWidget {
  static const String id = 'PrepedOrders';
  @override
  _PrepedOrdersState createState() => _PrepedOrdersState();
}

class _PrepedOrdersState extends State<PrepedOrders> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.cyan,
       leading: Container(),
         title: Center(child: Text('Completed Orders',style: TextStyle(
             color: Colors.black54
         ),)),
       ),
       body: StreamBuilder(
         stream: Firestore.instance.collection('CompletedOrders').snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return Column();
    }
    final cloud = snapshot.data.documents;
    for(var items in cloud)
    {
    PresentData value = new PresentData(imgPath: items.data['Items']['imgPath'],
    name: items.data['Items']['names'],
    quantity: items.data['Items']['quantity'],
    price: items.data['Items']['price'],
    time: items.data['timestamp'],total: items.data['totalPrice'],uid: items.data['uid']
    ,hour: items.data['hour'],min: items.data['minute']);
    if(completed.length < cloud.length && !completed.contains(value))
    completed.add(value);
    }
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Expanded(
    child: ListView.builder(
    itemCount: completed.length,
    itemBuilder: (context, index) {
    int ind = index +1;
    orders = '';
    for(int k = 0; k< completed.elementAt(index).name.length;k++) {
    int j = k +1;
    orders = orders + '$j) ' + 'Item: ' + completed
        .elementAt(index)
        .name
        .elementAt(k)
    + ', Price: ' + completed
        .elementAt(index)
        .price
        .elementAt(k) + ', Quantity: ' +
    completed
        .elementAt(index)
        .quantity
        .elementAt(k) + '\n';
    }
    tot = completed.elementAt(index).total.toString();
    return Card(
    child: ListTile(
    leading: Text(ind.toString()+') ')
    ,title: Text(completed.elementAt(index).time.toDate().day.toString()+
    '/'+ completed.elementAt(index).time.toDate().month.toString()+'/'+
    completed.elementAt(index).time.toDate().year.toString()),
    subtitle: Column(
    children: [
    Text(orders +'\n' +'Total Price: ' +tot)
    ],
    ),
    trailing: FlatButton.icon(icon: Icon(Icons.add),
    label: Text('Collected'),
    color: Colors.teal,
    onPressed: () async{
    await Firestore.instance.collection('User')
        .document(completed.elementAt(index).uid).collection('pastOrders')
        .document(completed.elementAt(index).hour
    +':'+completed.elementAt(index).min).setData({
    'Items' :{
    'imgPath': completed.elementAt(index).imgPath,
    'names': completed.elementAt(index).name,
    'price': completed.elementAt(index).price,
    'quantity': completed.elementAt(index).quantity,
    },
    'hour': completed.elementAt(index).hour,
    'minute': completed.elementAt(index).min,
    'timestamp': completed.elementAt(index).time,
    'totalPrice': double.parse(tot),
    'status': "Order has been collected"});
    await Firestore.instance.runTransaction((transaction) =>
        transaction.delete(snapshot.data.documents[index].reference));
    completed.removeAt(index);
    },),
    ),
    );
    },
    ),
    ),
    ],
    );
    }
       ),
       persistentFooterButtons: <Widget>[
         FlatButton.icon(
           label: Text('Current Orders'),
           icon: Icon(Icons.fastfood),
           onPressed: () {
             Navigator.popAndPushNamed(context, StartScreen.id);
           },
         ),
         FlatButton.icon(
           label: Text('Prepared Orders'),
           icon: Icon(Icons.beenhere),
           onPressed: () {
             print(completed.length);
             Navigator.popAndPushNamed(context, PrepedOrders.id);
           },
         ),
       ],
     );
  }
}

