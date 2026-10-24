import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sra_346_movil/src/screens/LoginPage.dart';
import 'package:sra_346_movil/src/screens/QRLectorComponent.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';
import 'package:sra_346_movil/src/services/loginService.dart';
import 'OvalRightBorderClipper.dart';

class DrawerPage extends StatelessWidget {
  final _formRecoverPassKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: OvalRightBorderClipper(),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.blue, boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300,
        child: FutureBuilder(
            future: JwtService().getUsername(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return listTile(context, snapshot.data);
              } else if (snapshot.hasError) {
                return Text('Error al cargar API. Error: ${snapshot.error}');
              }
              return CircularProgressIndicator();
            }),
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
        Divider(
          height: 2.0,
        ),
        ListTile(
            leading: Icon(Icons.edit),
            title: Text('Cambiar contraseña'),
            onTap: () {
              _changePassword(context);
            }),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Salir'),
          onTap: () async {
            var token = await JwtService().removeToken();
            print("Status: " + token);
            if (token == "") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          },
        )
      ],
    );
  }

  bool _validateAndSave(formKey) {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //TODO problema sin identificar
  void _changePassword(context) {
    String _actualPassword;
    String _newPassword;
    Alert(
        context: context,
        title: "Cambiar contraseña",
        content: new Form(
            key: _formRecoverPassKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  obscureText: true,
                  autofocus: false,
                  decoration: _decoration(
                      "Ingrese su actual contraseña", Icons.lock,
                      textColor: Colors.black),
                  validator: (value) => value.isEmpty
                      ? 'Contraseña no puede estar en blanco'
                      : null,
                  onSaved: (value) => _actualPassword = value.trim(),
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
                await LoginService()
                    .changePasswordInterno(_actualPassword, _newPassword);
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
