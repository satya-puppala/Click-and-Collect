import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class DatabaseService {
  //variables and constructor
  final String uid;
  bool test = false;

  DatabaseService({this.uid});
  final CollectionReference userInfo =
  Firestore.instance.collection('User');

  Future updateUserInformation(String firstName, String lastName,
      String email, String phoneNumber) async{
    return await userInfo.document(uid).setData({
      'Name': firstName +' '+lastName,
      'Email': email,
      'Phone_Number': phoneNumber,
    });
  }

  Future pastOrders(List<String> img,List<String> names,
      List<String> price,List<String> quantity,
      Timestamp timestamp,
      String H,String m, double totalPrice,String status )
  async {
    return await userInfo.document(uid).collection('pastOrders').document(H+':'+m).setData({
      'Items': {
        'imgPath': img,
        'names': names,
        'price': price,
        'quantity': quantity
      },
      'timestamp': timestamp,
      'hour': H,
      'minute': m,
      'totalPrice': totalPrice,
      'status': status
    });
  }
  Future foodRating(String name,double rating) async{
    var rateData = await Firestore.instance.collection('UserRatings').
    document('Ratings').collection(name).getDocuments();
    final result = rateData.documents;
    for(var items in result)
      {
        List<dynamic> list = new List();
        list.addAll(items.data['collected']);
        for(int k = 0 ; k< items.data['collected'].length; k++){
        if(items.data['collected'][k]['Name'] == name && items.data['collected'][k]['User'] == uid){
          test = true;
          list.removeAt(k);
          list.add({'Name':name,'Rating':rating,'User':uid});
          return await Firestore.instance.collection('UserRatings').
          document('Ratings').collection(name).document('Data').setData({
            "collected": list
          });
        }
        }
      }
    if(test == false){
    return await Firestore.instance.collection('UserRatings').
    document('Ratings').collection(name).document('Data').setData({
    "collected": FieldValue.arrayUnion([
    {
    'Rating' : rating,
    'Name' : name,
    'User': uid
    }
    ])
    },merge: true);
    }
  }
  Future userfoodRating(String name, double rating) async{
    return await userInfo.document(uid).collection('Ratings').document(name).setData({
      'Rating' : rating,
    });
  }
  Future Orders(List<String> img,List<String> names,
      List<String> price,List<String> quantity,
      Timestamp timestamp,
      String H,String m, double totalPrice, String uid )
  async {
    return await Firestore.instance.collection('Orders').document().setData({
      'Items': {
        'imgPath': img,
        'names': names,
        'price': price,
        'quantity': quantity
      },
      'timestamp': timestamp,
      'hour': H,
      'minute': m,
      'totalPrice': totalPrice,
      'uid': uid
    });
  }
  Future CompletedOrders(List<dynamic> img,List<dynamic> names,
      List<dynamic> price,List<dynamic> quantity,
      Timestamp timestamp,
      String H,String m, double totalPrice, String uid )
  async {
    return await Firestore.instance.collection('CompletedOrders').document().setData({
      'Items': {
        'imgPath': img,
        'names': names,
        'price': price,
        'quantity': quantity
      },
      'timestamp': timestamp,
      'hour': H,
      'minute': m,
      'totalPrice': totalPrice,
      'uid': uid
    });
  }

  Future setFood(List<String> img,List<String> names,
      List<String> price,List<int> quantity,String hour, String minute, double totalPrice) async{
    return await userInfo.document(uid).collection('setFood').document(hour+':'+minute).setData(
        {
          'Items': {
            'imgPath': img,
            'names': names,
            'price': price,
            'quantity': quantity
          },
          'totalprice': totalPrice,
          'hour': hour,
          'minute': minute
        }
    );
  }
  Future initialRatings() async{
    return await Firestore.instance.collection('recommRatings').document(uid).setData({
      'Baked Risotto':{
        'rating': 0
      },
      'Burger':{
        'rating': 0
      },
      'Chicken Chasseur and Mash':{
        'rating': 0
      },
      'Falafel burgers':{
        'rating': 0
      },
      'Margherita Pizza':{
        'rating': 0
      },
      'Mustard stuffed chicken':{
        'rating': 0
      },
      'Pesto Lasagne':{
        'rating': 0
      },
      'Salmon with roast Asparagus':{
        'rating': 0
      },
      'Spicy root & lentil casserole':{
        'rating': 0
      },
      'uid': {
        'uid': uid
      },
    });
  }
  Future setRatings(String name, double rating) async
  {
    return await Firestore.instance.collection('recommRatings').document(uid).setData({
      '$name': {
        'rating':rating
      }
    },merge: true);
  }
}