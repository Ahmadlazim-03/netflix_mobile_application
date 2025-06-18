import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/pocketbase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authService = PocketBaseService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    final currentUser = _authService.currentUser;
    _nameController = TextEditingController(text: currentUser?.getStringValue('name') ?? '');
    _emailController = TextEditingController(text: currentUser?.getStringValue('email') ?? 'Not logged in');
    _phoneController = TextEditingController(text: currentUser?.getStringValue('phone') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAvatarFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter new password.', isError: true);
      return;
    }
    if (_newPasswordController.text.isNotEmpty && _newPasswordController.text.length < 8) {
      _showSnackBar('New password must be at least 8 characters.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.updateUser(
      name: _nameController.text,
      phone: _phoneController.text,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      avatarPath: _selectedAvatarFile?.path,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result == null) {
        _showSnackBar('Profile updated successfully!', isError: false);
        _oldPasswordController.clear();
        _newPasswordController.clear();
        setState(() { _selectedAvatarFile = null; });
        FocusScope.of(context).unfocus();
      } else {
        if (result != 'No changes to update.') {
          _showSnackBar(result, isError: true);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Edit Account'),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: _selectedAvatarFile != null
                        ? FileImage(_selectedAvatarFile!) as ImageProvider
                        : _authService.getUserAvatarUrl() != null
                            ? NetworkImage(_authService.getUserAvatarUrl().toString())
                            : null,
                    child: _selectedAvatarFile == null && _authService.getUserAvatarUrl() == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.red[700],
                        child: Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            Text('Email', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            TextFormField(controller: _emailController, enabled: false, style: TextStyle(color: Colors.white70), decoration: InputDecoration(filled: true, fillColor: Colors.grey[850], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
            SizedBox(height: 20),
            
            Text('Name', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            TextFormField(controller: _nameController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Enter your name', hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: Colors.grey[800], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            SizedBox(height: 20),

            Text('Phone', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            TextFormField(controller: _phoneController, style: TextStyle(color: Colors.white), keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Enter your phone number', hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: Colors.grey[800], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            
            SizedBox(height: 30),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 20),

            Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Old Password', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            TextFormField(controller: _oldPasswordController, obscureText: true, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Enter old password', hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: Colors.grey[800], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            SizedBox(height: 20),

            Text('New Password', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            TextFormField(controller: _newPasswordController, obscureText: true, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Enter new password (min. 8 characters)', hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: Colors.grey[800], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            SizedBox(height: 40),

            // Tombol Update
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                // --- PERBAIKAN DI SINI ---
                // Menambahkan kembali parameter 'child' yang wajib ada
                child: _isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('Update Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}