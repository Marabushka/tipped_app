import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tip_app/screens/auth/auth.dart';
import 'package:tip_app/screens/main_screen/main%20_screen.dart';
import 'package:tip_app/services/auth_service.dart';

class Widgettree extends StatefulWidget {
  Widgettree({Key? key}) : super(key: key);

  @override
  State<Widgettree> createState() => _WidgettreeState();
}

class _WidgettreeState extends State<Widgettree> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AuthService>(context);
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return MainScreen();
        } else {
          return AuthPage();
        }
      },
      stream: model.authChanges,
    );
  }
}
