import 'package:flutter/material.dart';

import '../admin/tabs/owner_account_screen.dart';
import '../admin/tabs/user_account_screen.dart';

import '../../../widgets/appbar.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const CustomAppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Owners"),
              Tab(text: "Users"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OwnerAccountScreen(),
            UserAccountScreen()
          ],
        ),
      ),
    );
  }
}
