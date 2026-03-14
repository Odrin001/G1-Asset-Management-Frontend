import 'package:flutter/material.dart';

import '../utils/api.dart';

class HomeScreen extends StatelessWidget {
  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextFormField txtEmail = TextFormField(
      decoration: InputDecoration(labelText: 'School Email'),
      keyboardType: TextInputType.emailAddress,
      controller: _txtEmailController,
      textInputAction: TextInputAction.next
    );

    TextFormField txtPassword = TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _txtPasswordController,
      textInputAction: TextInputAction.done
    );

    Container btnLogin = Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.0),
      child: ElevatedButton(
        onPressed: () {
          API().login(
            email: _txtEmailController.text,
            password: _txtPasswordController.text
          ).then((value) {
            if (value == true) {
              const snackBar = SnackBar(content: Text('You have logged in successfully'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        },
        child: Text('Login')
      )
    );

    TextButton btnForgotPassword = TextButton(
      onPressed: () {
        // TODO: Implement forgot password functionality
      },
      child: Text('Forgot Password?')
    );

    TextButton btnSignUp = TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Text('Sign Up')
    );

    Form formLogin = Form(
      child: Column(
        children: [
          txtEmail,
          txtPassword,
          btnForgotPassword,
          btnLogin,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Don\'t have an account? '),
              btnSignUp
            ]
          )
        ]
      )
    );

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
        child: formLogin
      )
    );
  }
}