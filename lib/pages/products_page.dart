import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Map<String, dynamic>> _items = [];

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    String selectedType = 'Product';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Product or Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Example: Kota',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'Example: 35.00',
                        border: OutlineInputBorder(),
                        prefixText: 'R ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Product',
                          child: Text('Product'),
                        ),
                        DropdownMenuItem(
                          value: 'Service',
                          child: Text('Service'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final priceText = priceController.text.trim();
                    final price = double.tryParse(priceText);

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a product or service name.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (price == null || price < 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid price.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _items.add({
                        'name': name,
                        'price': price,
                        'type': selectedType,
                      });
                    });

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // We deliberately do not manually dispose these here.
    // The dialog has already been removed from the widget tree.
  }

  void _deleteItem(int index) {
    final String itemName = _items[index]['name'] as String;

    setState(() {
      _items.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName removed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products & Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _items.isEmpty
          ? _buildEmptyState()
          : _buildItemsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 90,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'No products or services yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add what your business sells so you can start recording sales.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product or Service',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];

        final String name = item['name'] as String;
        final double price = item['price'] as double;
        final String type = item['type'] as String;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            leading: CircleAvatar(
              child: Icon(
                type == 'Product'
                    ? Icons.shopping_bag
                    : Icons.design_services,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(type),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'R${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    _deleteItem(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}