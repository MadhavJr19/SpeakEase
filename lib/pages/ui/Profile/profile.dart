import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new01/pages/theme_provider.dart';
import 'package:new01/pages/ui/Profile/update_profile.dart';
import 'package:new01/pages/ui/Settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Auth/authentication.dart';
import 'about.dart';
import 'child_management.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _image;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _loadImagePath();
  }

  Future<void> _fetchUsername() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            _username = docSnapshot['username'];
          });
        } else {
          setState(() {
            _username = user.displayName ?? 'UserName';
          });
        }
      } catch (e) {
        setState(() {
          _username = 'UserName';
        });
      }
    }
  }

  Future<void> _clearData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Store UID for later use
        final String uid = user.uid;

        // Delete user data from Firestore
        await _firestore.collection('users').doc(uid).delete();

        // Clear specific data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        // Reset level progress to Level 1
        await prefs.setInt('level_progress', 1);

        // Remove stored profile image
        await prefs.remove('profile_image_$uid');

        // Clear other user-specific preferences if needed
        // But don't clear the entire SharedPreferences with prefs.clear()

        setState(() {
          _image = null;
          _username = user.displayName ?? 'UserName';
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data cleared successfully.")),
        );

        // Navigate back to profile page (or wherever appropriate)
        // You might want to refresh the profile page instead of navigating away
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImageBase64 = prefs.getString('profile_image_${_auth.currentUser!.uid}');
    if (savedImageBase64 != null) {
      setState(() {
        _image = base64Decode(savedImageBase64);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _image = bytes;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${_auth.currentUser!.uid}', base64Image);
    }
  }

  void _viewProfileImage() {
    final user = FirebaseAuth.instance.currentUser;

    // If there's no profile image to display, return early
    if (_image == null && user?.photoURL == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          image: _image,
          imageUrl: user?.photoURL,
          username: _username ?? user?.displayName ?? 'User',
        ),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  Widget _buildProfileImageWidget() {
    final user = FirebaseAuth.instance.currentUser;

    if (_image != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: MemoryImage(_image!),
      );
    } else if (user?.photoURL != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user!.photoURL!),
      );
    } else {
      return Icon(
        Icons.person_outline,
        size: 60,
        color: Colors.deepPurple.withOpacity(0.7),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Profile',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                themeProvider.isDarkMode
                    ? FontAwesomeIcons.sun
                    : FontAwesomeIcons.moon,
                color: Color(0xFF323232),
                size: 16,
              ),
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFCC80),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  // Title and profile image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR',
                              style: TextStyle(
                                fontFamily: "Impact",
                                fontSize: 40,
                                color: Color(0xFF323232),
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'PROFILE',
                              style: TextStyle(
                                fontFamily: "Impact",
                                fontSize: 40,
                                color: Color(0xFFFDAA40),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _viewProfileImage,
                          child: Stack(
                            children: [
                              _buildProfileImageWidget(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User info card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username display
                          Text(
                            'Username',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF323232),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.alternate_email, color: Color(0xFF323232).withOpacity(0.7), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _username ?? 'username',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email display
                          Text(
                            'Email',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF323232),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, color: Color(0xFF323232).withOpacity(0.7), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  user?.email ?? 'user@gmail.com',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Edit profile button
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Options card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildProfileOptionTile(
                            icon: Icons.settings,
                            text: 'Settings',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsPage()),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildProfileOptionTile(
                            icon: Icons.supervisor_account,
                            text: 'Child Management',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChildManagementPage()),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildProfileOptionTile(
                            icon: Icons.info,
                            text: 'About',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Danger zone card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildProfileOptionTile(
                            icon: Icons.delete_forever,
                            text: 'Clear Data',
                            onTap: _clearData,
                            isRed: true,
                          ),
                          _buildDivider(),
                          _buildProfileOptionTile(
                            icon: Icons.logout,
                            text: 'Logout',
                            onTap: () => signOut(context),
                            isRed: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? Colors.red : Color(0xFF323232).withOpacity(0.7),
        size: 22,
      ),
      title: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isRed ? Colors.red : Color(0xFF323232),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.withOpacity(0.2),
      indent: 16,
      endIndent: 16,
    );
  }
}

// Keep the same ImageViewer functionality
class _ImageViewerPage extends StatefulWidget {
  final Uint8List? image;
  final String? imageUrl;
  final String username;

  const _ImageViewerPage({
    Key? key,
    this.image,
    this.imageUrl,
    required this.username,
  }) : super(key: key);

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  // Transform controller to handle zoom and pan
  final TransformationController _transformationController = TransformationController();

  // Track if we're in zoom mode
  bool _isZoomed = false;

  // Double tap zoom values
  static const double _minScale = 0.8;
  static const double _maxScale = 5.0;
  static const double _doubleTapScale = 3.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // Handle double tap to zoom in/out
  void _handleDoubleTap() {
    if (_isZoomed) {
      // Reset to original size
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    } else {
      // Zoom in to predefined scale
      final Matrix4 newMatrix = Matrix4.identity()..scale(_doubleTapScale);
      _transformationController.value = newMatrix;
      _isZoomed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine what content to display
    Widget content;
    if (widget.image != null) {
      content = Image.memory(widget.image!);
    } else if (widget.imageUrl != null) {
      content = Image.network(widget.imageUrl!);
    } else {
      content = Container(
        color: theme.colorScheme.secondary.withOpacity(0.3),
        child: Center(
          child: Text(
            widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 100, color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Text(
          widget.username,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Add zoom instructions tooltip
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Double-tap to zoom in/out or pinch to zoom'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin: const EdgeInsets.all(double.infinity), // Allow panning beyond boundaries
            child: Hero(
              tag: 'profile_image',
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}