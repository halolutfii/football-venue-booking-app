import 'package:flutter/material.dart';

class DetailBookingScreen extends StatelessWidget {
  final String codeOrder;
  final String status;

  const DetailBookingScreen({
    super.key,
    required this.codeOrder,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Booking',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBookingInformation(context),
            const SizedBox(height: 20),
            Center(  // Membungkus ElevatedButton dengan Center
              child: ElevatedButton(
                onPressed: () {
                  // Action when the button is clicked (e.g., to reset or perform an action)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Action", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display the Booking Information box
  Widget buildBookingInformation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Booking Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          buildListTile(Icons.bookmark, "Order Code: $codeOrder", style: const TextStyle(fontWeight: FontWeight.bold)),
          buildListTile(Icons.access_alarm, "Status: $status", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Build list tile for sections like code_order, status, etc.
  Widget buildListTile(IconData icon, String title, {TextStyle? style, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: style ?? const TextStyle(fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}