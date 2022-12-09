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

  // Showing error below login field
  String? _loginError;

  // Showing error below password field
  String? _passError;

  // Email field value
  String _login = '';

  // Password field value
  String _password = '';

  // Is future running?
  bool _isSubmitting = false;

  // Request on submit
  void _onSubmit({bool isRegister = false}) async {
    if (!_isSubmitting && _formKey.currentState!.validate()) {
      _isSubmitting = true;
      _formKey.currentState!.save();
      try {
        if (isRegister) {
          await widget.session.register(login: _login, password: _password);
        }
        await widget.session.login(login: _login, password: _password);
      } catch (e) {
        print("Error: $e");
        if (e.runtimeType == AuthError) {
          var auth_error = e as AuthError;
          _loginError = auth_error.loginMsg;
          _passError = auth_error.passMsg;
        }
      } finally {
        _isSubmitting = false;
        setState(() {});
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/bg-3.JPG'), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Logged In as',style: TextStyle(fontSize: 16),),
                    SizedBox(
                      height: 10,
                    ),
                    Text(widget.session.name!, style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 50,
                    ),
                    // Row(children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.session.signOut();
                          });
                        },
                        child: const Text("Log out")),
                    // ]),
                    SizedBox(
                      height: 100,
                    ),
                    ElevatedButton(
                        onPressed: widget.session.saveCards,
                        child: Icon(Icons.sync))
                  ],
                ),
              ),
            ),
          ));
    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/bg-3.JPG'), fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text('Login'),
                      errorText: _loginError,
                    ),
                    onSaved: (login) {
                      _login = login!;
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: _onSubmit, child: const Text('Sign in')),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                            ),
                            onPressed: () => _onSubmit(isRegister: true),
                            child: const Text('Sign up')),
                      ]),
                ],
              ),
            ),
          ),
        ));
  }
}
