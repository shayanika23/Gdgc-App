import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'A',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: ${user?.email ?? 'Not available'}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}