import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import 'package:football_venue_booking_app/widgets/text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class FieldFormScreen extends StatefulWidget {
  final bool isUpdateForm;
  final String? fieldId;
  final String venueId;

  const FieldFormScreen({
    super.key,
    required this.isUpdateForm,
    this.fieldId,
    required this.venueId,
  });

  @override
  State<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends State<FieldFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final priceFormatter = MaskTextInputFormatter(
    mask: 'Rp###.###.###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final durationPerMinutes = MaskTextInputFormatter(
    mask: '### Minutes',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    final fieldProvider = context.read<FieldProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isUpdateForm && widget.fieldId != null) {
        fieldProvider.loadFieldById(widget.fieldId!);
      } else {
        fieldProvider.resetForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = context.watch<FieldProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Field Form',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (widget.isUpdateForm) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.ownerDetailField,
                arguments: widget.fieldId,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.ownerDetailVenue,
                arguments: widget.venueId,
              );
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            textField(
                              "Field Name",
                              fieldProvider.nameController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Field name required"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            textField(
                              "Default Price",
                              fieldProvider.priceController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "Price required"
                                  : (int.tryParse(
                                          v.replaceAll(RegExp(r'[^0-9]'), ''),
                                        ) ==
                                        null)
                                  ? "Enter valid number: $v"
                                  : null,
                              keyboardType: TextInputType.number,
                              inputFormatter: CurrencyInputFormatter(),
                            ),
                            const SizedBox(height: 16),

                            textField(
                              "Specifications",
                              fieldProvider.specController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Specifications required"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    tileColor: Colors.grey.shade100,
                                    leading: const Icon(Icons.access_time),
                                    title: const Text("Opening Time"),
                                    subtitle: Text(
                                      fieldProvider.openingTime != null
                                          ? fieldProvider.openingTime.toString()
                                          : "-",
                                    ),
                                    onTap: () =>
                                        fieldProvider.pickTime(context, true),
                                    isThreeLine: true,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ListTile(
                                    tileColor: Colors.grey.shade100,
                                    leading: const Icon(Icons.access_time),
                                    title: const Text("Closing Time"),
                                    subtitle: Text(
                                      fieldProvider.closingTime != null
                                          ? fieldProvider.closingTime.toString()
                                          : "-",
                                    ),
                                    onTap: () =>
                                        fieldProvider.pickTime(context, false),
                                    isThreeLine: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            textField(
                              "Slot Duration (minutes)",
                              fieldProvider.slotDurationController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "Duration required"
                                  : (int.tryParse(v) == null)
                                  ? "Enter valid number"
                                  : null,
                              keyboardType: TextInputType.number,
                              inputFormatter: durationPerMinutes,
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: fieldProvider.pickImage,
                                    icon: const Icon(Icons.image, size: 18),
                                    label: const Text('Pick Image'),
                                  ),
                                  const SizedBox(height: 12),

                                  fieldProvider.photo != null ||
                                          fieldProvider.field?.fieldPhoto !=
                                              null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: fieldProvider.photo != null
                                                  ? Image.file(
                                                      fieldProvider.photo!,
                                                      width: double.infinity,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      fieldProvider
                                                          .field!
                                                          .fieldPhoto!,
                                                      width: double.infinity,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ],
                              ),
                            ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     ElevatedButton.icon(
                            //       onPressed: fieldProvider.pickImage,
                            //       icon: const Icon(Icons.image, size: 18),
                            //       label: const Text('Pick Image'),
                            //     ),
                            //     Expanded(
                            //       child: Align(
                            //         alignment: Alignment.centerRight,
                            //         child: fieldProvider.photo != null
                            //             ? Image.file(
                            //                 fieldProvider.photo!,
                            //                 height: 50,
                            //               )
                            //             : Text("No image selected"),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          if (fieldProvider.photo == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                content: Text(
                                  "Field photo is required",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            );

                            return;
                          }

                          if (widget.isUpdateForm) {
                            await fieldProvider.editField(
                              widget.fieldId!,
                              widget.venueId,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Field updated successfully!"),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Navigator.pushNamed(
                              context,
                              AppRoutes.ownerDetailField,
                              arguments: widget.fieldId,
                            );
                          } else {
                            await fieldProvider.addField(widget.venueId);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Field created successfully!"),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Navigator.pushNamed(
                              context,
                              AppRoutes.ownerDetailVenue,
                              arguments: widget.venueId,
                            );
                          }
                        },
                        child: fieldProvider.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : widget.isUpdateForm
                            ? Text('Edit Field')
                            : Text('Add Field'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
