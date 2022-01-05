import 'package:clickcollect/components/BagObj.dart';
import 'package:clickcollect/components/ProductObj.dart';
import 'package:clickcollect/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mybag.dart';
import 'main_menu.dart';
import 'package:provider/provider.dart';
import 'components/user.dart';

class PastOrders extends StatefulWidget {
  static const String id = 'PastOrders';
  @override
  _PastOrdersState createState() => _PastOrdersState();
}

class _PastOrdersState extends State<PastOrders> {
  String orders = '';
  String tot = '';
  String status = '';
  TextStyle setColor (String text){
    if(text == 'Order being prepared'){
      return TextStyle(
        color: Colors.red,
      );
    }
    else if(text == 'Order has been collected'){
    return TextStyle(
    color: Colors.blue,
    );
    }
    else{
      return TextStyle(
        color: Colors.green,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    String uid = '';
    if(user == null)
      {
      }
    else{
      uid = user.uid;
    }
    return Scaffold(
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
        title: Center(child: Text('Past Orders',style: TextStyle(
            color: Colors.black54
        ),)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('User').document(uid).
        collection('pastOrders').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Column();
          }
          List<PastData> pastData = new List();
          final cloud =  snapshot.data.documents;
          for(var items in cloud)
          {
            PastData value = new PastData(imgPath: items.data['Items']['imgPath'], name: items.data['Items']['names'],
                quantity: items.data['Items']['quantity'],
                price: items.data['Items']['price'], time: items.data['timestamp'], total: items.data['totalPrice'],
                status: items.data['status']);
            if(pastData.length < cloud.length && !pastData.contains(value))
              pastData.add(value);
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: pastData.length,
                  itemBuilder: (context, index) {
                    int ind = index +1;
                    orders = '';
                    for(int k = 0; k< pastData.elementAt(index).name.length;k++) {
                      int j = k +1;
                      orders = orders + '$j) ' + 'Item: ' + pastData.elementAt(index).name.elementAt(k) + ', Price: ' + pastData.elementAt(index)
                          .price.elementAt(k) + ', Quantity: ' + pastData.elementAt(index).quantity.elementAt(k) + '\n';
                    }
                    tot = pastData.elementAt(index).total.toString();
                    status = pastData.elementAt(index).status;
                    return Card(
                      child: ListTile(
                        leading: Text(ind.toString()+') ')
                        ,title: Text(pastData.elementAt(index).time.toDate().day.toString()+
                          '/'+ pastData.elementAt(index).time.toDate().month.toString()+'/'+
                          pastData.elementAt(index).time.toDate().year.toString()),
                        subtitle: Column(
                          children: [
                            Text(orders +'\n' +'Total Price: ' +tot),
                            Text("Status: "+ status,style: setColor(status)),
                          ],
                        ),
                        trailing: FlatButton.icon(icon: Icon(Icons.add),
                          label: Text('Order Again'),
                          color: Colors.black54,
                          onPressed: (){
                            bagList.clear();
                            for(int k = 0; k< pastData.elementAt(index).name.length;k++)
                            {
                              ProductObj obj = new ProductObj(imgPath: pastData.elementAt(index).imgPath.elementAt(k)
                                  ,name: pastData.elementAt(index).name.elementAt(k),
                                  price: pastData.elementAt(index).price.elementAt(k));
                              BagObj object = new BagObj(obj: obj,
                                  quantity: int.parse(pastData.elementAt(index).quantity.elementAt(k))
                                  ,finalPrice: int.parse(pastData.elementAt(index).quantity.elementAt(k))
                                      * double.parse(obj.price));
                              bagList.add(object);
                              totalPrice = pastData.elementAt(index).total;
                            }
                            Navigator.popAndPushNamed(context, MyBag.id);
                          },),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class PastData{
  final List<dynamic> imgPath;
  final List<dynamic> name;
  final List<dynamic> quantity;
  final List<dynamic> price;
  final Timestamp time;
  final double total;
  final String status;
  PastData({this.imgPath,this.name,this.quantity,this.price,this.time,this.total,this.status});
}
