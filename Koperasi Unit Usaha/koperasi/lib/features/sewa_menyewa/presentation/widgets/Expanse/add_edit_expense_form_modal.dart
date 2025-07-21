import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_state.dart';

class AddEditExpenseFormModal extends StatefulWidget {
  final Expense? expense; // Null for add, not null for edit

  const AddEditExpenseFormModal({super.key, this.expense});

  @override
  State<AddEditExpenseFormModal> createState() =>
      _AddEditExpenseFormModalState();
}

class _AddEditExpenseFormModalState extends State<AddEditExpenseFormModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  final List<String> _categories = [
    'Gaji Karyawan',
    'Peralatan',
    'Internet',
    'Operasional',
    'Lain-lain',
  ]; // Example categories

  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Populate fields if in edit mode
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    } else {
      _selectedDate = DateTime.now(); // Default date for new expense
      _selectedCategory = _categories.first; // Default category for new expense
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
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
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih tanggal pengeluaran!')),
        );
        return;
      }
      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih kategori pengeluaran!')),
        );
        return;
      }

      final int? amount = int.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah pengeluaran harus angka positif!'),
          ),
        );
        return;
      }

      final expense = Expense(
        id: widget.expense?.id ?? 0, // Use existing ID for edit, 0 for new
        date: _selectedDate!,
        category: _selectedCategory!,
        amount: amount,
        description: _descriptionController.text,
      );

      if (widget.expense == null) {
        context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
      } else {
        context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseActionLoading) {
          _showLoadingDialog();
        } else if (state is ExpenseActionSuccess) {
          _dismissLoadingDialog();
          Navigator.pop(context); // Close the modal
        } else if (state is ExpenseActionError) {
          _dismissLoadingDialog();
        }
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
                widget.expense == null
                    ? 'Tambah Pengeluaran Baru'
                    : 'Edit Pengeluaran',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
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
                      labelText: 'Tanggal Pengeluaran',
                      hintText: 'Pilih tanggal pengeluaran',
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
                        return 'Tanggal pengeluaran tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Pilih kategori pengeluaran',
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
                  prefixIcon: const Icon(Icons.category, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: ColorConstant.blueColor,
                ),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  hintText: 'Masukkan jumlah pengeluaran',
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
                    Icons.attach_money,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Jumlah harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Deskripsi singkat pengeluaran',
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
                    return 'Keterangan tidak boleh kosong';
                  }
                  return null;
                },
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
                  icon: Icon(
                    widget.expense == null ? Icons.add_task : Icons.save,
                    color: Colors.white,
                  ),
                  label: Text(
                    widget.expense == null
                        ? 'Tambah Pengeluaran'
                        : 'Simpan Perubahan',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
}
