import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/utils/providers.dart';
import 'package:lmaida/utils/routes.dart';
import 'package:lmaida/utils/theme.dart';
import 'package:provider/provider.dart';

import 'SplashScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lmaida',
          theme: theme(),
          initialRoute: SplashScreen.routeName,
          routes: routes,
        ));
  }
}
