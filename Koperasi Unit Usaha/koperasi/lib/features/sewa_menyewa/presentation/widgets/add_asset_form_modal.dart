import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_state.dart';

class AddAssetFormModal extends StatefulWidget {
  const AddAssetFormModal({super.key});

  @override
  State<AddAssetFormModal> createState() => _AddAssetFormModalState();
}

class _AddAssetFormModalState extends State<AddAssetFormModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedStatus;

  final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoadingDialogShowing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    if (!_isLoadingDialogShowing) {
      _isLoadingDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      ).then((_) {
        _isLoadingDialogShowing = false;
      });
    }
  }

  void _dismissLoadingDialog() {
    if (_isLoadingDialogShowing && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      _isLoadingDialogShowing = false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstant.blueColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorConstant.blueColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String cleanedPrice = _priceController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '');

      final newAsset = Asset(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        purchaseDate: _selectedDate!,
        price: int.parse(cleanedPrice),
        description: _descriptionController.text,
        status: _selectedStatus!,
      );

      context.read<AssetBloc>().add(AddAssetEvent(asset: newAsset));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBloc, AssetState>(
      listener: (context, state) {
        if (state is AssetCreated) {
          _dismissLoadingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aset berhasil ditambahkan!')),
          );
          Navigator.pop(context);
          context.read<AssetBloc>().add(LoadAssetEvent());
        } else if (state is AssetCreateError) {
          _dismissLoadingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan aset: ${state.message}')),
          );
        } else if (state is AssetCreating) {
          _showLoadingDialog();
        }
      },
      child: Container(
        // Added Container for styling the modal
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          left: 20, // Increased padding
          right: 20, // Increased padding
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, // Increased padding
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(bottom: 16), // Increased margin
                ),
              ),
              Text(
                'Tambah Aset Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20), // Increased spacing
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Aset',
                  hintText: 'Masukkan nama aset',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConstant.blueColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstant.blueColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.inventory, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama aset tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Contoh: 150.000.000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConstant.blueColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstant.blueColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.currency_exchange,
                    color: Colors.grey,
                  ), // Changed to Icon
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  String cleanedValue = value
                      .replaceAll('Rp ', '')
                      .replaceAll('.', '');
                  if (cleanedValue.isEmpty) {
                    _priceController.text = '';
                    return;
                  }
                  try {
                    int parsedValue = int.parse(cleanedValue);
                    String formattedValue = currencyFormat.format(parsedValue);
                    _priceController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                        offset: formattedValue.length,
                      ),
                    );
                  } catch (e) {
                    // Handle non-numeric input gracefully
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  String cleanedValue = value
                      .replaceAll('Rp ', '')
                      .replaceAll('.', '');
                  if (int.tryParse(cleanedValue) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : dateFormat.format(_selectedDate!),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pembelian',
                      hintText: 'Pilih tanggal pembelian',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorConstant.blueColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorConstant.blueColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Tanggal pembelian tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintText:
                      'Deskripsi singkat aset (misal: "Kendaraan roda empat, kondisi baik")',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConstant.blueColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstant.blueColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  hintText: 'Pilih status aset',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConstant.blueColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstant.blueColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                isExpanded: true,
                items: <String>['Aktif', 'Terjual', 'Rusak']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: getStatusColorForDropdown(value),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status tidak boleh kosong';
                  }
                  return null;
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: ColorConstant.blueColor,
                ),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.blueColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Simpan Aset',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColorForDropdown(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green.shade700;
      case 'terjual':
        return Colors.red.shade700;
      case 'rusak':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
