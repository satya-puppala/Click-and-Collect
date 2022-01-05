import 'package:clickcollect/main_menu.dart';
import 'package:clickcollect/setOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart';
import 'product.dart';
import 'package:flutter/material.dart';
import 'package:square_in_app_payments/models.dart' as card;
import 'package:square_in_app_payments/in_app_payments.dart';
import 'services/database.dart';
import 'components/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyBag extends StatefulWidget {
  static const String id = 'mybag';
  @override
  _MyBagState createState() => _MyBagState();
}

class _MyBagState extends State<MyBag> {
  String uid = '';
  String status = 'Order being prepared';
  void _pay(){
    if(bagList.isEmpty){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text('Bag is empty'),
            content: new Text('Add items to Bag'),
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
    }
    else
      {
        InAppPayments.setSquareApplicationId('sandbox-sq0idb-K2iUCxEVRBG-VKQxPwOXLA');
        InAppPayments.startCardEntryFlow(
          onCardNonceRequestSuccess: _cardNonceRequestSuccess,
          onCardEntryCancel: _cardEntryCancel,);
      }

  }
  void _cardEntryCancel(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Cancelled'),
          content: new Text('Payment has been interrupted'),
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
  }

  void _cardNonceRequestSuccess(card.CardDetails result){
      print(result.nonce);
      InAppPayments.completeCardEntry(
        onCardEntryComplete: _cardEntryComplete,
      );
  }
  void _cardEntryComplete(){
    payment();
    Navigator.popAndPushNamed(context, MainMenu.id);
  }

  void payment(){
    if(bagList.isEmpty){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text('Bag is empty'),
            content: new Text('Add items to Bag'),
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
    }
    else{
      String hour = new DateFormat.H().format(new DateTime.now());
      String minutes = new DateFormat.m().format(new DateTime.now());
      List<String> a = new List();
      List<String> b = new List();
      List<String> c = new List();
      List<String> d = new List();
      for(int i = 0; i< bagList.length;i++)
      {
        a.add(bagList.elementAt(i).obj.imgPath);
        b.add(bagList.elementAt(i).obj.name);
        c.add(bagList.elementAt(i).obj.price);
        d.add(bagList.elementAt(i).quantity.toString());
      }
      DatabaseService(uid: uid).pastOrders(a,b,c,d,
          Timestamp.now(),
          hour,
          minutes,
          totalPrice, status
      );
      DatabaseService(uid: uid).Orders(a, b, c,
          d, Timestamp.now(), hour, minutes, totalPrice,uid);
      bagList.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return  Scaffold(
      bottomSheet: Row(
        children: [
          Badge(
            badgeColor: Colors.white,
            position: BadgePosition.topLeft(top: -15, left: 180),
            badgeContent: Text(totalPrice.toString()),
            child: FlatButton.icon(
                padding: EdgeInsets.only(left: 150,top: 0,right: 0,bottom: 0),
                onPressed: (){
                  uid = user.uid;
    _pay();
                },
                icon: Icon(Icons.payment,color: Colors.deepOrange,size: 30,),
                label: Text('Pay Card')),
          ),

             Badge(
               badgeColor: Colors.white,
               position: BadgePosition.topLeft(top: -15,left: 20),
               badgeContent: Text(totalPrice.toString()),
               child: FlatButton.icon(
                  onPressed: (){
                    payment();
                      Navigator.popAndPushNamed(context, MainMenu.id);
                  },
                  icon: Icon(Icons.attach_money,color: Colors.green,size: 30,),
                  label: Text('Pay cash')),
             ),

         // FlatButton.icon(onPressed: (){Navigator.popAndPushNamed(context, SetOrders.id);},
            //  icon: Icon(Icons.phonelink_setup), label: Text('Set this order'))
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.8),
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 50,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, MainMenu.id);
            }),
        title: Center(child: Text('Bagged Items',style: TextStyle(
          color: Colors.black54
        ),)),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: bagList.length,
          itemBuilder: (context, index)
          {
            String s = bagList.elementAt(index).finalPrice.toString();
            return Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: ListTile(leading: Image.network(bagList.elementAt(index).obj.imgPath,
                    height: 45.0,
                    width: 45.0,
                  ),
                    title: GestureDetector(
                      onTap: (){
                        Navigator.popAndPushNamed(context, MyProduct.id);
                      },
                      child: Column(
                        children: [
                          Text(bagList.elementAt(index).obj.name),
                          Text('£ $s')
                        ],
                      ),
                    ),
                    trailing: IconButton(icon: Icon(Icons.remove_shopping_cart),
                      color: Colors.black54,
                      onPressed: (){
                      setState(() {
                        totalPrice = totalPrice-bagList.elementAt(index).finalPrice;
                        bagList.removeAt(index);
                      });
                      },),),
              ),
            );
          },),
      ),
      persistentFooterButtons: <Widget>[
        FlatButton.icon(
          label: Text('Mains'),
          icon: Icon(Icons.add),
          onPressed: () {
            mains = true;
            sides = false;
            drinks = false;
            Navigator.popAndPushNamed(context, MainMenu.id);
          },
        ),
        FlatButton.icon(
          label: Text('Sides'),
          icon: Icon(Icons.add),
          onPressed: () {
            mains = false;
            sides = true;
            drinks = false;
            Navigator.popAndPushNamed(context, MainMenu.id);
          },
        ),
        FlatButton.icon(
          label: Text('Drinks'),
          icon: Icon(Icons.add),
          onPressed: () {
            mains = false;
            sides = false;
            drinks = true;
            Navigator.popAndPushNamed(context, MainMenu.id);
          },
        ),
      ],
    );
  }
}
