import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calculator_education.dart';
import 'package:flutter/foundation.dart';

class CalculatorEducationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CalculatorEducation>> getEducation(
    String calculator,
  ) async {
    try {
      final response = await _supabase
          .from('calculator_education')
          .select()
          .eq('calculator', calculator)
          .order('sort_order');

      return response
          .map(
            (item) => CalculatorEducation.fromMap(item),
          )
          .toList();
    } catch (error) {
      debugPrint(
        'Education load error: $error',
      );
      rethrow;
    }
  }
}