import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';

class PartnerStoreSignInRoute extends StatelessWidget {
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
            'Store Log In',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: PartnerStoreSignInBody(),
        ),
      ),
    );
  }
}

class PartnerStoreSignInBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PartnerStoreSignInBodyState();
  }
}

class _PartnerStoreSignInBodyState extends State<PartnerStoreSignInBody> {
  bool rememberMeChecked = false;
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

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
                    return "Your password should be at least 6 characters long";
                  }
                  this.password = password;
                  return null;
                },
              ),
              // Opacity(
              //   opacity: 0,
              //   child: Container(
              //     height: 15,
              //   ),
              // ),
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
                          email: email,
                          password: password,
                        )
                            .then((result) {
                          if (result.user != null) {
                            String userId = result.user.uid;
                            Firestore.instance
                                .collection('partnerStores')
                                .document(userId)
                                .get()
                                .then(
                              (userData) async {
                                if (userData == null || !userData.exists) {
                                  Utils.showSnackBarError(
                                    context,
                                    "User not found",
                                  );
                                  signInButtonEnabled = true;
                                  return;
                                }
                                // User user = User.fromMap(userData.data);
                                var storeId = userData.data['storeId'];
                                var data = await Firestore.instance
                                    .collection('stores')
                                    .document(storeId)
                                    .get()
                                    .catchError((_) {
                                  FirebaseAuth.instance.signOut();
                                  signInButtonEnabled = true;
                                  Navigator.pop(context);
                                  setState(() {});
                                  return null;
                                }).then((value) {
                                  return value;
                                }).timeout(
                                  Duration(seconds: 10),
                                  onTimeout: () {
                                    FirebaseAuth.instance.signOut();
                                    signInButtonEnabled = true;
                                    setState(() {});
                                    Navigator.pop(context);
                                    Utils.showSnackBarError(
                                      context,
                                      'Request Timed out',
                                    );
                                    return null;
                                  },
                                );
                                if (data == null) {
                                  return;
                                }
                                Store store = Store.fromMap(data.data);
                                store.storeId = data.documentID;
                                Session.data.update(
                                  'partnerStore',
                                  (a) {
                                    return store;
                                  },
                                  ifAbsent: () {
                                    return store;
                                  },
                                );
                                // Navigator.pop(context);
                                // Navigator.popUntil(
                                //     context, (route) => route.isFirst);
                                FirebaseMessaging fcm = FirebaseMessaging();
                                final deviceId = await fcm.getToken();
                                var deviceTokens = store.deviceTokens ?? [];
                                if (!deviceTokens.contains(deviceId))
                                  deviceTokens.add(deviceId);

                                await Firestore.instance
                                    .collection('stores')
                                    .document(storeId)
                                    .setData(
                                  {
                                    'deviceTokens': deviceTokens,
                                  },
                                  merge: true,
                                );
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  MyApp.partnerStoreHome,
                                  (route) => false,
                                );
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
}
