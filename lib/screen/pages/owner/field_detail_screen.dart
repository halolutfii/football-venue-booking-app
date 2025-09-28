import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import 'package:football_venue_booking_app/widgets/text_display.dart';
import 'package:provider/provider.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FieldProvider>().loadFieldById(widget.fieldId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FieldProvider fieldProvider = context.watch<FieldProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fieldProvider.field?.name ?? "Field",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.ownerDetailVenue,
            arguments: fieldProvider.field!.venueId,
          ),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text("Edit field"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(
                              context,
                              AppRoutes.ownerFormField,
                              arguments: {
                                "isUpdateForm": true,
                                "fieldId": fieldProvider.field!.fieldId,
                                "venueId": fieldProvider.field!.venueId,
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: const Text("Delete field"),
                          onTap: () {
                            Navigator.pop(context);

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                  "Are you sure want to delete venue?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      fieldProvider.removeField(widget.fieldId);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Field deleted successfully!",
                                          ),
                                        ),
                                      );

                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.ownerDetailVenue,
                                        arguments: fieldProvider.field!.venueId,
                                      );
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.more_horiz_outlined),
          ),
        ],
      ),
      body: fieldProvider.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : fieldProvider.errorMessage != null
          ? Scaffold(body: Center(child: Text(fieldProvider.errorMessage!)))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            displayText(
                              context,
                              "Specifications",
                              fieldProvider.field?.specifications ?? '-',
                            ),
                            const SizedBox(height: 16),

                            displayText(
                              context,
                              "Default Price",
                              fieldProvider.field?.defaultPrice != null
                                  ? CurrencyUtil.format(
                                      fieldProvider.field!.defaultPrice,
                                    )
                                  : '-',
                            ),
                            const SizedBox(height: 16),

                            displayText(
                              context,
                              "Slot Duration",
                              "${fieldProvider.field?.slotDurationStr ?? '-'} minutes",
                            ),
                            const SizedBox(height: 16),

                            displayText(
                              context,
                              "Opening Time",
                              fieldProvider.field?.openingTimeStr ?? '-',
                            ),
                            const SizedBox(height: 16),

                            displayText(
                              context,
                              "Closing Time",
                              fieldProvider.field?.closingTimeStr ?? '-',
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
