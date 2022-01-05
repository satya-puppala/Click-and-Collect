import 'package:clickcollect/components/ProductObj.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/startScreen.dart';
import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'package:provider/provider.dart';
import 'components/user.dart';
import 'components/BagObj.dart';
import 'package:intl/intl.dart';
class ShakeScreen extends StatefulWidget {
  static const String id = 'ShakeScreen';
  @override
  _ShakeScreenState createState() => _ShakeScreenState();
}
String str = '';
class _ShakeScreenState extends State<ShakeScreen> with SingleTickerProviderStateMixin{
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
        upperBound: 100.0
    );
    controller.forward();
    controller.addListener(() {
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    List<ProductObj> x = new List();
    final user = Provider.of<User>(context);
    List<BagObj> orderList = new List();
    String hour = new DateFormat.H().format(new DateTime.now());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 50,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.pushNamed(context, MainMenu.id);
            }),
        title: Center(child: Text('Instant Order',style: TextStyle(
            color: Colors.black54
        ),)),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('User').document(user.uid).collection('setFood')
            .snapshots(),
    builder: (context,snapshot){
    if(!snapshot.hasData){
    return Column();
    }
    final orderData = snapshot.data.documents;
    for(var items in orderData)
    {
    if(items.data['hour'] == hour) {

      for (int k = 0; k < items.data['Items']['names'].length; k++) {
        ProductObj obj = new ProductObj(
            imgPath: items.data['Items']['imgPath'][k]
            ,
            name: items.data['Items']['names'][k],
            price: items.data['Items']['price'][k]);
        BagObj object = new BagObj(obj: obj,
            quantity:
            items.data['Items']['quantity'][k],
            finalPrice: items.data['Items']['quantity'][k]
                * double.parse(items.data['Items']['price'][k]));
        if (orderList.length < k) {
          orderList.add(object);
        }
      }
      totalPrice = items.data['totalprice'];
    }
    }
       return ListView.builder(itemCount: orderList.length,
    itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(orderList.elementAt(index).obj.name),
                    ),
                  );
    }
    );
    }
      )
    );
  }
}
