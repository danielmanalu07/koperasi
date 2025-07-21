import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatter
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs // Assuming this path is correct
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_event.dart'; // Assuming this path is correct
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_state.dart'; // Assuming this path is correct
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_bloc.dart'; // Assuming this path is correct

class BayarTagihanPage extends StatefulWidget {
  final double tagihanBulanIni;
  final int pinjamanDetailId; // Added to pass the specific loan detail ID
  final String token; // Added to pass the user's authentication token

  const BayarTagihanPage({
    super.key,
    required this.tagihanBulanIni,
    required this.pinjamanDetailId, // Required
    required this.token, // Required
  });

  @override
  State<BayarTagihanPage> createState() => _BayarTagihanPageState();
}

class _BayarTagihanPageState extends State<BayarTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Initialize this if used

  String? _selectedJenisPembayaran;
  final List<String> _jenisPembayaranOptions = ['Manual Transfer', 'Otomatis'];

  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
    'BNI - 1122334455 (Koperasi Bersama)',
  ];

  File? _pickedImageFile; // To store the picked image file

  @override
  void initState() {
    super.initState();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Function to pick image from camera (still kept, but not directly called from main UI for now)
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _pickedImageFile = File(pickedFile.path);
        print(
          'DEBUG: Image picked from CAMERA. Path: ${_pickedImageFile?.path}',
        );
      } else {
        _pickedImageFile = null;
        debugPrint('No image selected from camera.');
        print(
          'DEBUG: No image selected from CAMERA. _pickedImageFile is null.',
        );
      }
    });
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _pickedImageFile = File(pickedFile.path);
        print(
          'DEBUG: Image picked from GALLERY. Path: ${_pickedImageFile?.path}',
        );
      } else {
        _pickedImageFile = null;
        debugPrint('No image selected from gallery.');
        print(
          'DEBUG: No image selected from GALLERY. _pickedImageFile is null.',
        );
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String type = '';
      String? imagePath;

      if (_selectedJenisPembayaran == 'Manual Transfer') {
        type = 'manual';
        imagePath = _pickedImageFile?.path;
        print(
          'DEBUG: Submitting form. Image path for manual transfer: $imagePath',
        );

        if (imagePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Harap unggah bukti transfer untuk pembayaran manual.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else if (_selectedJenisPembayaran == 'Otomatis') {
        type = 'automatic';
        print('DEBUG: Submitting form. Payment type: automatic');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jenis pembayaran tidak valid.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Dispatch the event to the BLoC
      context.read<BayarTagihanBloc>().add(
        CreateBayarTagihanEvent(
          pinjamanDetail: widget.pinjamanDetailId,
          amount: widget.tagihanBulanIni,
          type: type,
          image: imagePath,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field yang wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bayar Tagihan Bulan Ini',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE30031),
      ),
      body: BlocConsumer<BayarTagihanBloc, BayarTagihanState>(
        listener: (context, state) {
          if (state is BayarTagihanCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pembayaran Tagihan berhasil: ${_formatCurrency(state.bayarEntity.amount.toDouble())}',
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            // Redirect to payment link if automatic and link exists
            if (state.bayarEntity.type == 'automatic' &&
                state.bayarEntity.transactionEntity?.paymentLink != null) {
              final Uri url = Uri.parse(
                state.bayarEntity.transactionEntity!.paymentLink!,
              );
              launchUrl(url, mode: LaunchMode.externalApplication).catchError((
                e,
                stackTrace,
              ) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal membuka link pembayaran: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
            Navigator.pop(context, true);
          } else if (state is BayarTagihanCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error pembayaran: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Informasi Tagihan
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE30031).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFFE30031)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tagihan Bulan Ini:',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFE30031),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _formatCurrency(widget.tagihanBulanIni),
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Jenis Pembayaran
                  _buildDropdownFormField(
                    value: _selectedJenisPembayaran,
                    hintText: 'Pilih Jenis Pembayaran',
                    labelText: 'Jenis Pembayaran*',
                    items: _jenisPembayaranOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedJenisPembayaran = value;
                        // Reset related selections if payment type changes
                        _selectedRekeningTujuan = null;
                        _pickedImageFile =
                            null; // Reset image when type changes
                      });
                    },
                    validator: (value) => value == null
                        ? 'Jenis pembayaran tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20.0),

                  // --- Conditional Fields ---
                  if (_selectedJenisPembayaran == 'Manual Transfer') ...[
                    _buildDropdownFormField(
                      value: _selectedRekeningTujuan,
                      hintText: 'Pilih Rekening Tujuan',
                      labelText: 'Rekening Tujuan*',
                      items: _rekeningTujuanOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedRekeningTujuan = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Rekening tujuan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20.0),
                    // Image Picker for Manual Transfer (Gallery Only)
                    InkWell(
                      onTap: _pickImageFromGallery, // Directly opens gallery
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _pickedImageFile != null
                            ? Image.file(
                                _pickedImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .photo_library, // Changed to gallery icon
                                    size: 50,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pilih Bukti Transfer dari Galeri*', // Updated text
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],

                  // If "Otomatis" is selected, no additional dropdowns are shown.
                  // The payment link will be launched after submission.
                  const SizedBox(height: 30.0),

                  // Pay Button
                  ElevatedButton(
                    onPressed: state is BayarTagihanCreating
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30031),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: state is BayarTagihanCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Bayar Sekarang',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget for DropdownButtonFormField
  Widget _buildDropdownFormField({
    required String? value,
    required String hintText,
    required String labelText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 16.0,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  // Helper widget to display information (VA Number / E-Wallet) - This is no longer used for "Otomatis"
  // but kept for completeness if needed elsewhere or in future manual transfer enhancements.
  Widget _buildInfoDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
