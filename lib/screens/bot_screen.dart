import 'package:flutter/material.dart';
import '../services/bot/bot_service.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  _BotScreenState createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  List<dynamic> _bots = [];
  final _botService = BotService();

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  // Botları yükle
  void _loadBots() async {
    try {
      var bots = await _botService.getBots();
      setState(() {
        _bots = bots; // API'den gelen bot verilerini al
      });
    } catch (e) {
      print('Error loading bots: $e');
    }
  }

  // Bot oluşturma fonksiyonu
  void _createBot() async {
    Map<String, dynamic> newBot = {};

    try {
      var response = await _botService.createBot(newBot);
      print('Bot created: $response');
      _loadBots(); // Yeni botu listeye eklemek için tekrar yükleyelim
    } catch (e) {
      print('Error creating bot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bot Yönetimi')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _createBot,
            child: const Text('Bot Oluştur'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _bots.length,
              itemBuilder: (context, index) {
                var bot = _bots[index];
                return ListTile(
                  title: Text(bot['name']),
                  subtitle: Text('Symbol: ${bot['symbol']}'),
                  trailing: const Icon(Icons.arrow_forward),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
