import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/template.dart';

class TemplateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all public/system templates
  Future<List<Template>> getTemplates() async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .order('name', ascending: true);
      
      return (response as List).map((item) => Template.fromMap(item)).toList();
    } catch (e) {
      throw 'Error fetching templates: $e';
    }
  }

  // Fetch templates for a specific user (or system templates)
  Future<List<Template>> getUserTemplates(String userId) async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .or('user_id.eq.$userId,is_system.eq.true')
          .order('is_system', ascending: false);
      
      return (response as List).map((item) => Template.fromMap(item)).toList();
    } catch (e) {
      throw 'Error fetching user templates: $e';
    }
  }

  // Create a new template (if allowed by RLS)
  Future<void> createTemplate(Template template) async {
    try {
      await _supabase.from('templates').insert(template.toMap());
    } catch (e) {
      throw 'Error creating template: $e';
    }
  }
}
