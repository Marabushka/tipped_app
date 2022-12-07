import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tip_app/screens/auth/auth.dart';
import 'package:tip_app/screens/widget_tree.dart';
import 'package:tip_app/services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Tip app',
        theme: ThemeData(
            primaryColor: Color.fromRGBO(7, 212, 220, 1),
            buttonTheme: ButtonThemeData(
              buttonColor: Color.fromRGBO(7, 212, 220, 1), //  <-- dark color
              textTheme: ButtonTextTheme
                  .primary, //  <-- this auto selects the right color
            )),
        home: Widgettree(),
      ),
    );
  }
}
