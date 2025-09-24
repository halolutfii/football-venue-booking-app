import 'package:flutter/material.dart';
import '../../../widgets/appbar.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Booked"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Booked content')),
            Center(child: Text('History content')),
          ],
        ),
      ),
    );
  }
}