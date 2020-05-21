import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:password/password.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/forgot_password.dart';
import 'package:sennit/my_widgets/verify_email_route.dart';

class UserSignInRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);
        // Navigator.popAndPushNamed(context, MyApp.userStartPage);
        return true;
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

  static initializeCart(String userId) {
    _UserSignInState.initializeCart(userId);
  }
}

class _UserSignInState extends State<UserSignIn> {
  bool rememberMeChecked = false;
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

  void performSignin(
      Map<String, dynamic> userData, AuthResult result, String userId) {
    User user = User.fromMap(userData);
    user.userId = userId;
    Session.data.update(
      'user',
      (a) {
        return user;
      },
      ifAbsent: () {
        return user;
      },
    );
    // await DatabaseHelper.signInUser(userId);
    // List<UserLocationHistory>
    //     userLocationHistory = await DatabaseHelper
    //         .getUserLocationHistory();
    // Session.data.putIfAbsent(
    //   "userLocationHistory",
    //   () {
    //     return userLocationHistory;
    //   },
    // );
    MyApp.futureCart = initializeCart(user.userId);
    // Navigator.pop(context);
    if (result.user.isEmailVerified) {
      // Navigator.popUntil(
      //     context, (route) => route.isFirst);
      Navigator.of(context).pushNamedAndRemoveUntil(
        MyApp.userHome,
        (route) => false,
      );
    } else {
      result.user.sendEmailVerification();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return VerifyEmailRoute(
            context: context,
          );
        }),
      );
    }
  }

  bool signInButtonEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
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
                // style: Theme.of(context).textTheme.bodyText2,
                validator: (email) {
                  if (email.isEmpty) {
                    return "Email can't be empty";
                  } else {
                    // RegExp re = RegExp(
                    //     r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
                    //     caseSensitive: false,
                    //     multiLine: false);
                    // if (!re.hasMatch(email)) {
                    //   return 'Invalid Email Format';
                    // }
                    if (Utils.isEmailCorrect(email.trim())) {
                      this.email = email.trim();
                      return null;
                    } else {
                      return 'Invalid Email Format';
                    }
                  }
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
                    return "Your password should be at least 6 characters long";
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
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
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Text(
                      'Forgot?',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ForgotPasswordRoute(
                          userType: UserType.user,
                        );
                      }));
                    },
                  ),
                ],
              ),
              Opacity(
                opacity: 0,
                child: Container(
                  height: 20,
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.elliptical(100, 100)),
                ),
                onPressed: () async {
                  if (signInButtonEnabled) {
                    signInButtonEnabled = false;
                    Utils.showLoadingDialog(context);
                    if (_formKey.currentState.validate()) {
                      try {
                        var auth = FirebaseAuth.instance;
                        auth
                            .signInWithEmailAndPassword(
                          email: email.trim(),
                          password: password,
                        )
                            .then(
                          (result) {
                            if (result.user != null) {
                              String userId = result.user.uid;
                              Firestore.instance
                                  .collection('users')
                                  .document(userId)
                                  .get()
                                  .timeout(Duration(seconds: 10),
                                      onTimeout: () {
                                Navigator.pop(context);
                                Utils.showSnackBarError(
                                    context, 'Request Timed out try again');
                                setState(() {
                                  signInButtonEnabled = false;
                                });
                                return null;
                              }).then(
                                (userData) async {
                                  if (userData == null ||
                                      !userData.exists ||
                                      userData.data == null ||
                                      userData.data.length <= 0) {
                                    Firestore.instance
                                        .collection('drivers')
                                        .document(userId)
                                        .get()
                                        .then((data) {
                                      if (data == null ||
                                          !data.exists ||
                                          data.data == null ||
                                          data.data.length <= 0) {
                                        Navigator.pop(context);
                                        // result.user.delete();
                                        signInButtonEnabled = true;
                                        setState(() {});
                                        Utils.showSnackBarError(
                                          context,
                                          "User Doesn't exists. Please Signup again",
                                        );
                                      } else {
                                        Map<String, dynamic> userDataNew =
                                            Map<String, dynamic>.from(
                                                data.data);
                                        userDataNew.putIfAbsent(
                                            'userId', () => userId);

                                        Firestore.instance
                                            .collection('users')
                                            .document(result.user.uid)
                                            .setData(userDataNew)
                                            .timeout(
                                          Duration(seconds: 20),
                                          onTimeout: () {
                                            Navigator.pop(context);
                                            signInButtonEnabled = true;
                                            setState(() {});
                                            Utils.showSnackBarError(context,
                                                'Request Timed out please Try Again!');
                                          },
                                        ).then((_) {
                                          performSignin(
                                            userDataNew,
                                            result,
                                            userId,
                                          );
                                        });
                                      }
                                    });
                                    return;
                                  }
                                  performSignin(userData.data, result, userId);
                                },
                              );
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
                          },
                        ).catchError(
                          (_) {
                            Navigator.pop(context);
                            signInButtonEnabled = true;
                            Utils.showSnackBarError(
                              context,
                              '${_.message}',
                            );
                            return;
                          },
                        );
                        // .timeout(
                        //   Duration(seconds: 12),
                        //   onTimeout: () {
                        //     Navigator.pop(context);
                        //     signInButtonEnabled = true;
                        //     Utils.showSnackBarError(
                        //       context,
                        //       'Request Timed out',
                        //     );
                        //   },
                        // );
                      } on dynamic catch (_) {
                        print(_);
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
                padding:
                    EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
                color: Theme.of(context).accentColor,
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.button.fontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> initializeCart(String userId) async {
    if (userId == null) return;
    if (Session.data.containsKey('cart') &&
        Session.data['cart'] != null &&
        (Session.data['cart'] as UserCart).itemsData.length > 0) {
      return Firestore.instance.collection("carts").document(userId).setData({
        'itemsData': Session.data['cart'].itemsData,
      });
    }

    var value =
        await Firestore.instance.collection("carts").document(userId).get();

    if (value == null || value.data == null || value.data.isEmpty) {
      UserCart cart = UserCart(itemsData: {});
      Session.data.update(
        "cart",
        (value) {
          return cart;
        },
        ifAbsent: () {
          return cart;
        },
      );
      return;
      // Firestore.instance.collection('carts').document(userId).setData(
      //   {
      //     'itemsData': {},
      //   },
      // );
    }
    UserCart cart = UserCart.fromMap(value.data);
    List<StoreItem> storeItems = [];
    var allItems =
        (await Firestore.instance.collection("items").getDocuments()).documents;

    // int i = 0;

    for (DocumentSnapshot snapshot in allItems) {
      if (cart.itemsData.containsKey(snapshot.documentID)) {
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
