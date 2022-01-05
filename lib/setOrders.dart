import 'package:clickcollect/components/startScreen.dart';
import 'package:clickcollect/mybag.dart';
import 'package:clickcollect/product.dart';
import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'services/database.dart';
import 'package:provider/provider.dart';
import 'components/user.dart';
class SetOrders extends StatefulWidget {
  static const String id = 'setOrders';
  @override
  _SetOrdersState createState() => _SetOrdersState();
}

class _SetOrdersState extends State<SetOrders> {
  List<String> a = new List();
  List<String> b = new List();
  List<String> c = new List();
  List<int> d = new List();
  final TextEditingController controller1 = new TextEditingController();
  final TextEditingController controller2 = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
        title: Center(child: Text('Description',style: TextStyle(
            color: Colors.black54
        ),)),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
           TextFormField(
             controller: controller1,
          textAlign: TextAlign.center,
          decoration: InputDecoration(hintText: 'Hour in 24 hours format'),
      ),
          TextFormField(
            controller: controller2,
            textAlign: TextAlign.center,
            decoration: InputDecoration(hintText: 'minutes'),
          ),
          SizedBox(height: 20,),
          FlatButton(
            color: Colors.cyan,
            child: Text(
              'Set Order for this time'
            ),
            onPressed:(){
              for(int k =0; k < bagList.length;k++)
                {
                  a.add(bagList.elementAt(k).obj.imgPath);
                  b.add(bagList.elementAt(k).obj.name);
                  c.add(bagList.elementAt(k).obj.price);
                  d.add(bagList.elementAt(k).quantity);
                }
              print(b);
              DatabaseService(uid: user.uid).setFood(a, b, c, d,
                 controller1.text, controller2.text, totalPrice);
              print(controller1.text);
              print(controller2.text);
              print(totalPrice);
              Navigator.popAndPushNamed(context, MyBag.id);
              },
          )
        ],
      ),
    );
  }
}
