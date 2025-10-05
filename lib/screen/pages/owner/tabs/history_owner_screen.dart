import 'package:flutter/material.dart';

class Field {
  final String uid;
  final String code_order;
  final String status;
  final String? photo;

  Field({
    required this.uid,
    required this.code_order,
    required this.status,
    this.photo,
  });
}

class HistoryOwnerScreen extends StatelessWidget {
  const HistoryOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Field> fields = [
      Field(uid: '1', code_order: 'BOOK@1', status: 'Completed', photo: ''),
      Field(uid: '3', code_order: 'BOOK@2', status: 'Completed', photo: ''),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) {
            final field = fields[index];

            return Card(
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], 
                    image: field.photo != null && field.photo!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(field.photo!),
                            fit: BoxFit.cover,
                          )
                        : null,  // Menggunakan gambar jika ada
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: field.photo == null || field.photo!.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                ),
                title: Text(field.code_order),
                subtitle: Text(field.status),
                onTap: () async {
                  // Navigasi ke detail
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
