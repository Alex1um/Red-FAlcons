import 'package:flutter/material.dart';
import 'package:quick_wallet_app/user_session.dart';


// Login page Widget
class LoginView extends StatefulWidget {
  LoginView({super.key, required this.session});

  UserSession session;

  @override
  State<StatefulWidget> createState() {
    // if (session.is_signed()) {
    //
    // } else {
    return _LoginState();
    // }
  }
}

class _LoginState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Is showing pass?
  bool _showPass = false;

  // Showing error below email field
  String? _emailError;

  // Showing error below password field
  String? _passError;

  // Email field value
  String _email = '';

  // Password field value
  String _password = '';

  // Is future running?
  bool _isSubmitting = false;

  // Request on submit
  void _onSubmit() async {
    if (!_isSubmitting && _formKey.currentState!.validate()) {
      _isSubmitting = true;
      _formKey.currentState!.save();
      try {
        await widget.session
            .login(login: _email, password: _password);
      } catch (e) {
        print("Error: $e");
        if (e.runtimeType == AuthError) {
          var auth_error = e as AuthError;
          _emailError = auth_error.loginMsg;
          _passError = auth_error.passMsg;
        }
      }
      finally {
        _isSubmitting = false;
        setState(() {

        });
      }

      // var bar = ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      // _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Text('Logged In'),
            ElevatedButton(onPressed: () {
              setState(() {
                widget.session.signOut();
              });
            }, child: Text("Log out")),
            ElevatedButton(onPressed: widget.session.save, child: Text("Sync"))
          ],
        ),
      );
    }
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
