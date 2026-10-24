import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/screens/AttendancePage.dart';
import 'package:sra_346_movil/src/screens/LoginPage.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //sharedPreferences.setString("token","s");
  var token = await JwtService().getToken();
  runApp(App(token: token));
}

class App extends StatelessWidget {
  App({this.token});
  final token;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: this.token == "" ? LoginPage() : AttendancePage(),
    );
  }
}
