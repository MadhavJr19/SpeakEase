import 'package:flutter/material.dart';
import 'package:new01/pages/ui/Settings/accinfo.dart';
import 'package:new01/pages/ui/Settings/privacy.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences
import 'package:new01/pages/Auth/login.dart'; // Assuming this is your login page


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Function to delete account
  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently signed in.')),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and will remove all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1. Delete Firestore data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // 2. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clears all stored preferences

      // 3. Delete Firebase Authentication account
      await user.delete();

      // 4. Sign out and redirect to login page
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()), // Adjust to your login page
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        height: 1000,
        child: ListView(
          children: [
            SettingsTile(
              icon: Icons.account_circle,
              title: 'Account Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountInfoPage()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPage()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to Notifications Page
              },
            ),
            SettingsTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              onTap: () => _deleteAccount(context), // Call delete account function
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: title == 'Delete Account' ? Colors.red : theme.iconTheme.color, // Red icon for delete
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: title == 'Delete Account' ? Colors.red : null, // Red text for delete
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}