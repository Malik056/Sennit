import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sennit/main.dart';

class ChangePasswordRoute extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _controller,
                  validator: (value) {
                    if (value.length < 6) {
                      return "Password should be atleast 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    hintText: "Confirm Password",
                  ),
                  validator: (value) {
                    if (value.length < 6) {
                      return "Password does not match";
                    }
                    return null;
                  },
                  maxLines: 1,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await (await FirebaseAuth.instance.currentUser())
                          .updatePassword(_controller.text);
                      Utils.showSuccessDialog('Password Updated');
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(MyApp.recieveItRoute),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticateAgainRoute extends StatelessWidget {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool pressed = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Authenticate'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 10, right: 10),
        child: Card(
          elevation: 10.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Spacer(),
                Text(
                  'Verify Password',
                  style: Theme.of(context).textTheme.headline,
                ),
                SizedBox(
                  height: 40,
                ),
                // Spacer(flex: 2,),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Verify Password",
                    hintText: "Old Password",
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    if (!pressed) {
                      Utils.showLoadingDialog(context);
                      pressed = true;
                      if (_controller.text != null &&
                          _controller.text.length > 6) {
                        final user = await FirebaseAuth.instance
                            .currentUser()
                            .catchError((error) {
                          pressed = false;
                          Navigator.pop(context);
                          Utils.showSnackBarError(
                            context,
                            'Unknown Error! Please try again.',
                          );
                        });
                        final result = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: user.email,
                          password: _controller.text,
                        );
                        if (result.user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) {
                                return ChangePasswordRoute();
                              },
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          pressed = true;
                          Utils.showSnackBarError(
                            context,
                            'Your password is not correct',
                          );
                        }
                      } else {
                        Navigator.pop(context);
                        Utils.showSnackBarError(context, 'Invalid Password');
                        pressed = false;
                      }
                    }
                  },
                ),
                // Spacer(
                //   flex: 3,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
