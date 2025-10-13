import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';

class UpdateAccountScreen extends StatefulWidget {
  const UpdateAccountScreen({super.key});

  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  bool isSaving = false;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      Provider.of<UserProvider>(context, listen: false)
          .setSelectedImage(File(picked.path));
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    final provider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      isSaving = true;
    });

    try {
      // Periksa apakah ada foto baru yang di-upload, jika ada, update foto
      if (provider.selectedImage != null) {
        await provider.updateProfileWithPhoto(newPhoto: provider.selectedImage);
      } else {
        await provider.updateProfile(); // Update tanpa foto baru
      }

      // Menampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Profile updated successfully!"),
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

      // Langsung navigasi kembali ke ProfileScreen
      Navigator.pop(context); 

    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Failed to update profile. Please try again."),
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

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Update Account',
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: provider.formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: provider.selectedImage != null
                        ? FileImage(provider.selectedImage!)
                        : (user?.photo != null && user!.photo!.isNotEmpty
                            ? NetworkImage(user.photo!)
                            : null) as ImageProvider<Object>?,
                    child: provider.selectedImage == null &&
                            (user?.photo == null || user!.photo!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E3A59),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: provider.nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Full Name required";
                  if (val.length < 3) return "Min 3 characters";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: provider.phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? "Phone required" : null,
              ),
              const SizedBox(height: 12),

               // Gender
              DropdownButtonFormField<String>(
                value: provider.genderController.text.isEmpty ? null : provider.genderController.text, 
                onChanged: (String? newValue) {
                  provider.genderController.text = newValue ?? '';
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem<String>(
                    value: "Female",
                    child: Text("Female"),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: "Gender",
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Gender required";
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: provider.addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Address required";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              isSaving || provider.isLoading
              ? const Center(child: CircularProgressIndicator()) // Menampilkan loader saat sedang menyimpan
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (provider.formKey.currentState!.validate()) {
                          // Menampilkan dialog konfirmasi sebelum menyimpan
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFFF8F9FA),
                              title: const Text("Are you sure?"),
                              content: const Text("Do you want to save the changes?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx); 
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                
                                    await _saveProfile(context); 
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}