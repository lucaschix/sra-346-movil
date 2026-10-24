import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

import 'AttendancePage.dart';
import 'ErrorNotification.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.params, this.onSignedIn});

  final Map params;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormMode { LOGIN, FORGOTPASSWORD }

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  final _formRecoverPassKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;
  String _resetPassMessage = "Un token se enviará a su correo";
  // Check if form is valid before perform login or signup
  bool _validateAndSave(formKey) {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void loginIn() async {
    try {
      await LoginService().signIn(_email, _password);
      await LoginService().fetchRut(_email);
      var jwt = JwtService();
      String token = await jwt.getToken();
      String username = await jwt.getUsername();

      print("Usuario: " + username + " Token:" + token);
      if (username != "" && token != "") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AttendancePage()),
        );
      }
    } catch (e) {
      print('Error: $e');

      ErrorNotification().throwErrors(e, context,LoginPage());
    }
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave(_formKey)) {
      if (_formMode == FormMode.LOGIN) {
        loginIn();
      } else {
        await LoginService().recoverPassword(_email);
        _showPasswordEmailSentDialog();
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  void _changeFormToPasswordReset() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.FORGOTPASSWORD;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _showPasswordEmailSentDialog() {
    String _token;
    String _newPassword;
    Alert(
        context: context,
        title: _resetPassMessage,
        content: new Form(
            key: _formRecoverPassKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  decoration: _decoration("Ingrese el token", Icons.edit,
                      textColor: Colors.black),
                  validator: (value) => value.isEmpty
                      ? 'Token no puede ser menos de 6 longitudes'
                      : null,
                  onSaved: (value) => _token = value,
                ),
                TextFormField(
                  maxLines: 1,
                  obscureText: true,
                  autofocus: false,
                  decoration: _decoration(
                      "Ingrese su nueva contraseña", Icons.lock,
                      textColor: Colors.black),
                  validator: (value) => value.isEmpty
                      ? 'Contraseña no puede estar en blanco'
                      : null,
                  onSaved: (value) => _newPassword = value.trim(),
                ),
              ],
            )),
        buttons: [
          DialogButton(
            onPressed: () async {
              if (_validateAndSave(_formRecoverPassKey)) {
                await LoginService().changePassword(_token, _newPassword);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            child: Text(
              "Cambiar contraseña",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showForgotPasswordButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment.center,
          child: Text("Bienvenido".toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: _decoration("Ingrese su correo institucional", Icons.mail),
        validator: (value) =>
            value.isEmpty ? 'Correo no puede quedar en blanco' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    if (_formMode != FormMode.FORGOTPASSWORD) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: _decoration("Ingrese su contraseña", Icons.lock),
          validator: (value) =>
              value.isEmpty ? 'Contraseña no puede estar en blanco' : null,
          onSaved: (value) => _password = value.trim(),
        ),
      );
    } else {
      return new Text(_resetPassMessage,
          style: new TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: Colors.white));
    }
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white, //widget.params['buttonColor'],
            child: _textPrimaryButton(),
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _textSecondaryButton(),
      onPressed: _changeFormToLogin,
    );
  }

  Widget _showForgotPasswordButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('¿Olvidaste tu contraseña?',
              style: new TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.white))
          : new Text('',
              style:
                  new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300)),
      onPressed: _changeFormToPasswordReset,
    );
  }

  Widget _textPrimaryButton() {
    switch (_formMode) {
      case FormMode.LOGIN:
        return new Text('Entrar',
            style: new TextStyle(fontSize: 20.0, color: Colors.lightGreen));
        break;
      case FormMode.FORGOTPASSWORD:
        return new Text('Cambiar contraseña',
            style: new TextStyle(fontSize: 20.0, color: Colors.lightGreen));
        break;
    }
    return new Spacer();
  }

  Widget _textSecondaryButton() {
    switch (_formMode) {
      case FormMode.LOGIN:
        return new Text('',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300));
        break;
      case FormMode.FORGOTPASSWORD:
        return new Text('Cancelar',
            style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                color: Colors.white));
        break;
    }
    return new Spacer();
  }

  InputDecoration _decoration(text, icon, {textColor = Colors.white54}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(16.0),
      prefixIcon: Container(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(10.0))),
          child: Icon(
            icon,
            color: Colors.lightGreen,
          )),
      hintText: text,
      hintStyle: TextStyle(color: textColor),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }
}
