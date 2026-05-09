import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapbooth_mobile/providers/auth_provider.dart';
import 'package:snapbooth_mobile/screens/template_selection_screen.dart';
import 'package:snapbooth_mobile/screens/tutorial_screen.dart';
import 'package:snapbooth_mobile/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final metadata = user?.userMetadata ?? {};
    final displayName = metadata['username'] ?? metadata['full_name'] ?? user?.email ?? 'Guest';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1D3DF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.account_circle, size: 32, color: Color(0xFF741E31)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    tooltip: 'Profile',
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.camera_rounded,
                  size: 100,
                  color: Color(0xFF741E31),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SnapBooth',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF420D19),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Welcome, $displayName',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF741E31),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                _MenuButton(
                  label: 'How it Works',
                  icon: Icons.help_outline,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorialScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  label: 'Choose Template',
                  icon: Icons.grid_view_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TemplateSelectionScreen(),
                      ),
                    );
                  },
                  isPrimary: true,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF741E31) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF741E31),
          elevation: isPrimary ? 5 : 0,
          side: isPrimary ? null : const BorderSide(color: Color(0xFF741E31), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
