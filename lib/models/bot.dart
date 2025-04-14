// lib/models/bot.dart
class Bot {
  final String id;
  final String name;
  final String symbol;
  final double initialAmount;

  Bot({
    required this.id,
    required this.name,
    required this.symbol,
    required this.initialAmount,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      initialAmount: json['initialAmount'].toDouble(),
    );
  }
}
