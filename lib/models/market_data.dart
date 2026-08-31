class MarketData {
  final String symbol;
  final String name;
  final String exchange;
  final String category;
  final double? price;
  final double? previousClose;
  final double? change;
  final double? changePercent;
  final double? dayLow;
  final double? dayHigh;
  final String? currency;
  final String? marketStatus;
  final String? freshness;
  final DateTime? dataTimestamp;
  final DateTime fetchedAt;
  final String source;

  const MarketData({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.category,
    this.price,
    this.previousClose,
    this.change,
    this.changePercent,
    this.dayLow,
    this.dayHigh,
    this.currency,
    this.marketStatus,
    this.freshness,
    this.dataTimestamp,
    required this.fetchedAt,
    required this.source,
  });

  factory MarketData.fromMap(Map<String, dynamic> map,) {
    return MarketData(
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      exchange: map['exchange'] as String,
      category: map['category'] as String,
      price: (map['price'] as num?)?.toDouble(),
      previousClose: (map['previous_close'] as num?)?.toDouble(),
      change: (map['change'] as num?)?.toDouble(),
      changePercent: (map['change_percent'] as num?)?.toDouble(),
      dayLow: (map['day_low'] as num?)?.toDouble(),
      dayHigh: (map['day_high'] as num?)?.toDouble(),
      currency: map['currency'] as String?,
      marketStatus: map['market_status'] as String?,
      freshness: map['freshness'] as String?,
      dataTimestamp: map['data_timestamp'] == null
          ? null: DateTime.parse(
              map['data_timestamp'] as String,
            ),
      fetchedAt: DateTime.parse(map['fetched_at'] as String,),
      source: map['source'] as String,
    );
  }
}