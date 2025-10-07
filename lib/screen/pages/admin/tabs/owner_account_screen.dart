import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/master_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class OwnerAccountScreen extends StatefulWidget {
  const OwnerAccountScreen({super.key});

  @override
  State<OwnerAccountScreen> createState() => _OwnerAccountState();
}

class _OwnerAccountState extends State<OwnerAccountScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<MasterProvider>(context, listen: false).loadOwners(),
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
                itemCount: userProvider.owners.length,
                itemBuilder: (context, index) {
                  final owner = userProvider.owners[index];

                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: owner.photo != null && owner.photo!.isNotEmpty
                            ? NetworkImage(owner.photo!)  
                            : null,  
                        child: owner.photo == null || owner.photo!.isEmpty
                            ? const Icon(Icons.person, size: 30, color: Colors.grey) 
                            : null,  
                      ),
                      title: Text(
                        owner.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold), 
                      ),
                      subtitle: Text(owner.email),
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Owner'),
                              content: Text(
                                'Are you sure you want to delete ${owner.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    userProvider.deleteOwner(owner.uid);

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
                          arguments: {"uid": owner.uid}
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addOwner, 
          );
        },
        child: const Icon(Icons.person_add_alt_1_sharp, color: const Color.fromARGB(255, 71, 70, 70)),
        backgroundColor: Colors.white, 
      ),
    );
  }
}