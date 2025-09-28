import 'package:flutter/material.dart';

Widget displayText(BuildContext context, String title, String? data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(data ?? "-"),
    ],
  );
}
