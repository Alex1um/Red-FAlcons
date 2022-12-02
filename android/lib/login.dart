import 'package:flutter/material.dart';
import 'package:requests/requests.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPass = false;
  String? _emailError;
  String? _passError;

  void _onSubmit() {}


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
              ),
              CheckboxListTile(
                title: const Text('Show password'),
                value: _showPass,
                onChanged: (value) => {
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
