import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/config/user_role.dart';

import 'main.dart';
import 'screen/splash_screen.dart';
import 'screen/auth/login_screen.dart';
import 'screen/auth/register_screen.dart';
import 'screen/pages/owner/detail_venue_screen.dart';
import 'screen/pages/owner/home_screen.dart';
import 'screen/pages/owner/venue_form_screen.dart';
import 'screen/pages/admin/auth/add_owner_screen.dart';
import 'screen/pages/admin/auth/detail_user_screen.dart';

class AppRoutes {
  static const String main = '/main';
  static const String splashscreen = '/splashscreen';
  static const String login = '/login';
  static const String register = '/register';
  static const String ownerHome = '/ownerHome';
  static const String ownerForm = '/ownerForm';
  static const String ownerDetailVenue = '/ownerDetailVenue';
  static const String adminHome = '/adminHome';
  static const String addOwner = '/addOwner';
  static const String detailUser = '/detailUser';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        final role = settings.arguments as UserRole;
        return MaterialPageRoute(builder: (_) => MainScreen(role: role));
      case splashscreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case ownerHome:
        return MaterialPageRoute(builder: (_) => OwnerHomeScreen());
      case ownerForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VenueFormScreen(
            isUpdateForm: args['isUpdateForm'] as bool,
            venueId: args['venueId'] as String?,
          ),
        );
      case ownerDetailVenue:
        return MaterialPageRoute(builder: (_) => DetailVenueScreen());
      case addOwner:
        return MaterialPageRoute(builder: (_) => AddOwnerScreen());
      case detailUser:
        final args = settings.arguments as Map<String, dynamic>;
        final uid = args['uid'];  // Pass owner UID to UserDetailScreen
        return MaterialPageRoute(
          builder: (_) => UserDetailScreen(uid: uid),  // Pass the UID to UserDetailScreen
        );
    
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
