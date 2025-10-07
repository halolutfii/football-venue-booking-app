import 'package:flutter/material.dart';

import '../admin/tabs/owner_account_screen.dart';
import '../admin/tabs/user_account_screen.dart';
import '../admin/tabs/venue_master_screen.dart';
import '../admin/tabs/field_master_screen.dart';

import '../../../widgets/appbar.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const CustomAppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Owners"),
              Tab(text: "Users"),
              Tab(text: "Venues"),
              Tab(text: "Fields"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OwnerAccountScreen(),
            UserAccountScreen(),
            VenueMasterScreen(),
            FieldMasterScreen()
          ],
        ),
      ),
    );
  }
}
