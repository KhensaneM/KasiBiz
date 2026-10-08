import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SalesHistoryPage extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const SalesHistoryPage({super.key, this.auth, this.firestore});

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore => firestore ?? FirebaseFirestore.instance;

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Date unavailable';
    }

    final date = value.toDate().toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view sales history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('sales')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load sales history.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = snapshot.data!.docs.toList();

          sales.sort((a, b) {
            final first = a.data()['createdAt'];
            final second = b.data()['createdAt'];

            final firstDate = first is Timestamp
                ? first.millisecondsSinceEpoch
                : 0;

            final secondDate = second is Timestamp
                ? second.millisecondsSinceEpoch
                : 0;

            return secondDate.compareTo(firstDate);
          });

          if (sales.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 70,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No sales recorded yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Your recorded sales will appear here.'),
                ],
              ),
            );
          }

          double totalSales = 0;

          for (final sale in sales) {
            final value = sale.data()['total'];

            if (value is num) {
              totalSales += value.toDouble();
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Sales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R${totalSales.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final data = sales[index].data();

                    final name =
                        data['productName']?.toString() ?? 'Unnamed item';

                    final type = data['type']?.toString() ?? 'Product';

                    final quantity = data['quantity'] is num
                        ? (data['quantity'] as num).toInt()
                        : 1;

                    final total = data['total'] is num
                        ? (data['total'] as num).toDouble()
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Icon(
                            type == 'Service'
                                ? Icons.design_services
                                : Icons.shopping_bag,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$type • Quantity: $quantity\n'
                          '${_formatDate(data['createdAt'])}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          'R${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
