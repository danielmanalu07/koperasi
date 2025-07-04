import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatter
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:koperasi/core/errors/map_failure_toMessage.dart'; // Assuming this path is correct
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/create_bayar_tagihan_usecase.dart'; // Assuming this path is correct
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
  final ImagePicker _picker = ImagePicker();
  String? _sessionToken;
  late LocalDatasource _localDatasource; // Initialize this if used

  String? _selectedJenisPembayaran;
  final List<String> _jenisPembayaranOptions = ['Manual Transfer', 'Otomatis'];

  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
    'BNI - 1122334455 (Koperasi Bersama)',
  ];

  File? _pickedImageFile; // To store the picked image file

  String? _selectedMetodeOtomatis;
  final List<String> _metodeOotomatisOptions = [
    'Virtual Account Bank',
    'E-Wallet',
  ];

  String? _selectedBankVA;
  final List<String> _bankVAOptions = [
    'BCA Virtual Account',
    'Mandiri Virtual Account',
    'BNI Virtual Account',
    'BRI Virtual Account',
  ];
  final Map<String, String> _bankVANumbers = {
    'BCA Virtual Account': '8808 1234 5678 9012',
    'Mandiri Virtual Account': '8950 8123 4567 8901',
    'BNI Virtual Account': '9880 8123 4567 8902',
    'BRI Virtual Account': '7770 8123 4567 8903',
  };
  String? _displayedVANumber;

  String? _selectedEwallet;
  final List<String> _ewalletOptions = [
    'GoPay',
    'OVO',
    'Dana',
    'ShopeePay',
    'LinkAja',
  ];
  final Map<String, String> _ewalletNumbers = {
    'GoPay': '0812 3456 7890 (a/n Koperasi)',
    'OVO': '0898 7654 3210 (Koperasi Kita)',
    'Dana': '0877 1122 3344 (Koperasi Maju)',
    'ShopeePay': '0855 9988 7766 (Koperasi Jaya)',
    'LinkAja': '0821 5544 3322 (Koperasi Sukses)',
  };
  String? _displayedEwalletNumber;

  @override
  void initState() {
    super.initState();
    // Initialize _localDatasource if it's used elsewhere for token.
    // Future.microtask(() async {
    //   _localDatasource = LocalDatasource(await SharedPreferences.getInstance());
    //   _sessionToken = await _localDatasource.getToken();
    // });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // --- REMOVED: _showImageSourceActionSheet as per previous request ---

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
                  'Pembayaran Tagihan berhasil: ${state.bayarEntity.amount}',
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
                        _selectedMetodeOtomatis = null;
                        _selectedBankVA = null;
                        _displayedVANumber = null;
                        _selectedEwallet = null;
                        _displayedEwalletNumber = null;
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

                  if (_selectedJenisPembayaran == 'Otomatis') ...[
                    _buildDropdownFormField(
                      value: _selectedMetodeOtomatis,
                      hintText: 'Pilih Metode Pembayaran Otomatis',
                      labelText: 'Metode Otomatis*',
                      items: _metodeOotomatisOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedMetodeOtomatis = value;
                          // Reset related selections if automatic method changes
                          _selectedBankVA = null;
                          _displayedVANumber = null;
                          _selectedEwallet = null;
                          _displayedEwalletNumber = null;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Metode otomatis tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20.0),
                    if (_selectedMetodeOtomatis == 'Virtual Account Bank') ...[
                      _buildDropdownFormField(
                        value: _selectedBankVA,
                        hintText: 'Pilih Bank Virtual Account',
                        labelText: 'Bank VA*',
                        items: _bankVAOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedBankVA = value;
                            _displayedVANumber =
                                _bankVANumbers[value]; // Display VA number
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Bank VA tidak boleh kosong' : null,
                      ),
                      if (_displayedVANumber != null) ...[
                        const SizedBox(height: 10.0),
                        _buildInfoDisplay(
                          'Nomor Virtual Account:',
                          _displayedVANumber!,
                        ),
                      ],
                    ],
                    if (_selectedMetodeOtomatis == 'E-Wallet') ...[
                      _buildDropdownFormField(
                        value: _selectedEwallet,
                        hintText: 'Pilih E-Wallet',
                        labelText: 'E-Wallet*',
                        items: _ewalletOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedEwallet = value;
                            _displayedEwalletNumber =
                                _ewalletNumbers[value]; // Display E-Wallet number
                          });
                        },
                        validator: (value) => value == null
                            ? 'E-Wallet tidak boleh kosong'
                            : null,
                      ),
                      if (_displayedEwalletNumber != null) ...[
                        const SizedBox(height: 10.0),
                        _buildInfoDisplay(
                          'Nomor E-Wallet Tujuan:',
                          _displayedEwalletNumber!,
                        ),
                      ],
                    ],
                  ],
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

  // Helper widget to display information (VA Number / E-Wallet)
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
