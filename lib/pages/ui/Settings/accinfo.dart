import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme_provider.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = 'Loading...';
  String dob = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo();
  }

  Future<void> _fetchAccountInfo() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            username = docSnapshot['username'] ?? 'Not Available';
            email = docSnapshot['email'] ?? 'Not Available';
            phoneNumber = docSnapshot['phone'] ?? 'Not Available';
            dob = docSnapshot['dob'] ?? 'Not Available';
          });
        } else {
          setState(() {
            username = 'Not Available';
            email = 'Not Available';
            phoneNumber = 'Not Available';
            dob = 'Not Available';
          });
        }
      } catch (e) {
        setState(() {
          username = 'Error fetching data';
          email = 'Error fetching data';
          phoneNumber = 'Error fetching data';
          dob = 'Error fetching data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    const lightGradient = LinearGradient(
      colors: [Color(0xffffffff), Color(0xff808080)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const darkGradient = LinearGradient(
      colors: [Color(0xFF212121), Color(0xFF424242)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Account Information'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          height: 1000,
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode ? darkGradient : lightGradient, // Background color if needed
          ),
          child: Column(
            children: [
              const SizedBox(height: 150,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        _infoRow(Icons.person, 'Username', username, theme),
                        const SizedBox(height: 10,),
                        const Divider(),
                        const SizedBox(height: 10,),
                        _infoRow(Icons.email, 'Email', email, theme),
                        const SizedBox(height: 10,),
                        const Divider(),
                        const SizedBox(height: 10,),
                        _infoRow(Icons.phone, 'Phone Number', phoneNumber, theme),
                        const SizedBox(height: 10,),
                        const Divider(),
                        const SizedBox(height: 10,),
                        _infoRow(Icons.calendar_today, 'Date of Birth', dob, theme),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
