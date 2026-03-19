import 'package:flutter/material.dart';

import '../utils/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();

  @override
  void dispose() {
    _txtEmailController.dispose();
    _txtPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await API().login(
      email: _txtEmailController.text,
      password: _txtPasswordController.text,
    );

    if (!mounted) return;

    final snackBar = SnackBar(
      content: Text(
        success ? 'You have logged in successfully' : 'Login failed. Please check your credentials.',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final txtEmail = TextFormField(
      decoration: const InputDecoration(labelText: 'School Email'),
      keyboardType: TextInputType.emailAddress,
      controller: _txtEmailController,
      textInputAction: TextInputAction.next,
    );

    final txtPassword = TextFormField(
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _txtPasswordController,
      textInputAction: TextInputAction.done,
    );

    final btnLogin = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10.0),
      child: ElevatedButton(
        onPressed: _handleLogin,
        child: const Text('Login'),
      ),
    );

    final btnForgotPassword = TextButton(
      onPressed: () {
        // TODO: Implement forgot password functionality
      },
      child: const Text('Forgot Password?'),
    );

    final btnSignUp = TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: const Text('Sign Up'),
    );

    final formLogin = Form(
      child: Column(
        children: [
          txtEmail,
          txtPassword,
          btnForgotPassword,
          btnLogin,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Don\'t have an account? '),
              btnSignUp,
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
        child: formLogin,
      ),
    );
  }
}
