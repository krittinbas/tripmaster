import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  _ForgetPageState createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.isEmpty) {
      _showErrorBottomSheet('Please enter your email address');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      _showSuccessBottomSheet(
          'Password reset email sent! Please check your inbox.');
    } catch (e) {
      _showErrorBottomSheet('Error: ${e.toString()}');
    }
  }

  // Function to show success bottom sheet and navigate to /login on OK
  void _showSuccessBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allow the bottom sheet to be full screen if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0, // Make the width fill the screen
          heightFactor: 0.25, // Adjust the height
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white, // White background
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close bottom sheet
                    Navigator.pushNamed(
                        context, '/login'); // Navigate to login page
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(216, 47), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF00164F),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show error bottom sheet
  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0, // Make the width fill the screen
          heightFactor: 0.25, // Adjust the height as needed
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white, // White background
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(216, 47), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF00164F),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content to top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add some padding at the top to control how much space to leave
            const SizedBox(
                height: 80), // Adjust this value to move content up or down

            // Fingerprint Icon in Circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00164F), // Icon background color (from theme)
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 50,
                color: Colors.white, // Icon color
              ),
            ),
            const SizedBox(height: 20), // Spacing

            // Title
            const Text(
              'Forget password?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00164F), // Text color from theme
              ),
            ),
            const SizedBox(height: 10), // Spacing

            // Subtitle
            const Text(
              'Enter your email for instructions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Subtitle color (soft grey)
              ),
            ),
            const SizedBox(height: 40), // Spacing

            // Email Input Field with Container for shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _emailController, // Email controller
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none, // No visible border
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 16.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // Spacing

            // Send OTP Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: 216, // Set button width
                height: 47, // Set button height
                child: ElevatedButton(
                  onPressed: () {
                    _sendPasswordResetEmail();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    backgroundColor:
                        const Color(0xFF00164F), // Button color (theme primary)
                    shadowColor: Colors.black45,
                    elevation: 5, // Add shadow for button
                  ),
                  child: const Text(
                    'Reset Password', // Change button text
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Text color (white on primary)
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
