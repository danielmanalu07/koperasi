// features/sewa_menyewa/presentation/widgets/edit_asset_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_state.dart';

class EditAssetFormModal extends StatefulWidget {
  final Asset asset; // Asset data to be edited

  const EditAssetFormModal({super.key, required this.asset});

  @override
  State<EditAssetFormModal> createState() => _EditAssetFormModalState();
}

class _EditAssetFormModalState extends State<EditAssetFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedStatus;

  final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing asset data
    _nameController = TextEditingController(text: widget.asset.name);
    _priceController = TextEditingController(
      text: currencyFormat.format(widget.asset.price),
    );
    _descriptionController = TextEditingController(
      text: widget.asset.description,
    );
    _selectedDate = widget.asset.purchaseDate;
    _selectedStatus = widget.asset.status;
  }

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
      initialDate: _selectedDate,
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

      final updatedAsset = Asset(
        id: widget.asset.id, // Keep the original ID
        name: _nameController.text,
        purchaseDate: _selectedDate,
        price: int.parse(cleanedPrice),
        description: _descriptionController.text,
        status: _selectedStatus,
      );

      // context.read<AssetBloc>().add(UpdateAssetEvent(asset: updatedAsset));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBloc, AssetState>(
      listener: (context, state) {
        // if (state is AssetUpdated) {
        //   _dismissLoadingDialog();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Aset berhasil diperbarui!')),
        //   );
        //   Navigator.pop(context); // Close modal bottom sheet
        //   context.read<AssetBloc>().add(LoadAssetEvent()); // Reload assets
        // } else if (state is AssetUpdateError) {
        //   _dismissLoadingDialog();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Gagal memperbarui aset: ${state.message}')),
        //   );
        // } else if (state is AssetUpdating) {
        //   _showLoadingDialog();
        // }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
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
                  margin: const EdgeInsets.only(bottom: 16),
                ),
              ),
              Text(
                'Edit Aset',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
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
                  ),
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
                      text: dateFormat.format(_selectedDate),
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
                    _selectedStatus = newValue!;
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
                    'Simpan Perubahan',
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
