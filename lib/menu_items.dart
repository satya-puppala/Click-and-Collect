import 'package:clickcollect/product.dart';
import 'package:flutter/material.dart';
import 'package:clickcollect/main_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clickcollect/components/MainsObj.dart';

class MenuScroll extends StatefulWidget {
  @override
  _MenuScrollState createState() => _MenuScrollState();
}

List<MainsObj> mylist = new List();
int i;
class _MenuScrollState extends State<MenuScroll> {
  @override
  Widget build(BuildContext context) {
    if (mains == true) {
      return streamBuilding('MainMenu');
    } else if (sides == true) {
      return streamBuilding('SideMenu');
    } else if (drinks == true) {
      return streamBuilding('DrinksMenu');
    }
    else{
      return Container(height: 0,);
    }
  }
  Widget streamBuilding (String path){
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(path).snapshots(),
        builder: (context, snapshot) {
            if(!snapshot.hasData) {return Column();}
            mylist.clear();
          final menu = snapshot.data.documents;
          if(mylist.length < menu.length)
            for(var items in menu){
              MainsObj object = new MainsObj(imgPath: items.data['imgPath'],
                  name: items.data['name'], price: items.data['price'],ingredients:
                  items.data['ingredients']);
              mylist.add(object);
            }
          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for(int i =0; i< mylist.length;i++)
                    buildFoodItem(mylist.elementAt(i).imgPath,mylist.elementAt(i).name
                        ,mylist.elementAt(i).price,i),
                ],
              ),
            ),
          );
        }
    );
  }
  Widget buildFoodItem(String imgPath, String foodName, String price,int k) {
    return Card(
      child: ListTile(leading: Image.network(imgPath,
        height: 45.0,
        width: 45.0,
      ),
        title: GestureDetector(
          onTap: () {

          },
          child: Column(
            children: [
              Text(foodName),
              Text('£ $price')
            ],
          ),
        ),
        trailing: IconButton(icon: Icon(Icons.add),
          color: Colors.cyan,
          onPressed: (){
         // await getCsv();
            Navigator.popAndPushNamed(context, MyProduct.id);
            i = k;
          },),),
    );
  }
}

