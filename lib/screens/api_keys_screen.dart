import 'package:flutter/material.dart';
import '../services/api_key/api_key_service.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _apiKeyService = ApiKeyService();
  List<dynamic> _apiKeys = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
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
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddApiKeyDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _apiKeyService.addApiKey(
          result['exchange']!,
          result['marketType']!,
          result['key']!,
          result['secretKey']!,
        );
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadApiKeys,
              child: _apiKeys.isEmpty
                  ? const Center(child: Text('No API keys found'))
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
                              Text('Key: ${key['key']?.substring(0, 5)}...'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addApiKey,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddApiKeyDialog extends StatefulWidget {
  const AddApiKeyDialog({super.key});

  @override
  State<AddApiKeyDialog> createState() => _AddApiKeyDialogState();
}

class _AddApiKeyDialogState extends State<AddApiKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exchangeController = TextEditingController();
  final _marketTypeController = TextEditingController();
  final _keyController = TextEditingController();
  final _secretKeyController = TextEditingController();

  @override
  void dispose() {
    _exchangeController.dispose();
    _marketTypeController.dispose();
    _keyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add API Key'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _exchangeController,
              decoration: const InputDecoration(labelText: 'Exchange'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the exchange';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _marketTypeController,
              decoration: const InputDecoration(labelText: 'Market Type'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the market type';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _keyController,
              decoration: const InputDecoration(labelText: 'API Key'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the API key';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(labelText: 'Secret Key'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the secret key';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'exchange': _exchangeController.text,
                'marketType': _marketTypeController.text,
                'key': _keyController.text,
                'secretKey': _secretKeyController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
