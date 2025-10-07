import 'dart:io';
import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/providers/master_provider.dart';
import 'package:provider/provider.dart';

import 'package:football_venue_booking_app/providers/user_provider.dart'; 
import 'package:football_venue_booking_app/routes.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccountScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<MasterProvider>(context, listen: false).loadUsers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MasterProvider userProvider = context.watch<MasterProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  final users = userProvider.users[index];

                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: users.photo != null && users.photo!.isNotEmpty
                            ? NetworkImage(users.photo!)  
                            : null,  
                        child: users.photo == null || users.photo!.isEmpty
                            ? const Icon(Icons.person, size: 30, color: Colors.grey) 
                            : null,  
                      ),
                      title: Text(
                        users.name,
                        style: const TextStyle(fontWeight: FontWeight.bold), 
                      ),
                      subtitle: Text(users.email),
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Users'),
                              content: Text(
                                'Are you sure you want to delete ${users.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    userProvider.deleteUser(users.uid);

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.detailUser, 
                          arguments: {"uid": users.uid}
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}