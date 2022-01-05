import 'package:document_analysis/document_analysis.dart';
import 'package:clickcollect/login_screen.dart';
import 'package:clickcollect/product.dart';
import 'package:clickcollect/services/authService.dart';
import 'package:clickcollect/setOrders.dart';
import 'package:provider/provider.dart';
import 'menu_items.dart';
import 'mybag.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'components/user.dart';
import 'PastOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/ProductObj.dart';
import 'components/BagObj.dart';
import 'dart:math';
import 'components/MainsObj.dart';

class MainMenu extends StatefulWidget {
  static const String id = 'main_menu';
  @override
  _MainMenuState createState() => _MainMenuState();
}
//bool values to check which of the image in carousel is tapped
bool mains = true;
bool sides = false;
bool drinks = false;
double totalPrice = bagList.elementAt(0).finalPrice;

class _MainMenuState extends State<MainMenu> {
  final AuthService _auth = AuthService();
  List<double> LoggedInUserRatings  = new List();

  getRecommendation(String uid) async {
    List<List<double>> rate = new List();
    List<MainsObj> recommendationItemsList = new List();
    List <AddElement> element = new List();
    double sum = 0;
    double prediction = 0;
    AddRecommendElement rel;
    bool ratedAll = false;
    List<AddRecommendElement> recommendationsList = new List();
    var foodItems = await Firestore.instance.collection('MainMenu').getDocuments();
    final food = foodItems.documents;
    for(var items in food)
      {
        MainsObj object = new MainsObj(imgPath: items.data['imgPath'],
            name: items.data['name'], price: items.data['price'],ingredients:
            items.data['ingredients']);
          recommendationItemsList.add(object);
      }
    var ratings = await Firestore.instance.collection('recommRatings').
    getDocuments();
    final ratingData = ratings.documents;
    for(var items in ratingData)
      {
        List<double> testList1  = new List();
        for(int k = 0; k< recommendationItemsList.length;k++)
        {
          double x = items.data[recommendationItemsList.elementAt(k).name]['rating'].toDouble();
          testList1.add(x);
        }
        if(items.data['uid']['uid'] == uid && LoggedInUserRatings.length < recommendationItemsList.length)
        {
          // if it is the same then add those ratings to the 1st position in matrix
          for(int s = 0; s< testList1.length;s++) {
            LoggedInUserRatings.add(testList1.elementAt(s));
          }
          rate.insert(0, testList1);
        }
        // if not add tge ratings normally
        rate.add(testList1);
      }

      for(int z = 0; z < LoggedInUserRatings.length;z++)
        {
          sum = sum + LoggedInUserRatings[z];
          if(LoggedInUserRatings.elementAt(z) != 0.0)
            {
              ratedAll = true;
            }
        }
      if(sum == 0.0)
        {
          totalPrice = 0.0;
          bagList.clear();
          for(int l = 0 ; l< recommendationItemsList.length;l++) {
            var basicRatings = await Firestore.instance.collection('UserRatings').
            document('Ratings').collection(recommendationItemsList.elementAt(l).name).getDocuments();
            final basic = basicRatings.documents;
            double basicSum = 0;
            double rating;
            for(var items in basic)
              {

                for(int b = 0; b < items.data['collected'].length; b++) {
                   basicSum = basicSum + items.data['collected'][b]['Rating'];
                   rating = basicSum / items.data['collected'].length;
                }
                if(rating >= 3)
                {
                  AddElement el;
                  for(int b = 0; b < items.data['collected'].length; b++)
                  el = new AddElement(name: items.data['collected'][b]['Name'],
                      length: items.data['collected'].length);
                  element.add(el);
                }
              }
          }

          element.sort((b,a)=> a.length.compareTo(b.length));
          for(int r = 0; r< 3;r++)
          {
            var rateData = await Firestore.instance.collection('MainMenu').getDocuments();
            final recData = rateData.documents;
            for(var items in recData)
            {
              if(items.data['name'] == element.elementAt(r).name){
                ProductObj obj = new ProductObj(imgPath: items.data['imgPath']
                    ,name: items.data['name'],price: items.data['price']);
                BagObj object = new BagObj(obj: obj,quantity: 1,
                    finalPrice: double.parse(items.data['price']));
                bagList.add(object);
                totalPrice = totalPrice + double.parse(items.data['price']);
              }
            }
          }
          Navigator.popAndPushNamed(context, MyBag.id);
        }
      else{
        print(LoggedInUserRatings);
        for(int j =0; j< LoggedInUserRatings.length;j++)
        {
          List<double> similarityList = new List();
          List<double> getRatedValues = new List();
          //looping through user ratings inside matrix and checking if it is 0
          if(LoggedInUserRatings[j] == 0.0)
          {
            //looping though user ratings in matrix again to add non zero values to
            //getRatedValues
            for(int r =0; r< LoggedInUserRatings.length;r++){
              if(LoggedInUserRatings[r] != 0.0)
              {
                //adding the non zero ratings to getRatedValues
                getRatedValues.add(LoggedInUserRatings[r]);
                // print('get Rated Values: ' + getRatedValues.toString());
                //lists to compare
                List<double> Vector1 = new List();
                List<double> Vector2 = new List();
                //looping through matrix and checking if the value at the positions is
                //not 0 and adding them to compare lists
                for(int a = 1; a< rate.length;a++)
                {
                  if(rate[a][j] != 0.0 && rate[a][r] != 0.0){
                    Vector1.add(rate[a][j]);
                    Vector2.add(rate[a][r]);
                  }
                }
                similarityList.add((cosineDistance(Vector1,Vector2) -1) * -1);
              }
            }
            List<double> predictedRatings = new List();
            for(int k =0; k< getRatedValues.length;k++)
            {
              double topPrediction = getRatedValues[k] * similarityList[k];
              predictedRatings.add(topPrediction);
            }
            double topValue = 0;
            double bottomValue = 0;
            for(int l = 0; l< predictedRatings.length;l++)
            {
              topValue += predictedRatings[l];
              bottomValue += similarityList[l];
            }
            prediction = topValue / bottomValue;
            LoggedInUserRatings[j] = prediction;
            print(LoggedInUserRatings);
           rel = new AddRecommendElement(name: recommendationItemsList.elementAt(j).name,rating: prediction);
           recommendationsList.add(rel);
            recommendationsList.sort((b,a)=> a.rating.compareTo(b.rating));
          }
        }
          totalPrice = 0.0;
          bagList.clear();
          if(recommendationsList.length < 3)
            {
              int randomIndex = Random().nextInt(recommendationItemsList.length);
              AddRecommendElement obj = new AddRecommendElement(name: recommendationItemsList[randomIndex].name,
                  rating: LoggedInUserRatings[randomIndex]);
              recommendationsList.add(obj);
            }
        for(int r = 0; r< 3;r++)
        {
          var rateData = await Firestore.instance.collection('MainMenu').getDocuments();
          final recData = rateData.documents;
          for(var items in recData)
          {
            if(items.data['name'] == recommendationsList.elementAt(r).name){
              ProductObj obj = new ProductObj(imgPath: items.data['imgPath']
                  ,name: items.data['name'],price: items.data['price']);
              BagObj object = new BagObj(obj: obj,quantity: 1,
                  finalPrice: double.parse(items.data['price']));
              bagList.add(object);
              totalPrice = totalPrice + double.parse(items.data['price']);
            }
          }
        }
        Navigator.popAndPushNamed(context, MyBag.id);
      }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    String email = '';
    if(user == null)
      {
        email = 'user';
      }
    else{
      email  = user.email;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.8),
        title: Text('Menu',style: TextStyle(color: Colors.black54),),
        actions: <Widget>[
          FlatButton.icon(onPressed: ()async{
            await getRecommendation(user.uid);
          }, icon: Icon(Icons.ac_unit,size: 25.0,color: Colors.cyan,), label: Text('Recommend')),
        ],
        iconTheme: new IconThemeData(color: Colors.cyan),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('images/Logo.png'),height: 100,width: 100,),
                  Text('Welcome ' + email),
                ],
              )),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 20,),
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.history,color: Colors.black,),
                  title: Text("Past Orders"),
                  onTap: ()
                  {
                    setState(() {

                    });
                    Navigator.popAndPushNamed(context, PastOrders.id);
                  },
                  trailing: Icon(Icons.chevron_right,color: Colors.cyan,),
                ),
                ListTile(
                  leading: Icon(Icons.history,color: Colors.black,),
                  title: Text("Set Orders"),
                  onTap: ()
                  {
                    Navigator.popAndPushNamed(context, SetOrders.id);
                  },
                  trailing: Icon(Icons.chevron_right,color: Colors.cyan,),
                ),
              ],
            ),
            SizedBox(height: 300,),
            FlatButton.icon(onPressed: ()async{
              await  _auth.signOutFunction();
              Navigator.of(context).pushAndRemoveUntil(
                // the new route
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginScreen(),
                ),

                // this function should return true when we're done removing routes
                // but because we want to remove all other screens, we make it
                // always return false
                    (Route route) => false,
              );
            },
                icon: Icon(Icons.exit_to_app,color: Colors.black87,), label: Text('Logout',style: TextStyle(color: Colors.redAccent),))
          ],
        ),
      ),
      bottomSheet: Row(
        children: [
          Badge(
            badgeColor: Colors.white,
            position: BadgePosition.topLeft(top: -15, left: 180),
            badgeContent: Text(bagList.length.toString(),style: TextStyle(color: Colors.cyan),),
            child: FlatButton.icon(
              padding: EdgeInsets.only(left: 150,top: 0,right: 0,bottom: 0),
                  onPressed: () {
                if(bagList.isEmpty)
                  {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text('Bag is Empty'),
                          content: new Text('Please add items to bag'),
                          actions: <Widget>[
                            // usually buttons at the bottom of the dialog
                            new FlatButton(
                              child: new Text('Okay'),
                              onPressed: () async{
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                else {
                  totalPrice = bagList
                      .elementAt(0)
                      .finalPrice;
                  for (int i = 1; i < bagList.length; i++) {
                    totalPrice = totalPrice + bagList
                        .elementAt(i)
                        .finalPrice;
                  }
                  Navigator.popAndPushNamed(context, MyBag.id);
                }
                  },
                  icon: Icon(
                    Icons.add_shopping_cart,
                    size: 30.0,
                  ),
                  label: Text('View Bag')),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical:20.0,horizontal: 24.0),
          child: Column(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      //true when the mains is tapped and main menu will be displayed below
                      menuTap(true, false, false,'images/images.jpeg','Mains'),
                      //true when the sides is tapped and sides menu will be displayed below
                      menuTap(false,true,false,'images/chips.jpg','Sides'),
                      //true when the drinks is tapped and main menu will be displayed below
                      menuTap(false,false,true,'images/drinks.jpg','Drinks'),
                    ],
                  ),
                ),
                MenuScroll(),
              ]),
        ),
      ),
    );

  }
  Widget menuTap(bool mainsIn, bool sidesIn, bool drinksIn, String imgPath, String name) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            sides = sidesIn;
            drinks = drinksIn;
            mains = mainsIn;
          });

        },
        child: Container(
          height: 190,
          width: 260,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(
                        20.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(4.0, 4.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0),
                    ]
                ),
              ),
              ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(20.0)),
                  child: Image.asset(imgPath,
                    fit: BoxFit.cover,)
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(
                        20.0)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black]
                    )
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(name, style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddElement{
  final String name;
  final int length;
  AddElement({this.name,this.length});
}
class AddRecommendElement{
  final String name;
  final double rating;
  AddRecommendElement({this.name,this.rating});
}
class GetDouble{
  final double d;
  GetDouble({this.d});
}