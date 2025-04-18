import 'package:flutter/material.dart';
import '../services/bot/bot_service.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  _BotScreenState createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  List<dynamic> _bots = [];
  List<List<dynamic>> _botsHistory = [];
  final _botService = BotService();
  bool _isLoading = false;
  final List<String> _exchanges = ['Binance', 'KuCoin', 'OKX'];
  final List<String> _marketTypes = ['Spot', 'Futures'];

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  // Botları yükle
  Future<void> _loadBots() async {
    setState(() => _isLoading = true);
    try {
      var bots = await _botService.getBots();
      setState(() {
        _botsHistory.add(List.from(_bots)); // Mevcut durumu geçmişe ekle
        _bots = bots;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Botlar yüklenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Bot oluşturma fonksiyonu
  Future<void> _createBot() async {
    String selectedExchange = _exchanges.first;
    String selectedMarketType = _marketTypes.first;
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    final apiKeyIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Bot Oluştur'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bot bilgilerini girin:'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Bot Adı',
                          hintText: 'Örn: BTC/USDT Bot',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bot adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedExchange,
                        decoration: const InputDecoration(
                          labelText: 'Exchange',
                        ),
                        items: _exchanges.map((String exchange) {
                          return DropdownMenuItem<String>(
                            value: exchange,
                            child: Text(exchange),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedExchange = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Exchange seçimi gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMarketType,
                        decoration: const InputDecoration(
                          labelText: 'Market Type',
                        ),
                        items: _marketTypes.map((String marketType) {
                          return DropdownMenuItem<String>(
                            value: marketType,
                            child: Text(marketType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMarketType = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Market Type seçimi gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: symbolController,
                        decoration: const InputDecoration(
                          labelText: 'Sembol',
                          hintText: 'Örn: BTC/USDT',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sembol gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: apiKeyIdController,
                        decoration: const InputDecoration(
                          labelText: 'API Key ID',
                          hintText: 'Örn: 1',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'API Key ID gereklidir';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Geçerli bir sayı giriniz';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'name': nameController.text,
                        'symbol': symbolController.text,
                        'api_key_id': int.parse(apiKeyIdController.text),
                        'exchange': selectedExchange,
                        'market_type': selectedMarketType,
                      });
                    }
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        _botsHistory.add(List.from(_bots)); // Mevcut durumu geçmişe ekle
        await _botService.createBot(result);
        await _loadBots();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bot başarıyla oluşturuldu')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bot oluşturulurken hata oluştu: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Bot silme fonksiyonu
  Future<void> _deleteBot(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bot Sil'),
        content: const Text('Bu botu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        _botsHistory.add(List.from(_bots)); // Mevcut durumu geçmişe ekle
        await _botService.deleteBot(id);
        await _loadBots();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bot başarıyla silindi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bot silinirken hata oluştu: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Geri alma fonksiyonu
  void _undoLastAction() {
    if (_botsHistory.isNotEmpty) {
      setState(() {
        _bots = _botsHistory.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Son işlem geri alındı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bot Yönetimi'),
        actions: [
          if (_botsHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _undoLastAction,
              tooltip: 'Son işlemi geri al',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBots,
            tooltip: 'Botları yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bots.isEmpty
              ? const Center(child: Text('Henüz bot bulunmuyor'))
              : ListView.builder(
                  itemCount: _bots.length,
                  itemBuilder: (context, index) {
                    var bot = _bots[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(bot['name'] ?? 'İsimsiz Bot'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sembol: ${bot['symbol'] ?? 'Belirtilmemiş'}'),
                            Text(
                                'Exchange: ${bot['exchange'] ?? 'Belirtilmemiş'}'),
                            Text(
                                'Market Type: ${bot['market_type'] ?? 'Belirtilmemiş'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Bot düzenleme işlemi
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteBot(bot['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBot,
        child: const Icon(Icons.add),
      ),
    );
  }
}
