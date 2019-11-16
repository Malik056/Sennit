import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/main.dart';

class UserSignUpRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserSignUpRouteState();
  }

  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
}

class UserSignUpRouteState extends State<UserSignUpRoute> {
  Color defaultColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);
  Color defaultHeighlightedColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);
  Color defaultBtnBackgroundColor = Colors.white;
  double btnPaddingTop;
  double btnPaddingBottom;
  double btnPaddingLeft;
  double btnPaddingRight;
  String dateInitialText;
  bool dateSelected = false;

  Color defaultHeighlightedColorDOB = Color.fromARGB(255, 57, 59, 82);

  String dateText;

  bool tapped = false;

  String address = "Not Available";

  @override
  void initState() {
    btnPaddingTop = 10;
    btnPaddingBottom = 10;
    btnPaddingLeft = 20;
    btnPaddingRight = 25;
    dateInitialText = 'Tap to select';
    dateText = dateInitialText;
    super.initState();
    // defaultHeighlightedColorDOB = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!Navigator.canPop(context)) {
          Navigator.of(context).popAndPushNamed(MyApp.startPage);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Sign Up'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: widget._formKey,
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (firstName) {
                        if (firstName.isEmpty) {
                          return "First Name can't be empty";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (lastName) {
                        if (lastName.isEmpty) {
                          return "Last Name can't be empty";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Email'),
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
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (password) {
                        if (password.isEmpty) {
                          return "Please enter a password";
                        } else if (password.length < 6) {
                          return "Your password should be at least 6 characters long";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Retype Password'),
                      validator: (rePassword) {
                        if (rePassword.isEmpty) {
                          return "Please confirm your password";
                        } else if (rePassword !=
                            widget.passwordController.text) {
                          return "Password does not match";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Opacity(
                      opacity: 0,
                      child: Container(
                        height: 20,
                      ),
                    ), // Text(
                    //   'Date of Birth: ',
                    //   style: TextStyle(
                    //       color: Theme.of(context).primaryColor,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    Text(
                      'Date of Birth: ',
                      style: TextStyle(color: defaultHeighlightedColorDOB),
                      textAlign: TextAlign.start,
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          padding: EdgeInsets.only(
                              left: btnPaddingLeft - 10,
                              right: btnPaddingRight,
                              top: btnPaddingTop - 5,
                              bottom: btnPaddingBottom - 5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(100, 100)),
                            // side: BorderSide(
                            //     color: Theme.of(context).accentColor,
                            //     width: 3),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.calendarDay,
                                color: defaultHeighlightedColorDOB,
                              ),
                              Text(
                                '   $dateText',
                                style: TextStyle(
                                    color: defaultHeighlightedColorDOB),
                              ),
                            ],
                          ),
                          // highlightColor: Theme.of(context).primaryColor,
                          // onHighlightChanged: (isHeighlighted) {
                          //   if (!tapped || dateSelected) {
                          //     if (isHeighlighted) {
                          //       defaultHeighlightedColorDOB = Colors.white;
                          //     } else {
                          //       defaultHeighlightedColorDOB =
                          //           Theme.of(context).primaryColor;
                          //     }
                          //   }
                          //   setState(() {});
                          // },
                          onPressed: () async {
                            DateTime selectedDate = await showDatePicker(
                              firstDate: DateFormat("yyyy/MM/dd", "en_US")
                                  .parse("1950/01/01"),
                              lastDate: DateTime.now(),
                              context: context,
                              initialDate: DateFormat("dd-MMM-yyyy", "en_US")
                                  .parse(dateText == dateInitialText
                                      ? "01-Jan-2000"
                                      : dateText),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                dateSelected = true;
                                defaultHeighlightedColorDOB =
                                    Theme.of(context).accentColor;
                                dateText = DateFormat("dd-MMM-yyyy", "en_US")
                                    .format(selectedDate)
                                    .toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: dateSelected ? 0 : 1,
                      child: tapped
                          ? (dateSelected
                              ? () {
                                  setState(() {
                                    defaultHeighlightedColorDOB =
                                        Theme.of(context).primaryColor;
                                  });
                                  return null;
                                }()
                              : () {
                                  setState(() {
                                    defaultHeighlightedColorDOB = Colors.red;
                                  });
                                  return Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Please select your date of birth',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  );
                                }())
                          : null,
                    ),
                    // TextFormField(
                    //   maxLines: 1,
                    //   decoration: InputDecoration(labelText: 'Street Address'),
                    //   validator: (street) {
                    //     if (street.isEmpty) {
                    //       return "Adress is required";
                    //     }
                    //     return null;
                    //   },
                    //   style: Theme.of(context).textTheme.body1,
                    // ),
                    // TextFormField(
                    //   maxLines: 1,
                    //   decoration: InputDecoration(labelText: 'City'),
                    //   validator: (city) {
                    //     if (city.isEmpty) {
                    //       return "City is required";
                    //     }
                    //     return null;
                    //   },
                    //   style: Theme.of(context).textTheme.body1,
                    // ),
                    // TextFormField(
                    //   maxLines: 1,
                    //   decoration: InputDecoration(labelText: 'State/Provice'),
                    //   validator: (state) {
                    //     if (state.isEmpty) {
                    //       return "This field is required";
                    //     }
                    //     return null;
                    //   },
                    //   style: Theme.of(context).textTheme.body1,
                    // ),
                    // TextFormField(
                    //   keyboardType: TextInputType.phone,
                    //   maxLines: 1,
                    //   decoration: InputDecoration(labelText: 'Country'),
                    //   validator: (country) {
                    //     if (country.isEmpty) {
                    //       return "Please Mention your Country";
                    //     }
                    //     return null;
                    //   },
                    //   style: Theme.of(context).textTheme.body1,
                    // ),
                    // TextFormField(
                    //   maxLines: 1,
                    //   keyboardType: TextInputType.number,
                    //   decoration: InputDecoration(labelText: 'Zip'),
                    //   validator: (zip) {
                    //     if (zip.isEmpty) {
                    //       return "This field is required";
                    //     }
                    //     return null;
                    //   },
                    //   style: Theme.of(context).textTheme.body1,
                    // ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (cellNum) {
                        if (cellNum.isEmpty) {
                          return "Please Enter your phone number";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                                      ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Pick A location'),
                    onTap: () async {
                      LocationResult result =
                          await Utils.showPlacePicker(context);
                      if (result != null) {
                        setState(() {
                          address = result.formattedAddress;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.my_location,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Selected Location',
                        style: TextStyle(color: Theme.of(context).accentColor)),
                    subtitle: Text(
                      address,
                    ),
                  ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text.rich(
                        TextSpan(
                          text: 'By creating an account you agree to our ',
                          style: TextStyle(fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Terms & Privacy',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0x1E, 0x90, 0xFF),
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: RaisedButton(
                        padding: EdgeInsets.only(
                          left: btnPaddingLeft + 30,
                          right: btnPaddingRight + 30,
                          top: btnPaddingTop - 5,
                          bottom: btnPaddingBottom - 5,
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(100, 100)),

                        ),
                        child:
                            //  Row(
                            //   children: <Widget>[
                            //     Icon(
                            //       FontAwesomeIcons.envelopeOpen,
                            //       color: defaultHeighlightedColor,
                            //     ),
                            Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.button.fontSize,
                            color: Colors.white,
                          ),
                        ),
                        // ],
                        // ),
                        highlightColor: defaultColor,
                        onHighlightChanged: (isHeighlighted) {
                          if (isHeighlighted) {
                            defaultHeighlightedColor = Colors.white;
                          } else {
                            defaultHeighlightedColor = defaultColor;
                          }
                          setState(() {});
                        },
                        onPressed: () {
                          tapped = true;
                          var form = widget._formKey.currentState;
                          if (form.validate() && dateInitialText != dateText) {
                            setState(() {
                              dateSelected = true;
                            });
                          } else if (dateInitialText == dateText) {
                            setState(() {
                              defaultHeighlightedColorDOB = Colors.red;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
