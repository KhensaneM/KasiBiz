import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecordSalePage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const RecordSalePage({super.key, this.auth, this.firestore});

  @override
  State<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends State<RecordSalePage> {
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

  CollectionReference<Map<String, dynamic>> get _salesCollection {
    final user = _user;

    if (user == null) {
      throw StateError('User is not logged in.');
    }

    return _firestore.collection('users').doc(user.uid).collection('sales');
  }

  Future<void> _recordSale(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) async {
    final data = product.data();

    final String productName = data['name']?.toString() ?? 'Unnamed item';

    final String type = data['type']?.toString() ?? 'Product';

    final num priceValue = data['price'] is num ? data['price'] : 0;

    final double price = priceValue.toDouble();

    final quantityController = TextEditingController(text: '1');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        int quantity = 1;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double total = price * quantity;

            return AlertDialog(
              title: Text('Record Sale - $productName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      'Price: R${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: quantityController,
                      enabled: !isSaving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Example: 2',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      onChanged: (value) {
                        final parsedQuantity = int.tryParse(value.trim());

                        setDialogState(() {
                          if (parsedQuantity != null && parsedQuantity > 0) {
                            quantity = parsedQuantity;
                          } else {
                            quantity = 0;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sale Total',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'R${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (quantity <= 0) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Please enter a quantity greater than 0.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
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
                FilledButton.icon(
                  onPressed: isSaving || quantity <= 0
                      ? null
                      : () async {
                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await _salesCollection.add({
                              'productId': product.id,
                              'productName': productName,
                              'type': type,
                              'price': price,
                              'quantity': quantity,
                              'total': total,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sale recorded: '
                                  '$quantity x $productName '
                                  '= R${total.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          } on FirebaseException catch (error) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.message ?? 'Could not record sale.',
                                ),
                              ),
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          } catch (_) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Something went wrong while '
                                  'recording the sale.',
                                ),
                              ),
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.point_of_sale),
                  label: Text(isSaving ? 'Saving...' : 'Record Sale'),
                ),
              ],
            );
          },
        );
      },
    );

    // Do not manually dispose the dialog controller here.
    // The dialog owns its lifecycle while it is displayed.
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to record sales.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Record Sale',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _productsCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data();

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
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    _recordSale(product);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'No products or services yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Add a product or service before '
              'recording a sale.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70),
            SizedBox(height: 16),
            Text(
              'Could not load your products.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Please try again later.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
