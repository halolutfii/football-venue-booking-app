import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/master_provider.dart';

class AddOwnerScreen extends StatefulWidget {
  const AddOwnerScreen({super.key});

  @override
  State<AddOwnerScreen> createState() => _AddOwnerScreenState();
}

class _AddOwnerScreenState extends State<AddOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TextField builder for reusability
  Widget buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "$label tidak boleh kosong";
        if (label == "Password" && value.length < 6) return "Password minimal 6 karakter";
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterProvider = Provider.of<MasterProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add New Owner',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      buildTextField("Name", _nameController),
                      const SizedBox(height: 12),
                      buildTextField("Email", _emailController),
                      const SizedBox(height: 12),
                      buildTextField("Password", _passwordController, obscure: _obscurePassword),
                      const SizedBox(height: 20),
                      // Create Owner button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
                                    try {
                                      // Call the method to create the owner
                                      await masterProvider.createOwner(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                        _nameController.text.trim(),
                                      );

                                      if (mounted) {
                                        if (masterProvider.errorMessage == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.error, color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Owner created successfully!",
                                                      style: TextStyle(color: Colors.white),
                                                      overflow: TextOverflow.visible,  
                                                      softWrap: true,
                                                    ),
                                                  ),
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
                                          Navigator.pop(context); // Navigate back
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.error, color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      masterProvider.errorMessage ?? "Owner created failed!",
                                                      style: TextStyle(color: Colors.white),
                                                      overflow: TextOverflow.visible,  
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.error, color: Colors.white),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "Register failed: $e",
                                                    style: TextStyle(color: Colors.white),
                                                    overflow: TextOverflow.visible,  
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setState(() => _isLoading = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Create Owner",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}