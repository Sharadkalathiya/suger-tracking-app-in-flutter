import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/record_provider.dart';
import '../services/auth_service.dart';
import 'record_entry.dart';
import 'record_list.dart';
import 'record_report.dart';
import 'sweet_report.dart';
import 'auth_screen.dart';
import 'sweet_entry.dart';
import 'sweet_list.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profile = await authService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userName = profile?['name'] ?? user.email?.split('@')[0] ?? 'User';
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _userName = 'User';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      bool shouldLogout = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Logout'),
              ),
            ],
          );
        },
      ) ?? false;

      if (shouldLogout) {
        await FirebaseAuth.instance.signOut();
        // Navigate to auth screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String greeting = _getGreeting();

    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from closing the app
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Records Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Records',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildMenuButton(
                            context,
                            'Enter Record',
                            Icons.add_circle_outline,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecordEntry()),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMenuButton(
                            context,
                            'See Records',
                            Icons.list_alt,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecordList()),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMenuButton(
                            context,
                            'Records Report',
                            Icons.analytics,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecordReport()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Sweets Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Sweets',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildMenuButton(
                            context,
                            'Enter Sweet Data',
                            Icons.add_circle_outline,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SweetEntry()),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMenuButton(
                            context,
                            'See Sweet Entries',
                            Icons.cookie,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SweetList()),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMenuButton(
                            context,
                            'Sweet Report',
                            Icons.pie_chart,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SweetReport()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    String timeGreeting;
    if (hour < 12) timeGreeting = 'Good Morning';
    else if (hour < 16) timeGreeting = 'Good Afternoon';
    else if (hour < 20) timeGreeting = 'Good Evening';
    else timeGreeting = 'Good Night';
    
    return '$timeGreeting, ${_userName ?? 'User'}!';
  }
}

// ... rest of the code stays the same ...