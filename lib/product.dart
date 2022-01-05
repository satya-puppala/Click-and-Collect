import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/BagObj.dart';
import 'components/ProductObj.dart';
import 'package:flutter/material.dart';
import 'menu_items.dart';
import 'main_menu.dart';
import 'components/user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'services/database.dart';
import 'package:provider/provider.dart';
class MyProduct extends StatefulWidget {
  static const String id = 'product';
  @override
  _MyProductState createState() => _MyProductState();
}
List <BagObj> bagList = new List();
double stars = 3;
class _MyProductState extends State<MyProduct> {
  int counter = 1;
  String prices = mylist.elementAt(i).price;
  double fp = double.tryParse(mylist.elementAt(i).price);
  double rtng = stars;
  double sum = 0;
  String ingredients;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if(mylist.elementAt(i).ingredients == null)
      {
        ingredients = '';
      }
    else{
      ingredients = 'Ingredients: '+mylist.elementAt(i).ingredients;
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
        title: Center(child: Text('Description',style: TextStyle(
            color: Colors.black54
        ),)),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('UserRatings').
        document('Ratings').collection(mylist.elementAt(i).name).snapshots(),
        builder: (context,snapshot) {
          if (!snapshot.hasData) {
            return Column();
          }
          final rating = snapshot.data.documents;
          int l;
          if(rating.length != 0) {
            for (var items in rating) {
              l = items.data['collected'].length;
              for(int j = 0; j < l;j++) {
                sum = sum + items.data['collected'][j]['Rating'];
              }
            }
            rtng = sum / l;
            sum = 0;
          }
          return SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20.0)),
                    child: Image.network(mylist.elementAt(i).imgPath,
                      fit: BoxFit.cover,
                      height: 250,
                      width: 300,)
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(mylist.elementAt(i).name,
                          style: TextStyle(
                              fontSize: 20.0
                          ),),
                        Text('£ $prices',
                          style: TextStyle(
                              fontSize: 20.0
                          ),
                        ),
                      ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          if(counter>1) {
                            counter--;
                            fp = fp - double.tryParse(mylist.elementAt(i).price);
                          }
                        });
                      },
                    ),
                    Text('Quantity: $counter'),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          counter++;
                          fp = fp + double.tryParse(mylist.elementAt(i).price);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Container(
                  child: RatingBar(
                    initialRating: rtng,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(padding: EdgeInsets.all(20),
                child:  Card(
                  child: Text(ingredients, textAlign: TextAlign.center, style: TextStyle(
                    fontFamily: 'Fondamento',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),),
                ),),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: [
                        FlatButton.icon(onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text('Rate the Item'),
                                content: RatingBar(
                                initialRating: rtng,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  stars = rating;
                                },
                              ),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                   FlatButton(
                                    child: Text('Submit'),
                                    onPressed: ()  async{
                                     await DatabaseService(uid: user.uid).userfoodRating
                                        (mylist.elementAt(i).name, stars);
                                     await DatabaseService(uid: user.uid).foodRating(
                                          mylist.elementAt(i).name, stars);
                                     await DatabaseService(uid: user.uid).setRatings
                                       (mylist.elementAt(i).name, stars);
                                      Navigator.of(context).pop();
                                     showDialog(
                                       context: context,
                                       builder: (BuildContext context) {
                                         // return object of type Dialog
                                         return AlertDialog(
                                           title: new Text('Thank you'),
                                           content: new Text('your rating is submitted'),
                                           actions: <Widget>[
                                             // usually buttons at the bottom of the dialog
                                             new FlatButton(
                                               child: new Text('okay'),
                                               onPressed: () {
                                                 Navigator.of(context).pop();
                                               },
                                             ),
                                           ],
                                         );
                                       },
                                     );
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        },
                            icon: Icon(Icons.rate_review),
                            label: Text('Rate Item')),
                        Expanded(
                            child:  FlatButton.icon(
                                onPressed: (){
                                  BagObj bagItems = new BagObj(obj:
                                  new ProductObj(imgPath: mylist.elementAt(i).imgPath,
                                      name: mylist.elementAt(i).name,
                                      price: mylist.elementAt(i).price),
                                    quantity: counter,
                                    finalPrice: fp,
                                  );
                                  bagList.add(bagItems);
                                  counter = 1;
                                  final snackBar = SnackBar(
                                    content: Text('Item is added to Bag'),
                                    action: SnackBarAction(
                                      label: 'Okay',
                                      onPressed: () {
                                        Scaffold.of(context).hideCurrentSnackBar();
                                      },
                                    ),
                                  );
                                  // Find the Scaffold in the widget tree and use
                                  // it to show a SnackBar.
                                  Scaffold.of(context).showSnackBar(snackBar);
                                },
                                label:  Text('Add: £ $fp'),
                                icon: Icon(
                                  Icons.shopping_basket,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
