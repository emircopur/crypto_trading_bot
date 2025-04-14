// lib/widgets/bot_card.dart
import 'package:flutter/material.dart';
import '../models/bot.dart';

class BotCard extends StatelessWidget {
  final Bot bot;
  final VoidCallback onDelete;

  const BotCard({
    super.key,
    required this.bot,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(bot.name),
        subtitle: Text('${bot.symbol} - ${bot.initialAmount} USDT'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
