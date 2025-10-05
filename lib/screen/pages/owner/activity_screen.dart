import 'package:flutter/material.dart';

import 'tabs/booking_owner_screen.dart';
import 'tabs/history_owner_screen.dart';

import '../../../widgets/appbar.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          bottom: TabBar(
            // indicatorColor: Colors.white,
            // labelColor: Colors.white,
            // unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Booking"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookingOwnerScreen(),
            HistoryOwnerScreen(),
          ],
        ),
      ),
    );
  }
}
