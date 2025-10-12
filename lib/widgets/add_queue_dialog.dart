import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

void showAddQueueDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  String selectedService = 'Tarik Tunai';
  final List<String> services = [
    'Tarik Tunai',
    'Setor Tunai',
    'Layanan Nasabah',
    'Lainnya',
  ];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Ambil Nomor Antrian'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(
                  labelText: 'Jenis Layanan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.miscellaneous_services),
                ),
                items: services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    selectedService = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final firestoreService = Provider.of<FirestoreService>(
                  context,
                  listen: false,
                );
                firestoreService.addQueueItem(
                  nameController.text.trim(),
                  selectedService,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Ambil Nomor'),
          ),
        ],
      );
    },
  );
}
