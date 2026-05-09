import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapbooth_mobile/models/template.dart';
import 'package:snapbooth_mobile/providers/photobooth_provider.dart';
import 'package:snapbooth_mobile/screens/photobooth_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['All', 'Classic', 'Aesthetic', 'Retro', 'Minimal', 'Special'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF741E31),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF741E31),
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  final filteredTemplates = category == 'All'
                      ? PhotostripTemplate.availableTemplates
                      : PhotostripTemplate.availableTemplates
                          .where((t) => t.category == category)
                          .toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return _TemplateCard(template: filteredTemplates[index]);
                    },
                  );
                }).toList(),
              ),
            ),
            const _SelectionFooter(),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PhotostripTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoboothProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.selectedTemplate?.id == template.id;
        return GestureDetector(
          onTap: () => provider.selectTemplate(template),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF1D3DF) : Colors.white,
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
              children: [
                const SizedBox(height: 15),
                // Visual Template Preview
                Expanded(
                  child: Center(
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: template.backgroundColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade400, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Frames
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              template.slotCount,
                              (index) => Container(
                                height: 120 / template.slotCount,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  border: Border.all(color: template.accentColor.withAlpha(100), width: 1),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: template.accentColor.withAlpha(50),
                                ),
                              ),
                            ),
                          ),
                          // Decorative Elements (Ribbon/Stickers simulated)
                          if (template.category == 'Aesthetic')
                            Positioned(
                              top: -5,
                              right: -5,
                              child: Icon(Icons.bookmark, color: template.accentColor, size: 24),
                            ),
                          if (template.category == 'Retro')
                            Positioned(
                              bottom: 2,
                              left: 2,
                              child: Text(
                                'MAY 2026',
                                style: TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                  color: template.accentColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        template.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF420D19),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${template.slotCount} Frames',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectionFooter extends StatelessWidget {
  const _SelectionFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Consumer<PhotoboothProvider>(
        builder: (context, provider, child) {
          final isSelected = provider.selectedTemplate != null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    'Selected: ${provider.selectedTemplate!.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF741E31),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: !isSelected
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhotoboothScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF741E31),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Start',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
