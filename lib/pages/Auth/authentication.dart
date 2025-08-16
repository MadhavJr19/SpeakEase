import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:new01/pages/Auth/signup.dart';
import 'login.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Top gradient background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.45,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF62D0FF),
                      Color(0xFFFFCC80),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // Character image
            // Character animation

            Positioned(
              top: screenHeight * 0.01,
              left: 0,
              right: 0,
              child: SizedBox(
                height: screenHeight * 0.27,
                child: Lottie.asset(
                  'assets/Lottie/sky.json', // Replace with your Lottie file
                  //fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.08,
              left: 0,
              right: 0,
              child: SizedBox(
                height: screenHeight * 0.57,
                child: Lottie.asset(
                  'assets/Lottie/happy.json', // Replace with your Lottie file
                  //fit: BoxFit.contain,
                ),
              ),
            ),


            // Content area
            SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 430), // Adjusted spacing

                    // Welcome text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            'WELCOME!',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF323232),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose your preferred sign-in method',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Color(0xFF646464),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Sign-in buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          // Login Button
                          _buildModernButton(
                            context: context,
                            icon: Icon(Icons.login_rounded, size: 24, color: Colors.white),
                            text: "Log In".toUpperCase(),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()), // Replace with Login Page if available
                              );
                            },
                          ),

                          SizedBox(height: 20),

                          // Sign Up Button
                          _buildModernButton(
                            context: context,
                            icon: Icon(Icons.person_add_rounded, size: 24, color: Colors.white),
                            text: "Sign Up".toUpperCase(),
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpPage()), // Sign Up Page
                              );
                            },
                          ),
                        ],
                      ),
                    ),


                    SizedBox(height: 40),

                    // Terms and privacy
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Terms & Privacy Policy",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF646464),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Sign-in Button Function
  Widget _buildModernButton({
    required BuildContext context,
    required Widget icon, // Accepts both Icon and Image.asset
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    required double elevation,
    required VoidCallback onPressed,
  }) {
    return Container(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Row(
              children: [
                SizedBox(width: 20),
                icon, // ✅ Displays both Icon or Image.asset
                SizedBox(width: 16),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 16),
                SizedBox(width: 20),
              ],
            ),
            ),
        );
    }
}
