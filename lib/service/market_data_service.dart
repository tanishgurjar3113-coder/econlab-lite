import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_data.dart';

class MarketDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MarketData>> getMarketData() async {
    final response = await _supabase
      .from('market_data')
      .select()
      .order('category', ascending: true);

    return response.map((item) => MarketData.fromMap(item)).toList();
  }

  Future<MarketData?> getMarketDataBySymbol(String symbol) async {
    final response = await _supabase
      .from('market_data')
      .select()
      .eq('symbol', symbol)
      .maybeSingle();

    if (response == null) {
      return null;
    }
    return MarketData.fromMap(response);
  }

  Future<List<double>> getPriceHistory(String symbol) async {
    final response = await _supabase
      .from('market_history')
      .select('price')
      .eq('symbol', symbol)
      .order('data_timestamp', ascending: true);

    return response.map((item) => (item['price'] as num).toDouble()
    ).toList();
  }
}