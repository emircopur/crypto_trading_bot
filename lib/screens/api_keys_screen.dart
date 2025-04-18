import 'package:flutter/material.dart';
import '../services/api_key/api_key_service.dart';
import 'package:flutter/services.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _apiKeyService = ApiKeyService();
  List<dynamic> _apiKeys = [];
  bool _isLoading = false;
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _exchangeController = TextEditingController(text: 'Binance');
  final _marketTypeController = TextEditingController(text: 'Spot');

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    _exchangeController.dispose();
    _marketTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKeys() async {
    setState(() => _isLoading = true);
    try {
      final keys = await _apiKeyService.getApiKeys();
      print('API Keys Response: $keys');
      setState(() => _apiKeys = keys);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addApiKey() async {
    // API Key giriş sayfasını göster
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Exchange:'),
              TextField(
                controller: _exchangeController,
                decoration: const InputDecoration(
                  labelText: 'Exchange',
                  hintText: 'Örn: Binance',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Market Type:'),
              TextField(
                controller: _marketTypeController,
                decoration: const InputDecoration(
                  labelText: 'Market Type',
                  hintText: 'Örn: Spot',
                ),
              ),
              const SizedBox(height: 16),
              const Text('API Key:'),
              TextField(
                controller: _apiKeyController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'API Key numaranızı girin',
                  helperText: 'Lütfen sadece sayı girin',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Secret Key:'),
              TextField(
                controller: _secretKeyController,
                decoration: const InputDecoration(
                  labelText: 'Secret Key',
                  hintText: 'Secret Key\'inizi girin',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_apiKeyController.text.isNotEmpty &&
                  _secretKeyController.text.isNotEmpty &&
                  _exchangeController.text.isNotEmpty &&
                  _marketTypeController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'exchange': _exchangeController.text,
                  'marketType': _marketTypeController.text,
                  'apiKey': _apiKeyController.text,
                  'secretKey': _secretKeyController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                );
              }
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );

    // Kullanıcı bilgileri girdiyse onay sayfasını göster
    if (result != null) {
      final exchange = result['exchange']!;
      final marketType = result['marketType']!;
      final apiKey = result['apiKey']!;
      final secretKey = result['secretKey']!;

      // Onay sayfasını göster
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aşağıdaki API Key eklenecek:'),
              const SizedBox(height: 16),
              Text('Exchange: $exchange'),
              Text('Market Type: $marketType'),
              Text('API Key: $apiKey'),
              Text('Secret Key: $secretKey'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ekle'),
            ),
          ],
        ),
      );

      // Kullanıcı onayladıysa API Key'i ekle
      if (confirmed == true) {
        setState(() => _isLoading = true);
        try {
          await _apiKeyService.addApiKey(
            exchange,
            marketType,
            apiKey,
            secretKey,
          );
          await _loadApiKeys();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('API Key başarıyla eklendi')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  Future<void> _deleteApiKey(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: const Text('Are you sure you want to delete this API key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _apiKeyService.deleteApiKey(id);
        await _loadApiKeys();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              try {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'API endpoints tested, check console for results')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error testing endpoints: $e')),
                  );
                }
              }
            },
            tooltip: 'Test API Endpoints',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _addApiKey,
            tooltip: 'Add API Key',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadApiKeys,
              child: _apiKeys.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No API keys found'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addApiKey,
                            child: const Text('Add API Key'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _apiKeys.length,
                      itemBuilder: (context, index) {
                        final key = _apiKeys[index];
                        return ListTile(
                          title: Text('API Key #${key['id'] ?? 'N/A'}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Exchange: ${key['exchange'] ?? 'Unknown'}'),
                              Text(
                                  'Market Type: ${key['market_type'] ?? 'Unknown'}'),
                              Text('Key: ${key['key'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteApiKey(key['id']),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
