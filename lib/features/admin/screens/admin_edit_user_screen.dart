import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminEditUserScreen extends StatefulWidget {
  final DocumentSnapshot user;

  const AdminEditUserScreen({super.key, required this.user});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  String? _profileImageUrl;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.user.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name']);
    _emailController = TextEditingController(text: data['email']);
    _roleController = TextEditingController(text: data['role']);
    _profileImageUrl = data['profileImageUrl'];
    _isActive = data['isActive'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_image != null) {
                      _profileImageUrl = await _uploadImage(
                        _image!,
                        widget.user.id,
                      );
                    }
                    widget.user.reference
                        .update({
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'role': _roleController.text,
                          'profileImageUrl': _profileImageUrl,
                          'isActive': _isActive,
                          'updatedAt': FieldValue.serverTimestamp(),
                        })
                        .then((_) {
                          Navigator.pop(context);
                        });
                  }
                },
                child: const Text('Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image de profil',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E6DB)),
            ),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : (_profileImageUrl != null
                      ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.add_a_photo,
                          color: Color(0x66546259),
                          size: 50,
                        )),
          ),
        ),
      ],
    );
  }
}
