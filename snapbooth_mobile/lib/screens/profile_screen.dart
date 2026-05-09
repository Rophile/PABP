import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapbooth_mobile/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // Extract metadata from Supabase User
    final metadata = user?.userMetadata ?? {};
    final username = metadata['username'] ?? metadata['full_name'] ?? 'Guest';
    final email = user?.email ?? 'No email';
    final lastSignIn = user?.lastSignInAt ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar / Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF741E31),
              child: metadata['avatar_url'] != null
                  ? ClipOval(child: Image.network(metadata['avatar_url']))
                  : Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
            
            // User Name
            Text(
              username,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF420D19),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Profile Details Section
            _ProfileItem(
              icon: Icons.person_outline,
              label: 'Username',
              value: username,
            ),
            _ProfileItem(
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: email,
            ),
            _ProfileItem(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: user?.createdAt != null 
                  ? user!.createdAt.substring(0, 10) 
                  : 'N/A',
            ),
            _ProfileItem(
              icon: Icons.access_time,
              label: 'Last Login',
              value: lastSignIn.toString().split('.')[0],
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.signOut();
                  Navigator.pop(context); // Go back after logout
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF741E31),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1D3DF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF741E31)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF420D19),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
