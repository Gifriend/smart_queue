import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/history_item.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  final bool isAdmin;
  final String? userId;
  const HistoryScreen({Key? key, required this.isAdmin, this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Riwayat Transaksi'),
      ),
      body: StreamBuilder<List<HistoryItem>>(
        stream: firestoreService.getHistoryStream(
          userId: isAdmin ? null : userId,
        ),
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
            padding: const EdgeInsets.only(
              top: 8.0,
            ), // Beri sedikit padding di atas
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              // Setiap kartu sekarang bisa ditekan untuk menampilkan detail
              return InkWell(
                onTap: () => _showSlipDialog(context, item),
                child: _buildHistoryCard(context, item),
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan ringkasan di daftar
  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    final servedTime = DateFormat(
      'd MMM yyyy, HH:mm',
      'id_ID',
    ).format(item.servedAt.toDate());
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
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
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Layanan: ${item.service}\nDilayani: $servedTime'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        isThreeLine: true,
      ),
    );
  }

  // BARU: Fungsi untuk menampilkan dialog slip elektronik
  void _showSlipDialog(BuildContext context, HistoryItem item) {
    // Formatter untuk mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // Formatter untuk tanggal dan waktu
    final dateTimeFormatter = DateFormat('EEEE, d MMMM yyyy HH:mm:ss', 'id_ID');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Slip Transaksi Elektronik'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Divider(),
                _buildSlipDetailRow('No. Antrian', item.queueNumber.toString()),
                _buildSlipDetailRow('Nama Nasabah', item.name),
                _buildSlipDetailRow('Layanan', item.service),
                const SizedBox(height: 12),
                const Text(
                  'DETAIL TRANSAKSI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                _buildSlipDetailRow(
                  'Jumlah',
                  currencyFormatter.format(item.transactionAmount),
                ),
                _buildSlipDetailRow(
                  'Catatan',
                  item.transactionNotes.isEmpty ? '-' : item.transactionNotes,
                ),
                const SizedBox(height: 12),
                const Text(
                  'WAKTU & PETUGAS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                _buildSlipDetailRow(
                  'Tanggal Kunjungan',
                  dateTimeFormatter
                          .format(item.appointmentDate.toDate())
                          .split(' ')[0] +
                      ' ' +
                      dateTimeFormatter
                          .format(item.appointmentDate.toDate())
                          .split(' ')[1] +
                      ' ' +
                      dateTimeFormatter
                          .format(item.appointmentDate.toDate())
                          .split(' ')[2],
                ),
                _buildSlipDetailRow(
                  'Waktu Dilayani',
                  dateTimeFormatter.format(item.servedAt.toDate()),
                ),
                _buildSlipDetailRow('ID Teller', item.tellerId),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // BARU: Helper widget untuk membuat baris detail agar kode tidak berulang
  Widget _buildSlipDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          const Text(' : '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
