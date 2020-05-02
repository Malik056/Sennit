// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:sennit/models/models.dart';
// import 'package:sennit/my_widgets/forgot_password.dart';
// import 'package:sennit/my_widgets/verify_email_route.dart';

// import '../main.dart';

// class DriverSignInRoute extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Navigator.popAndPushNamed(context, MyApp.driverStartPage);
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Driver Log In',
//           ),
//           centerTitle: true,
//         ),
//         body: SafeArea(
//           child: DriverSignIn(),
//         ),
//       ),
//     );
//   }
// }

// class DriverSignIn extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _DriverSignInState();
//   }
// }

// class _DriverSignInState extends State<DriverSignIn> {
//   bool rememberMeChecked = false;
//   String email = "";
//   String password = "";
//   final _formKey = GlobalKey<FormState>();
//   bool signInButtonEnabled = true;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.only(left: 20, right: 20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 // style: Theme.of(context).textTheme.body1,
//                 validator: (email) {
//                   if (email.isEmpty) {
//                     return "Email can't be empty";
//                   } else {
//                     if (Utils.isEmailCorrect(email.trim())) {
//                       this.email = email.trim();
//                       return null;
//                     } else {
//                       return 'Invalid Email Format';
//                     }
//                     // RegExp re = RegExp(
//                     //     r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
//                     //     caseSensitive: false,
//                     //     multiLine: false);
//                     // if (!re.hasMatch(email)) {
//                     //   return 'Invalid Email Format';
//                     // }
//                   }
//                 },
//               ),
//               TextFormField(
//                 obscureText: true,
//                 keyboardType: TextInputType.visiblePassword,
//                 maxLines: 1,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 validator: (password) {
//                   if (password.isEmpty) {
//                     return "Please enter a password";
//                   } else if (password.length < 6) {
//                     return "Your password should be at least 6 characters long";
//                   }
//                   this.password = password;
//                   return null;
//                 },
//               ),
//               Opacity(
//                 opacity: 0,
//                 child: Container(
//                   height: 15,
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: <Widget>[
//                   GestureDetector(
//                     child: Row(
//                       children: <Widget>[
//                         Icon(
//                           !rememberMeChecked
//                               ? FontAwesomeIcons.circle
//                               : FontAwesomeIcons.solidCheckCircle,
//                           size: 18,
//                         ),
//                         Text(' Remember me'),
//                       ],
//                     ),
//                     onTap: () {
//                       setState(() {
//                         rememberMeChecked = !rememberMeChecked;
//                       });
//                     },
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     child: Text(
//                       'Forgot?',
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                     onTap: () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) {
//                         return ForgotPasswordRoute(
//                           userType: UserType.driver,
//                         );
//                       }));
//                     },
//                   ),
//                 ],
//               ),
//               Opacity(
//                 opacity: 0,
//                 child: Container(
//                   height: 20,
//                 ),
//               ),
//               RaisedButton(
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.all(Radius.elliptical(100, 100))),
//                 onPressed: () async {
//                   if (signInButtonEnabled) {
//                     signInButtonEnabled = false;
//                     Utils.showLoadingDialog(context);
//                     if (_formKey.currentState.validate()) {
//                       try {
//                         // FirebaseAuth.instance
//                         //     .signInWithEmailAndPassword(
//                         //         email: email, password: password)
//                         //     .then((result) {});
//                         // var documents = await Firestore.instance
//                         //     .collection("drivers")
//                         //     .getDocuments();

//                         // bool foundUser = false;

//                         // for (DocumentSnapshot snapshot in documents.documents) {
//                         //   if (snapshot.data['email'] == email) {
//                         //     foundUser = true;
//                         //   }
//                         // }

//                         // if (!foundUser) {
//                         //   Navigator.pop(context);
//                         //   signInButtonEnabled = true;
//                         //   Utils.showSnackBarError(
//                         //     context,
//                         //     "This email account does not exists",
//                         //   );
//                         //   return;
//                         // }

//                         var auth = FirebaseAuth.instance;
//                         auth
//                             .signInWithEmailAndPassword(
//                                 email: email, password: password)
//                             .then((result) {
//                           if (result.user != null) {
//                             String userId = result.user.uid;
//                             Firestore.instance
//                                 .collection('drivers')
//                                 .document(userId)
//                                 .get()
//                                 .then((userData) async {
//                               if (userData == null ||
//                                   !userData.exists ||
//                                   userData.data == null ||
//                                   userData.data.length <= 0) {
//                                 FirebaseAuth.instance.signOut();
//                                 Session.data..removeWhere((key, value) => true);
//                                 Navigator.pop(context);
//                                 signInButtonEnabled = true;
//                                 Utils.showSnackBarError(context,
//                                     "This email address is not associated with a driver.");
//                                 return;
//                               }
//                               Driver user = Driver.fromMap(userData.data);
//                               user.driverId = userId;
//                               Session.data.update('driver', (a) {
//                                 return user;
//                               }, ifAbsent: () {
//                                 return user;
//                               });
//                               // await DatabaseHelper.signInUser(userId);
//                               if (!result.user.isEmailVerified) {
//                                 // Navigator.popUntil(
//                                 //     context, (route) => route.isFirst);
//                                 Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(builder: (c) {
//                                     return VerifyEmailRoute(context: context);
//                                   }),
//                                   (route) => false,
//                                 );
//                                 // Navigator.pushReplacement(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //     builder: (c) {
//                                 //       return VerifyEmailRoute(context: context);
//                                 //     },
//                                 //   ),
//                                 // );
//                               } else {
//                                 // Navigator.popUntil(
//                                 //     context, (route) => route.isFirst);
//                                 Navigator.of(context).pushNamedAndRemoveUntil(
//                                   MyApp.driverHome,
//                                   (route) => false,
//                                 );
//                               }
//                             });
//                           } else {
//                             Navigator.pop(context);
//                             signInButtonEnabled = true;
//                             SnackBar snackBar = SnackBar(
//                               content: Text(
//                                 'Invalid Email or Password',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               backgroundColor: Colors.red,
//                               duration: Duration(seconds: 1),
//                             );
//                             Scaffold.of(context).showSnackBar(snackBar);
//                             return;
//                           }
//                         }).catchError(
//                           (_) {
//                             Navigator.pop(context);
//                             signInButtonEnabled = true;
//                             Utils.showSnackBarError(
//                               context,
//                               '${_.message}',
//                             );
//                             return;
//                           },
//                         );
//                         // .timeout(
//                         //   Duration(seconds: 12),
//                         //   onTimeout: () {
//                         //     Navigator.pop(context);
//                         //     signInButtonEnabled = true;
//                         //     Utils.showSnackBarError(
//                         //       context,
//                         //       'Request Timed out',
//                         //     );
//                         //   },
//                         // );
//                       } on dynamic catch (_) {
//                         Navigator.pop(context);
//                         signInButtonEnabled = true;
//                         Utils.showSnackBarError(
//                           context,
//                           'Driver not Found',
//                         );
//                         return;
//                       }
//                       // Firestore.instance
//                       //     .collection('credentials')
//                       //     .document(email)
//                       //     .get()
//                       //     .then((data) async {
//                       //   if (!data.exists && data.data == null) {}
//                       //   compute(verifyPassword,
//                       //           "$password;${data.data['password']}")
//                       //       .then((passwordIsCorrect) {
//                       //     if (passwordIsCorrect) {
//                       //     } else {
//                       //       Navigator.pop(context);
//                       //       signInButtonEnabled = true;
//                       //       SnackBar snackBar = SnackBar(
//                       //         content: Text(
//                       //           'Invalid Password',
//                       //           style: TextStyle(
//                       //             color: Colors.white,
//                       //           ),
//                       //         ),
//                       //         backgroundColor: Colors.red,
//                       //         duration: Duration(seconds: 1),
//                       //       );
//                       //       Scaffold.of(context).showSnackBar(snackBar);
//                       //     }
//                       //   });
//                       // });
//                     } else {
//                       Navigator.pop(context);
//                       signInButtonEnabled = true;
//                       SnackBar snackBar = SnackBar(
//                         content: Text(
//                           'Please fix errors',
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                         backgroundColor: Colors.red,
//                         duration: Duration(seconds: 1),
//                       );
//                       Scaffold.of(context).showSnackBar(snackBar);
//                     }
//                   }
//                 },
//                 padding:
//                     EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
//                 color: Theme.of(context).accentColor,
//                 child: Text(
//                   'Sign in',
//                   style: TextStyle(
//                     fontSize: Theme.of(context).textTheme.button.fontSize,
//                     color: Colors.white,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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

class DriverSignInRoute extends StatelessWidget {
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
            'Driver Log In',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: DriverSignIn(),
        ),
      ),
    );
  }
}

class DriverSignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DriverSignInState();
  }

  // static initializeCart(String userId) {
  //   _DriverSignInState.initializeCart(userId);
  // }
}

class _DriverSignInState extends State<DriverSignIn> {
  bool rememberMeChecked = false;
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

  void performSignin(
      Map<String, dynamic> userData, AuthResult result, String userId) {
    Driver driver = Driver.fromMap(userData);
    driver.driverId = userId;
    Session.data.update(
      'driver',
      (a) {
        return driver;
      },
      ifAbsent: () {
        return driver;
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
    // Navigator.pop(context);
    if (result.user.isEmailVerified) {
      // Navigator.popUntil(
      //     context, (route) => route.isFirst);
      Navigator.of(context).pushNamedAndRemoveUntil(
        MyApp.driverHome,
        (route) => false,
      );
    } else {
      result.user.sendEmailVerification();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) {
          return VerifyEmailRoute(context: context);
        }),
        (route) => false,
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
                // style: Theme.of(context).textTheme.body1,
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
                                  .collection('drivers')
                                  .document(userId)
                                  .get()
                                  .then(
                                (userData) async {
                                  if (userData == null ||
                                      !userData.exists ||
                                      userData.data == null ||
                                      userData.data.length <= 0) {
                                    Firestore.instance
                                        .collection('users')
                                        .document(userId)
                                        .get()
                                        .timeout(Duration(seconds: 20),
                                            onTimeout: () {
                                      Navigator.pop(context);
                                      signInButtonEnabled = true;
                                      setState(() {});
                                      Utils.showSnackBarError(
                                          context, 'Request Timed Out');
                                      return;
                                    }).then((data) {
                                      if (data == null ||
                                          !data.exists ||
                                          data.data == null ||
                                          data.data.length <= 0) {
                                        Navigator.pop(context);
                                        result.user.delete();
                                        signInButtonEnabled = true;
                                        setState(() {});
                                        Utils.showSnackBarError(
                                          context,
                                          "Driver Doesn't exists. Please Signup again",
                                        );
                                      } else {
                                        Map<String, dynamic> driverData =
                                            Map<String, dynamic>.from(
                                                data.data);
                                        driverData.putIfAbsent(
                                            'driverId', () => result.user.uid);
                                        Firestore.instance
                                            .collection('drivers')
                                            .document(result.user.uid)
                                            .setData(driverData)
                                            .timeout(
                                          Duration(seconds: 20),
                                          onTimeout: () {
                                            signInButtonEnabled = true;
                                            Navigator.pop(context);
                                            Utils.showSnackBarError(context,
                                                'Request Timed out please Try Again!');
                                            setState(() {});
                                          },
                                        ).then((_) {
                                          performSignin(
                                            driverData,
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
                          'Driver not Found',
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
}

bool verifyPassword(String message) {
  List<String> data = message.split(';');
  return Password.verify(
    data[0],
    data[1],
  );
}
