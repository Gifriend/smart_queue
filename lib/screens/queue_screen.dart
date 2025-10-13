import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/queue_item.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/add_queue_dialog.dart';
import '../widgets/queue_list_item.dart';
import '../widgets/queue_summary_card.dart';
import '../widgets/transaction_slip_dialog.dart'; // Import slip dialog

class QueueScreen extends StatelessWidget {
  final UserModel user;
  const QueueScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder<List<QueueItem>>(
      stream: firestoreService.getQueueStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final queueList = snapshot.data ?? [];
        final nextNumber = queueList.isNotEmpty
            ? queueList.first.queueNumber
            : -1;

        return Scaffold(
          body: Column(
            children: [
              QueueSummaryCard(
                totalQueue: queueList.length,
                nextNumber: nextNumber,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Antrian Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: queueList.isEmpty
                    ? Center(
                        child: Text(
                          'Antrian Kosong',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: queueList.length,
                        itemBuilder: (context, index) {
                          final item = queueList[index];
                          return QueueListItem(
                            item: item,
                            displayIndex: index + 1,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: user.role == 'admin'
              ? FloatingActionButton.extended(
                  onPressed: queueList.isEmpty
                      ? null
                      : () {
                          final itemToCall = queueList.first;
                          showDialog(
                            context: context,
                            builder: (_) => TransactionSlipDialog(
                              queueItem: itemToCall,
                              tellerId: user.uid,
                            ),
                          );
                        },
                  label: const Text('Panggil Berikutnya'),
                  icon: const Icon(Icons.volume_up),
                  backgroundColor: queueList.isEmpty
                      ? Colors.grey
                      : Theme.of(context).colorScheme.secondary,
                )
              : FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddQueueDialog(userId: user.uid),
                    );
                  },
                  label: const Text('Ambil Antrian'),
                  icon: const Icon(Icons.person_add),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
