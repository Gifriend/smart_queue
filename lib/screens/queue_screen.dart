import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/queue_item.dart';
import '../services/firestore_service.dart';
import '../widgets/add_queue_dialog.dart';
import '../widgets/queue_list_item.dart';
import '../widgets/queue_summary_card.dart';
import 'history_screen.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('SmartQueue BSG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lihat Riwayat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Bersihkan Semua Antrian',
            onPressed: () =>
                _showClearAllConfirmation(context, firestoreService),
          ),
        ],
      ),
      body: StreamBuilder<List<QueueItem>>(
        stream: firestoreService.getQueueStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              children: [
                const QueueSummaryCard(totalQueue: 0, nextNumber: -1),
                Expanded(
                  child: Center(
                    child: Text(
                      'Antrian Kosong',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }

          final queueList = snapshot.data!;
          final nextNumber = queueList.isNotEmpty
              ? queueList.first.queueNumber
              : -1;

          return Column(
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
                    'Daftar Antrian Saat Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: queueList.length,
                  itemBuilder: (context, index) {
                    final item = queueList[index];
                    return QueueListItem(item: item, displayIndex: index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => showAddQueueDialog(context),
              heroTag: 'addQueue',
              icon: const Icon(Icons.person_add),
              label: const Text('Ambil Antrian'),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              onPressed: () {
                if (context.read<FirestoreService>() != null) {
                  firestoreService.callNextItem();
                }
              },
              heroTag: 'callNext',
              icon: const Icon(Icons.volume_up),
              label: const Text('Panggil'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showClearAllConfirmation(
    BuildContext context,
    FirestoreService service,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus SEMUA data antrian? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ya, Hapus Semua',
                style: TextStyle(color: Colors.red.shade600),
              ),
              onPressed: () {
                service.clearAllQueue();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua antrian telah dibersihkan.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
