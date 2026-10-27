import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/errors/appException.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

import 'AttendancePage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    this.params,
    this.onSignedIn,
    JwtService? jwtService,
    LoginService? loginService,
    this.signedInPage,
  }) : jwtService = jwtService ?? JwtService(),
       loginService = loginService ?? LoginService();

  final Map? params;
  final VoidCallback? onSignedIn;
  final JwtService jwtService;
  final LoginService loginService;
  final Widget? signedInPage;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormMode { LOGIN, FORGOTPASSWORD }

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  final _formRecoverPassKey = new GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isLoading = false;
  bool _passwordChangeInProgress = false;
  int _operationGeneration = 0;
  int _passwordDialogGeneration = 0;
  String _resetPassMessage = "Un token se enviará a su correo";
  // Check if form is valid before perform login or signup
  bool _validateAndSave(GlobalKey<FormState> formKey) {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> loginIn() async {
    await widget.jwtService.removeToken();
    final authentication = await widget.loginService.signIn(_email, _password);
    if (!mounted) return;
    if (!authentication.roles.contains('ROLE_ESTUD')) {
      throw const UnsupportedRoleException();
    }
    final rut = await widget.loginService.fetchRut(
      _email,
      token: authentication.token,
    );
    if (!mounted) return;
    await widget.jwtService.saveSession(
      token: authentication.token,
      username: authentication.username,
      rut: rut,
    );
    if (!mounted) {
      await widget.jwtService.removeToken();
      return;
    }
    widget.onSignedIn?.call();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.signedInPage ?? AttendancePage(),
      ),
    );
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    if (_isLoading ||
        _passwordChangeInProgress ||
        !_validateAndSave(_formKey)) {
      return;
    }
    final submittedMode = _formMode;
    final operationGeneration = ++_operationGeneration;
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    try {
      if (submittedMode == FormMode.LOGIN) {
        await loginIn();
      } else {
        await widget.loginService.recoverPassword(_email);
        if (!mounted ||
            operationGeneration != _operationGeneration ||
            submittedMode != _formMode) {
          return;
        }
        _showPasswordEmailSentDialog();
      }
    } catch (error) {
      if (submittedMode == FormMode.LOGIN) {
        await widget.jwtService.removeToken();
      }
      if (!mounted) return;
      setState(() {
        _errorMessage = submittedMode == FormMode.LOGIN
            ? error is UnsupportedRoleException
                  ? 'Esta cuenta no tiene un flujo habilitado en la app móvil.'
                  : 'No se pudo iniciar sesión. Verifique sus datos o conexión.'
            : 'No se pudo iniciar la recuperación. Intente nuevamente.';
      });
    } finally {
      if (mounted && operationGeneration == _operationGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToLogin() {
    if (_passwordChangeInProgress) return;
    _operationGeneration++;
    _formKey.currentState?.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  void _changeFormToPasswordReset() {
    if (_passwordChangeInProgress) return;
    _operationGeneration++;
    _formKey.currentState?.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.FORGOTPASSWORD;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Stack(children: <Widget>[_showBody(), _showCircularProgress()]),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(height: 0.0, width: 0.0);
  }

  void _showPasswordEmailSentDialog() {
    String _token = '';
    String _newPassword = '';
    var dialogOpen = true;
    final dialogGeneration = ++_passwordDialogGeneration;
    late final Alert passwordAlert;
    passwordAlert = Alert(
      context: context,
      title: _resetPassMessage,
      closeFunction: () {
        if (!dialogOpen) return;
        dialogOpen = false;
        _passwordDialogGeneration++;
        Navigator.of(context, rootNavigator: true).pop();
      },
      content: new Form(
        key: _formRecoverPassKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: _decoration(
                "Ingrese el token",
                Icons.edit,
                textColor: Colors.black,
              ),
              validator: (value) => (value?.isEmpty ?? true)
                  ? 'Token no puede ser menos de 6 longitudes'
                  : null,
              onSaved: (value) => _token = value ?? '',
            ),
            TextFormField(
              maxLines: 1,
              obscureText: true,
              autofocus: false,
              decoration: _decoration(
                "Ingrese su nueva contraseña",
                Icons.lock,
                textColor: Colors.black,
              ),
              validator: (value) => (value?.isEmpty ?? true)
                  ? 'Contraseña no puede estar en blanco'
                  : null,
              onSaved: (value) => _newPassword = value ?? '',
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: () async {
            if (_passwordChangeInProgress ||
                !_validateAndSave(_formRecoverPassKey)) {
              return;
            }
            _passwordChangeInProgress = true;
            try {
              await widget.loginService.changePassword(_token, _newPassword);
              if (!mounted ||
                  !dialogOpen ||
                  dialogGeneration != _passwordDialogGeneration) {
                return;
              }
              dialogOpen = false;
              _passwordDialogGeneration++;
              await passwordAlert.dismiss();
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No se pudo confirmar el cambio de contraseña.',
                  ),
                ),
              );
            } finally {
              _passwordChangeInProgress = false;
            }
          },
          child: Text(
            "Cambiar contraseña",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
    passwordAlert.show().whenComplete(() {
      dialogOpen = false;
      if (dialogGeneration == _passwordDialogGeneration) {
        _passwordDialogGeneration++;
      }
    });
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
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return new Container(height: 0.0);
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "Bienvenido".toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        validator: (value) => (value?.isEmpty ?? true)
            ? 'Correo no puede quedar en blanco'
            : null,
        onSaved: (value) => _email = (value?.trim() ?? ''),
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
          validator: (value) => (value?.isEmpty ?? true)
              ? 'Contraseña no puede estar en blanco'
              : null,
          onSaved: (value) => _password = value ?? '',
        ),
      );
    } else {
      return new Text(
        _resetPassMessage,
        style: new TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new MaterialButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          color: Colors.white, //widget.params['buttonColor'],
          child: _textPrimaryButton(),
          onPressed: _isLoading ? null : _validateAndSubmit,
        ),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new TextButton(
      child: _textSecondaryButton(),
      onPressed: _isLoading ? null : _changeFormToLogin,
    );
  }

  Widget _showForgotPasswordButton() {
    return new TextButton(
      child: _formMode == FormMode.LOGIN
          ? new Text(
              '¿Olvidaste tu contraseña?',
              style: new TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            )
          : new Text(
              '',
              style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300),
            ),
      onPressed: _isLoading ? null : _changeFormToPasswordReset,
    );
  }

  Widget _textPrimaryButton() {
    switch (_formMode) {
      case FormMode.LOGIN:
        return new Text(
          'Entrar',
          style: new TextStyle(fontSize: 20.0, color: Colors.lightGreen),
        );
      case FormMode.FORGOTPASSWORD:
        return new Text(
          'Cambiar contraseña',
          style: new TextStyle(fontSize: 20.0, color: Colors.lightGreen),
        );
    }
  }

  Widget _textSecondaryButton() {
    switch (_formMode) {
      case FormMode.LOGIN:
        return new Text(
          '',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
        );
      case FormMode.FORGOTPASSWORD:
        return new Text(
          'Cancelar',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        );
    }
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
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Icon(icon, color: Colors.lightGreen),
      ),
      hintText: text,
      hintStyle: TextStyle(color: textColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
    );
  }
}
