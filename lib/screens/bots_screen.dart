// lib/screens/bots_screen.dart
import 'package:flutter/material.dart';
import '../models/bot.dart';
import '../widgets/bot_card.dart';
import '../widgets/create_bot_dialog.dart';

class BotsScreen extends StatefulWidget {
  const BotsScreen({super.key});

  @override
  State<BotsScreen> createState() => _BotsScreenState();
}

class _BotsScreenState extends State<BotsScreen> {
  List<Bot> bots = [];
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  String selectedApiKey = '';
  String selectedSymbol = '';
  List<String> apiKeyService = ['', ''];
  List<String> symbols = ['BTCUSDT', 'ETHUSDT'];

  void createBot() {
    setState(() {
      bots.add(Bot(
        id: DateTime.now().toString(),
        name: nameController.text,
        symbol: selectedSymbol,
        initialAmount: double.tryParse(amountController.text) ?? 0,
      ));
      nameController.clear();
      amountController.clear();
    });
    Navigator.of(context).pop();
  }

  void deleteBot(String id) {
    setState(() {
      bots.removeWhere((bot) => bot.id == id);
    });
  }

  void showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateBotDialog(
        nameController: nameController,
        amountController: amountController,
        selectedApiKey: selectedApiKey,
        selectedSymbol: selectedSymbol,
        apiKeys: apiKeyService,
        symbols: symbols,
        onApiKeyChanged: (val) => setState(() => selectedApiKey = val ?? ''),
        onSymbolChanged: (val) => setState(() => selectedSymbol = val ?? ''),
        onCreate: createBot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botlar')),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bots.length,
        itemBuilder: (_, index) {
          final bot = bots[index];
          return BotCard(bot: bot, onDelete: () => deleteBot(bot.id));
        },
      ),
    );
  }
}
