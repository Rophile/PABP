import 'package:flutter/material.dart';
import 'package:snapbooth_mobile/screens/template_selection_screen.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.grid_view, 'text': 'Pick a template'},
      {'icon': Icons.camera_alt, 'text': 'Strike a pose'},
      {'icon': Icons.timer, 'text': 'Wait for countdown'},
      {'icon': Icons.download, 'text': 'Get your photostrip'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How it Works'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF1D3DF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ready to snap?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF420D19),
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 30),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF741E31),
                          child: Icon(
                            step['icon'] as IconData,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            step['text'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF420D19),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TemplateSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF741E31),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
