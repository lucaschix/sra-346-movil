import 'package:flutter/material.dart';
import 'package:sra_346_movil/src/screens/AttendancePage.dart';
import 'package:sra_346_movil/src/screens/LoginPage.dart';
import 'package:sra_346_movil/src/services/jwtService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  App({
    this.token,
    JwtService? jwtService,
    this.signedInPage,
    this.signedOutPage,
  }) : jwtService = jwtService ?? JwtService();

  /// Compatibilidad con llamadas antiguas: el token aislado nunca basta.
  final String? token;
  final JwtService jwtService;
  final Widget? signedInPage;
  final Widget? signedOutPage;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool? _sessionIsUsable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.token == '') {
      _sessionIsUsable = false;
    } else {
      _checkSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkSession(resetIfInvalid: true);
  }

  Future<void> _checkSession({bool resetIfInvalid = false}) async {
    final usable = await widget.jwtService.hasUsableSession();
    if (!mounted) return;
    setState(() => _sessionIsUsable = usable);
    if (!usable && resetIfInvalid) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget.signedOutPage ?? LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: ThemeData(useMaterial3: false),
      home: _sessionIsUsable == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _sessionIsUsable!
          ? widget.signedInPage ?? AttendancePage()
          : widget.signedOutPage ?? LoginPage(),
    );
  }
}
