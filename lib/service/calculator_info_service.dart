import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calculator_info.dart';
import 'package:flutter/foundation.dart';

class CalculatorInfoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CalculatorInfo>> getInfo(String calculator) async {
    debugPrint('1️⃣ Starting Supabase query...');

    try {
      final response = await _supabase
          .from('calculator_info')
          .select()
          .eq('calculator', calculator)
          .order('section_number', ascending: true);

      debugPrint('2️⃣ Supabase query completed.');

      debugPrint('3️⃣ Rows received: ${response.length}');

      return response.map((item) => CalculatorInfo.fromMap(item)).toList();
    } catch (error, stackTrace) {
      debugPrint('❌ Supabase query error: $error');

      debugPrint('Stack trace: $stackTrace');

      rethrow;
    }
  }
}
