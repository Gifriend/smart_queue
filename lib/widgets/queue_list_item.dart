import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/queue_item.dart';
import '../services/firestore_service.dart';

class QueueListItem extends StatelessWidget {
  final QueueItem item;
  final int displayIndex;

  const QueueListItem({
    Key? key,
    required this.item,
    required this.displayIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final time = DateFormat('HH:mm').format(item.timestamp.toDate());
    final colorScheme = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme,
          child: Text(
            item.queueNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Layanan: ${item.service} • Diambil: $time'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          onPressed: () {
            // Konfirmasi sebelum menghapus
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hapus Antrian'),
                content: Text(
                  'Anda yakin ingin menghapus antrian #${item.queueNumber} (${item.name})?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      firestoreService.deleteQueueItem(item.id);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
