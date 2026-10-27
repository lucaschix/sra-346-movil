import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/screens/LoginPage.dart';
import 'package:sra_346_movil/src/screens/QRLectorComponent.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';
import 'OvalRightBorderClipper.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({JwtService? jwtService, LoginService? loginService})
    : jwtService = jwtService ?? JwtService(),
      loginService = loginService ?? LoginService();

  final JwtService jwtService;
  final LoginService loginService;

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final _formRecoverPassKey = new GlobalKey<FormState>();
  bool _loggingOut = false;
  bool _passwordChangeInProgress = false;
  int _passwordDialogGeneration = 0;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: OvalRightBorderClipper(),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [BoxShadow(color: Colors.black45)],
        ),
        width: 300,
        child: FutureBuilder<String>(
          future: widget.jwtService.getUsername(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return listTile(context, snapshot.data!);
            } else if (snapshot.hasError) {
              return Text('Error al cargar API. Error: ${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget listTile(context, username) {
    return ListView(
      padding: const EdgeInsets.only(left: 60.0, right: 0),
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(username),
          accountEmail: Text('Estudiante'),
        ),
        QrScan(),
        Divider(height: 2.0),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Cambiar contraseña'),
          onTap: () {
            _changePassword(context);
          },
        ),
        Divider(height: 2.0),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Salir'),
          onTap: _loggingOut ? null : () => _logout(context),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _loggingOut = true);
    try {
      await widget.jwtService.removeToken();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar la sesión.')),
      );
    }
  }

  bool _validateAndSave(GlobalKey<FormState> formKey) {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //TODO problema sin identificar
  void _changePassword(context) {
    if (_passwordChangeInProgress) return;
    String _actualPassword = '';
    String _newPassword = '';
    var dialogOpen = true;
    final dialogGeneration = ++_passwordDialogGeneration;
    late final Alert passwordAlert;
    passwordAlert = Alert(
      context: context,
      title: "Cambiar contraseña",
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
              obscureText: true,
              autofocus: false,
              decoration: _decoration(
                "Ingrese su actual contraseña",
                Icons.lock,
                textColor: Colors.black,
              ),
              validator: (value) => (value?.isEmpty ?? true)
                  ? 'Contraseña no puede estar en blanco'
                  : null,
              onSaved: (value) => _actualPassword = value ?? '',
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
              await widget.loginService.changePasswordInterno(
                _actualPassword,
                _newPassword,
              );
              if (!mounted ||
                  !dialogOpen ||
                  dialogGeneration != _passwordDialogGeneration) {
                return;
              }
              dialogOpen = false;
              _passwordDialogGeneration++;
              await passwordAlert.dismiss();
              if (!mounted) return;
              await widget.jwtService.removeToken();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginPage()),
                (_) => false,
              );
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
