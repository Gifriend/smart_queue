import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/queue_item.dart';
import '../services/firestore_service.dart';

class TransactionSlipDialog extends StatefulWidget {
  final QueueItem queueItem;
  final String tellerId;
  const TransactionSlipDialog({
    Key? key,
    required this.queueItem,
    required this.tellerId,
  }) : super(key: key);

  @override
  State<TransactionSlipDialog> createState() => _TransactionSlipDialogState();
}

class _TransactionSlipDialogState extends State<TransactionSlipDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Slip Transaksi No. ${widget.queueItem.queueNumber}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nama: ${widget.queueItem.name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Layanan: ${widget.queueItem.service}"),
              const Divider(height: 24),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Transaksi (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (val) =>
                    val!.isEmpty ? 'Jumlah tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_add),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final firestoreService = Provider.of<FirestoreService>(
                context,
                listen: false,
              );
              await firestoreService.completeQueueItem(
                item: widget.queueItem,
                tellerId: widget.tellerId,
                transactionAmount:
                    double.tryParse(_amountController.text) ?? 0.0,
                transactionNotes: _notesController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Selesaikan Transaksi'),
        ),
      ],
    );
  }
}
