// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/history_item.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Riwayat Transaksi Slip Elektronik',
          style: TextStyle(fontSize: 20.0),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<HistoryItem>>(
        stream: firestoreService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat transaksi.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
              ),
            );
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return _buildHistoryCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    final servedTime = DateFormat(
      'd MMM yyyy, HH:mm:ss',
    ).format(item.servedAt.toDate());
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No. Antrian: ${item.queueNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(height: 20),
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Layanan: ${item.service}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Dilayani pada: $servedTime',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
