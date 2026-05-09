enum TemplateLayout { vertical3, vertical4 }

class PhotostripTemplate {
  final String id;
  final String name;
  final TemplateLayout layout;
  final int slotCount;

  PhotostripTemplate({
    required this.id,
    required this.name,
    required this.layout,
    required this.slotCount,
  });

  static List<PhotostripTemplate> availableTemplates = [
    PhotostripTemplate(
      id: '3-strip-vertical',
      name: '3-Strip Classic',
      layout: TemplateLayout.vertical3,
      slotCount: 3,
    ),
    PhotostripTemplate(
      id: '4-strip-vertical',
      name: '4-Strip Modern',
      layout: TemplateLayout.vertical4,
      slotCount: 4,
    ),
  ];
}
