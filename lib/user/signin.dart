import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:password/password.dart';
import 'package:sennit/database/mydatabase.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';

class UserSignInRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, MyApp.userStartPage);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Log In',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: UserSignIn(),
        ),
      ),
    );
  }
}

class UserSignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserSignInState();
  }
}

class _UserSignInState extends State<UserSignIn> {
  bool rememberMeChecked = false;
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

  bool signInButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        focusColor: Theme.of(context).accentColor),
                    // style: Theme.of(context).textTheme.body1,
                    validator: (email) {
                      if (email.isEmpty) {
                        return "Email can't be empty";
                      } else {
                        RegExp re = RegExp(
                            r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
                            caseSensitive: false,
                            multiLine: false);
                        if (!re.hasMatch(email)) {
                          return 'Invalid Email Format';
                        }
                        this.email = email;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        focusColor: Theme.of(context).accentColor),
                    validator: (password) {
                      if (password.isEmpty) {
                        return "Please enter a password";
                      } else if (password.length < 6) {
                        return "Your password should be at least 8 characters long";
                      }
                      this.password = password;
                      return null;
                    },
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 15,
                    ),
                  ),
                  GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            !rememberMeChecked
                                ? FontAwesomeIcons.circle
                                : FontAwesomeIcons.solidCheckCircle,
                            size: 18,
                          ),
                          Text(' Remember me'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          rememberMeChecked = !rememberMeChecked;
                        });
                      }),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 20,
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(100, 100)),
                    ),
                    onPressed: () async {
                      if (signInButtonEnabled) {
                        signInButtonEnabled = false;
                        Utils.showLoadingDialog(context);
                        if (_formKey.currentState.validate()) {
                          try {
                            var documents = await Firestore.instance
                                .collection("users")
                                .getDocuments();

                            bool founduser = false;

                            for (DocumentSnapshot snapshot
                                in documents.documents) {
                              if (snapshot.data['email'] == email) {
                                founduser = true;
                              }
                            }

                            if (!founduser) {
                              Navigator.pop(context);
                              signInButtonEnabled = true;
                              Utils.showSnackBarError(
                                context,
                                "This email account does not exists",
                              );
                              return;
                            }

                            var auth = FirebaseAuth.instance;
                            auth
                                .signInWithEmailAndPassword(
                                    email: email, password: password)
                                .then((result) {
                              if (result.user != null) {
                                String userId = result.user.uid;
                                Firestore.instance
                                    .collection('users')
                                    .document(userId)
                                    .get()
                                    .then((userData) async {
                                  User user = User.fromMap(userData.data);
                                  Session.data.update('user', (a) {
                                    return user;
                                  }, ifAbsent: () {
                                    return user;
                                  });
                                  await DatabaseHelper.signInUser(userId);
                                  List<UserLocationHistory>
                                      userLocationHistory = await DatabaseHelper
                                          .getUserLocationHistory();
                                  Session.data
                                      .putIfAbsent("userLocationHistory", () {
                                    return userLocationHistory;
                                  });
                                  MyApp.futureCart =
                                      initializeCart(user.userId);
                                  Navigator.pop(context);
                                  Navigator.of(context)
                                      .popAndPushNamed(MyApp.userHome);
                                });
                              } else {
                                Navigator.pop(context);
                                signInButtonEnabled = true;
                                SnackBar snackBar = SnackBar(
                                  content: Text(
                                    'Invalid Email or Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                );
                                Scaffold.of(context).showSnackBar(snackBar);
                                return;
                              }
                            }).catchError((_) {
                              Navigator.pop(context);
                              signInButtonEnabled = true;
                              Utils.showSnackBarError(
                                context,
                                '${_.message}',
                              );
                              return;
                            }).timeout(
                              Duration(seconds: 12),
                              onTimeout: () {
                                Navigator.pop(context);
                                signInButtonEnabled = true;
                                Utils.showSnackBarError(
                                  context,
                                  'Request Timed out',
                                );
                              },
                            );
                          } on dynamic catch (_) {
                            Navigator.pop(context);
                            signInButtonEnabled = true;
                            Utils.showSnackBarError(
                              context,
                              'User not Found',
                            );
                            return;
                          }
                          // Firestore.instance
                          //     .collection('credentials')
                          //     .document(email)
                          //     .get()
                          //     .then((data) async {
                          //   if (!data.exists && data.data == null) {}
                          //   compute(verifyPassword,
                          //           "$password;${data.data['password']}")
                          //       .then((passwordIsCorrect) {
                          //     if (passwordIsCorrect) {
                          //     } else {
                          //       Navigator.pop(context);
                          //       signInButtonEnabled = true;
                          //       SnackBar snackBar = SnackBar(
                          //         content: Text(
                          //           'Invalid Password',
                          //           style: TextStyle(
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //         backgroundColor: Colors.red,
                          //         duration: Duration(seconds: 1),
                          //       );
                          //       Scaffold.of(context).showSnackBar(snackBar);
                          //     }
                          //   });
                          // });
                        } else {
                          Navigator.pop(context);
                          signInButtonEnabled = true;
                          SnackBar snackBar = SnackBar(
                            content: Text(
                              'Please fix errors',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    padding: EdgeInsets.only(
                        left: 60, right: 60, top: 10, bottom: 10),
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.button.fontSize,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> initializeCart(String userId) async {
    var value =
        await Firestore.instance.collection("carts").document(userId).get();

    if (value == null || value.data == null) {
      UserCart cart = UserCart();
      Session.data.update("cart", (value) {
        return cart;
      }, ifAbsent: () {
        return cart;
      });
      return Firestore.instance
          .collection('carts')
          .document(userId)
          .setData({});
    }
    UserCart cart = UserCart.fromMap(value.data);
    List<StoreItem> storeItems = [];

    var allItems =
        (await Firestore.instance.collection("items").getDocuments()).documents;

    for (DocumentSnapshot snapshot in allItems) {
      if (cart.itemIds.contains(snapshot.documentID)) {
        storeItems.add(StoreItem.fromMap(snapshot.data));
      }
    }
    
    cart.items = storeItems;
    Session.data.update("cart", (value) {
      return cart;
    }, ifAbsent: () {
      return cart;
    });
  }
}

bool verifyPassword(String message) {
  List<String> data = message.split(';');
  return Password.verify(
    data[0],
    data[1],
  );
}
