import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/screens/QRLectorComponent.dart';

class TheHeader extends StatelessWidget implements PreferredSizeWidget {
  final qrScan = QrScan();
  final String title;
  TheHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.lightBlue; //(0xff489AC7);
    return AppBar(
      title: Text(this.title),
      //actions: <Widget>[qrScan],
      backgroundColor: primary,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
