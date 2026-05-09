import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapbooth_mobile/models/template.dart';
import 'package:snapbooth_mobile/providers/photobooth_provider.dart';
import 'package:snapbooth_mobile/screens/photobooth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapBooth'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TutorialSection(),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Choose a Template',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF420D19),
                ),
              ),
            ),
            const _TemplateSelectionSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Consumer<PhotoboothProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.selectedTemplate == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhotoboothScreen(),
                              ),
                            );
                          },
                    child: const Text('Start Session'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialSection extends StatelessWidget {
  const _TutorialSection();

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.grid_view, 'text': 'Pick a template'},
      {'icon': Icons.camera_alt, 'text': 'Strike a pose'},
      {'icon': Icons.timer, 'text': 'Wait for countdown'},
      {'icon': Icons.download, 'text': 'Get your photostrip'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFFF1D3DF),
      child: Column(
        children: [
          const Text(
            'How it works',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF420D19),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: steps.map((step) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF741E31),
                    child: Icon(step['icon'] as IconData, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step['text'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TemplateSelectionSection extends StatelessWidget {
  const _TemplateSelectionSection();

  @override
  Widget build(BuildContext context) {
    final templates = PhotostripTemplate.availableTemplates;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return Consumer<PhotoboothProvider>(
            builder: (context, provider, child) {
              final isSelected = provider.selectedTemplate?.id == template.id;
              return GestureDetector(
                onTap: () => provider.selectTemplate(template),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF6BAD6) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF741E31) : Colors.grey.shade300,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for actual template preview image
                      Container(
                        height: 140,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            template.slotCount,
                            (index) => Container(
                              height: 100 / template.slotCount,
                              width: 80,
                              margin: const EdgeInsets.all(2),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        template.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: const Color(0xFF420D19),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
