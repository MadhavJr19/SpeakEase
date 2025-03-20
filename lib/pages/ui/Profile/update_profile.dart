import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    final providers = _auth.currentUser?.providerData.map((e) => e.providerId).toList() ?? [];
    _isPasswordUser = providers.contains('password');
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userData = await _firestore.collection('users').doc(user.uid).get();

    setState(() {
      _nameController.text = userData['name'] ?? '';
      _usernameController.text = userData['username'] ?? '';
      _dobController.text = userData['dob'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
    });
  }

  Future<void> _reauthenticateUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final providers = user.providerData.map((e) => e.providerId).toList();

    try {
      if (providers.contains('password')) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providers.contains('google.com')) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await user.reauthenticateWithProvider(googleProvider);
      } else {
        throw Exception('Unsupported sign-in provider');
      }
    } catch (e) {
      throw Exception('Reauthentication failed: $e');
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _reauthenticateUser();

      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'dob': _dobController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _dobController, decoration: const InputDecoration(labelText: 'DOB')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            if (_isPasswordUser)
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: _updateProfile, child: const Text('Update Profile')),
          ],
        ),
      ),
    );
  }
}
