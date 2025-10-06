import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/screen/pages/user/home_screen.dart';
import 'package:football_venue_booking_app/screen/pages/account/account_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/activity_screen.dart';
import 'package:football_venue_booking_app/screen/pages/owner/home_screen.dart';
import 'package:football_venue_booking_app/screen/pages/user/booking_screen.dart';
import 'package:football_venue_booking_app/screen/pages/admin/home_screen.dart';
import 'package:football_venue_booking_app/screen/pages/admin/user_management_screen.dart';

List<Widget> getPages(UserRole role) {
  final pages = <Widget>[];

  // add admin screen here
  if (role == UserRole.admin) {
    pages.add(AdminHomeScreen());
    pages.add(UserManagementScreen());
  }

  if (role == UserRole.owner) {
    pages.add(OwnerHomeScreen());
    pages.add(ActivityScreen());
  }

  if (role == UserRole.user) {
    pages.add(HomeScreen());
    pages.add(BookingScreen());
  }

  pages.add(AccountScreen());

  return pages;
}

List<BottomNavigationBarItem> getBottomNavItems(UserRole role) {
  final items = <BottomNavigationBarItem>[];

  items.add(
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  );

  if (role == UserRole.admin) {
    items.add(
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        label: 'User Management',
      ),
    );
  }

  if (role == UserRole.owner) {
    items.add(
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        label: 'Activity',
      ),
    );
  }

  if (role == UserRole.user) {
    items.add(
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Booking',
      ),
    );
  }

  items.add(
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
  );

  return items;
}

List<String> getTitles(UserRole role) {
  final titles = <String>[];

  titles.add('Home');

  if (role == UserRole.admin) {
    titles.add('User Management');
  }

  if (role == UserRole.owner) {
    titles.add('Activity');
  }

  if (role == UserRole.user) {
    titles.add('Booking');
  }

  titles.add('Account');

  return titles;
}
