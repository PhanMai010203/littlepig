import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/page_template.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'navigation.transactions'.tr(),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter transactions')),
            );
          },
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search transactions')),
            );
          },
          icon: const Icon(Icons.search),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new transaction')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(                leading: CircleAvatar(
                backgroundColor: index % 2 == 0
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                child: Icon(
                  index % 2 == 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: index % 2 == 0 ? Colors.green : Colors.red,
                ),
              ),
              title: Text('Transaction ${index + 1}'),
              subtitle: Text('${index % 2 == 0 ? 'Income' : 'Expense'} • Today'),
              trailing: Text(
                '${index % 2 == 0 ? '+' : '-'}\$${(index + 1) * 50}.00',
                style: TextStyle(
                  color: index % 2 == 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped Transaction ${index + 1}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 