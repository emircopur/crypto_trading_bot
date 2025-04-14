import 'package:flutter/material.dart';

class CreateBotDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String? selectedApiKey;
  final String? selectedSymbol;
  final List<String> apiKeys;
  final List<String> symbols;
  final void Function(String?) onApiKeyChanged;
  final void Function(String?) onSymbolChanged;
  final VoidCallback onCreate;

  const CreateBotDialog({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.selectedApiKey,
    required this.selectedSymbol,
    required this.apiKeys,
    required this.symbols,
    required this.onApiKeyChanged,
    required this.onSymbolChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Bot Oluştur'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Bot Adı'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Başlangıç Miktarı (USDT)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value:
                  (selectedApiKey != null && apiKeys.contains(selectedApiKey))
                      ? selectedApiKey
                      : null,
              hint: const Text('API Key Seç'),
              isExpanded: true,
              onChanged: onApiKeyChanged,
              items: apiKeys
                  .map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(key),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value:
                  (selectedSymbol != null && symbols.contains(selectedSymbol))
                      ? selectedSymbol
                      : null,
              hint: const Text('Sembol Seç'),
              isExpanded: true,
              onChanged: onSymbolChanged,
              items: symbols
                  .map((symbol) => DropdownMenuItem(
                        value: symbol,
                        child: Text(symbol),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: onCreate,
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
