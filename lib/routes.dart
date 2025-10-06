import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/screen/pages/owner/venue_detail_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/field_detail_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/field_form_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/venue_form_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/home_screen.dart';
import 'package:football_venue_booking_app/screen/pages/admin/auth/add_owner_screen.dart';
import 'package:football_venue_booking_app/screen/pages/admin/auth/detail_user_screen.dart';
import 'main.dart';
import 'screen/splash_screen.dart';
import 'screen/auth/login_screen.dart';
import 'screen/auth/register_screen.dart';
import 'screen/pages/admin/home_screen.dart';
import 'screen/pages/account/detail_account_screen.dart';
import 'screen/pages/account/update_account_screen.dart';
import 'screen/pages/user/venue/detail_venue_screen.dart';
import 'screen/pages/user/field/detail_field_screen.dart';

class AppRoutes {
  static const String main = '/main';
  static const String splashscreen = '/splashscreen';
  static const String login = '/login';
  static const String register = '/register';
  static const String ownerHome = '/ownerHome';
  static const String ownerForm = '/ownerForm';
  static const String ownerDetailVenue = '/ownerDetailVenue';
  static const String ownerFormField = '/ownerFormField';
  static const String ownerDetailField = '/ownerDetailField';
  static const String adminHome = '/adminHome';
  static const String addOwner = '/addOwner';
  static const String detailUser = '/detailUser';
  static const String personalInformation = '/personalInformation';
  static const String updateAccount = '/updateAccount';
  static const String detailVenue= '/detailVenue';
  static const String detailField= '/detailField';

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
        final venueId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VenueDetailScreen(venueId: venueId),
        );
      case ownerFormField:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FieldFormScreen(
            isUpdateForm: args['isUpdateForm'] as bool,
            fieldId: args['fieldId'] as String?,
            venueId: args['venueId'] as String,
          ),
        );
      case ownerDetailField:
        final fieldId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FieldDetailScreen(fieldId: fieldId),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => AdminHomeScreen());
      case addOwner:
        return MaterialPageRoute(builder: (_) => AddOwnerScreen());
      case detailUser:
        final args = settings.arguments as Map<String, dynamic>;
        final uid = args['uid'];  
        return MaterialPageRoute(
          builder: (_) => UserDetailScreen(uid: uid),  
        );
      case personalInformation:
        return MaterialPageRoute(builder: (_) => DetailAccountScreen());
      case updateAccount:
        return MaterialPageRoute(builder: (_) => UpdateAccountScreen());
      case detailVenue:
        final venueId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DetailVenueScreen(venueId: venueId),
        );
      case detailField:
        final fieldId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DetailScreen(fieldId: fieldId),
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