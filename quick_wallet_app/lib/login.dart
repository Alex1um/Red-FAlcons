import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'config.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPass = false;
  String? _emailError;
  String? _passError;
  String _email = '';
  String _password = '';
  bool _isSubmitting = false;

  void _onSubmit() async {
    if (!_isSubmitting && _formKey.currentState!.validate()) {
      _isSubmitting = true;
      var bar = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
      _formKey.currentState!.save();
      var creds = {'login': _email, 'password': _password};
      try {
        var res = await Requests.get('$serverAddress/login',
          json: creds,
          port: serverPort,
          timeoutSeconds: 2,
        );
      } finally {
        _isSubmitting = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Email address'),
                  hintText: 'email@example.org',
                  errorText: _emailError,
                ),
                onSaved: (email) {
                  _email = email!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text('Password'),
                  hintText: _showPass ? '123456' : '******',
                  errorText: _passError,
                ),
                obscureText: !_showPass,
                enableSuggestions: false,
                autocorrect: false,
                onSaved: (pass) {
                  _password = pass!;
                },
              ),
              CheckboxListTile(
                title: const Text('Show password'),
                value: _showPass,
                onChanged: (value) =>
                {
                  setState(() {
                    // if (value != null) {
                    _showPass = value!;
                    // }
                  })
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              ElevatedButton(onPressed: _onSubmit, child: const Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
