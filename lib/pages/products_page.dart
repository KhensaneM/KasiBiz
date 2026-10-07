import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const ProductsPage({super.key, this.auth, this.firestore});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  User? get _user => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _productsCollection {
    final user = _user;

    if (user == null) {
      throw StateError('User is not logged in.');
    }

    return _firestore.collection('users').doc(user.uid).collection('products');
  }

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    String selectedType = 'Product';
    bool isSaving = false;

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
                      onChanged: isSaving
                          ? null
                          : (value) {
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
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();

                          final price = double.tryParse(
                            priceController.text.trim(),
                          );

                          if (name.isEmpty) {
                            _showMessage(
                              'Please enter a product or service name.',
                            );
                            return;
                          }

                          if (price == null || price < 0) {
                            _showMessage('Please enter a valid price.');
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await _productsCollection.add({
                              'name': name,
                              'price': price,
                              'type': selectedType,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (!dialogContext.mounted) return;

                            Navigator.of(dialogContext).pop();
                          } on FirebaseException catch (error) {
                            if (!mounted) return;

                            _showMessage(
                              error.message ?? 'Could not save the item.',
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          } catch (_) {
                            if (!mounted) return;

                            _showMessage('Something went wrong while saving.');

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // Do not manually dispose these dialog controllers here.
    // The dialog lifecycle previously caused a Flutter assertion
    // when they were disposed immediately after showDialog.
  }

  Future<void> _deleteItem(String documentId, String itemName) async {
    try {
      await _productsCollection.doc(documentId).delete();

      if (!mounted) return;

      _showMessage('$itemName removed.');
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(error.message ?? 'Could not delete the item.');
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong while deleting.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage products.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products & Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _productsCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final document = products[index];
              final data = document.data();

              final String name = data['name']?.toString() ?? 'Unnamed item';

              final String type = data['type']?.toString() ?? 'Product';

              final num priceValue = data['price'] is num ? data['price'] : 0;

              final double price = priceValue.toDouble();

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
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      const SizedBox(width: 5),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          _deleteItem(document.id, name);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add what your business sells so you can start recording sales.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Product or Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70),
            const SizedBox(height: 16),
            const Text(
              'Could not load your products.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
