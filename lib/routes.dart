import 'package:flutter/material.dart';

import 'main.dart';
import 'screen/splash_screen.dart';
import 'screen/auth/login_screen.dart';
import 'screen/auth/register_screen.dart';

class AppRoutes {
  static const String main = '/main';
  static const String splashscreen = '/splashscreen';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case splashscreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}