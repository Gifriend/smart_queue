import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

// Diubah dari fungsi menjadi StatefulWidget agar bisa mengelola state tanggal
class AddQueueDialog extends StatefulWidget {
  final String userId;
  const AddQueueDialog({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddQueueDialog> createState() => _AddQueueDialogState();
}

class _AddQueueDialogState extends State<AddQueueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedService = 'Tarik Tunai';
  // State untuk menyimpan tanggal yang dipilih, default hari ini
  DateTime _selectedDate = DateTime.now();

  final List<String> services = [
    'Tarik Tunai',
    'Setor Tunai',
    'Layanan Nasabah',
    'Lainnya',
  ];

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Pengguna tidak bisa memilih tanggal kemarin
      lastDate: DateTime.now().add(const Duration(days: 30)), // Batas 30 hari
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ambil Nomor Antrian'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Agar tidak overflow jika keyboard muncul
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sesuai KTP',
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
                value: _selectedService,
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
                    setState(() {
                      _selectedService = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // BARU: UI untuk memilih tanggal
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.calendar_today),
                ),
                title: const Text("Tanggal Kedatangan"),
                subtitle: Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate),
                ),
                onTap: () => _selectDate(context),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final firestoreService = Provider.of<FirestoreService>(
                context,
                listen: false,
              );
              // Panggil fungsi dengan 4 argumen yang dibutuhkan
              firestoreService.addQueueItem(
                _nameController.text.trim(),
                _selectedService,
                widget.userId, // Ambil userId dari widget
                _selectedDate, // Kirim tanggal yang sudah dipilih
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Ambil Nomor'),
        ),
      ],
    );
  }
}
