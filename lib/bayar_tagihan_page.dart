import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk InputFormatter
import 'package:intl/intl.dart'; // Untuk format mata uang

class BayarTagihanPage extends StatefulWidget { // Diubah dari SimpananFormPage
  final double tagihanBulanIni; // Tambahkan parameter untuk tagihan

  const BayarTagihanPage({
    super.key,
    this.tagihanBulanIni = 1500000, // Default value jika tidak di-pass
  });

  @override
  State<BayarTagihanPage> createState() => _BayarTagihanPageState(); // Diubah
}

class _BayarTagihanPageState extends State<BayarTagihanPage> { // Diubah
  final _formKey = GlobalKey<FormState>();

  // Nominal (sekarang hanya untuk display, diambil dari widget.tagihanBulanIni)
  // final TextEditingController _nominalController = TextEditingController(); // Tidak lagi diinput

  // Jenis Pembayaran
  String? _selectedJenisPembayaran;
  final List<String> _jenisPembayaranOptions = ['Manual Transfer', 'Otomatis'];

  // Opsi untuk Manual Transfer
  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
    'BNI - 1122334455 (Koperasi Bersama)'
  ];

  // Opsi untuk Pembayaran Otomatis
  String? _selectedMetodeOtomatis;
  final List<String> _metodeOtomatisOptions = ['Virtual Account Bank', 'E-Wallet'];

  // Opsi untuk Virtual Account Bank
  String? _selectedBankVA;
  final List<String> _bankVAOptions = [
    'BCA Virtual Account',
    'Mandiri Virtual Account',
    'BNI Virtual Account',
    'BRI Virtual Account'
  ];
  final Map<String, String> _bankVANumbers = {
    'BCA Virtual Account': '8808 1234 5678 9012',
    'Mandiri Virtual Account': '8950 8123 4567 8901',
    'BNI Virtual Account': '9880 8123 4567 8902',
    'BRI Virtual Account': '7770 8123 4567 8903'
  };
  String? _displayedVANumber;

  // Opsi untuk E-Wallet
  String? _selectedEwallet;
  final List<String> _ewalletOptions = ['GoPay', 'OVO', 'Dana', 'ShopeePay', 'LinkAja'];
  final Map<String, String> _ewalletNumbers = {
    'GoPay': '0812 3456 7890 (a/n Koperasi)',
    'OVO': '0898 7654 3210 (Koperasi Kita)',
    'Dana': '0877 1122 3344 (Koperasi Maju)',
    'ShopeePay': '0855 9988 7766 (Koperasi Jaya)',
    'LinkAja': '0821 5544 3322 (Koperasi Sukses)'
  };
  String? _displayedEwalletNumber;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }


  @override
  void dispose() {
    // _nominalController.dispose(); // Tidak lagi digunakan
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Proses data form di sini
      String message = 'Pembayaran Tagihan berhasil diproses!\n';
      message += 'Nominal Tagihan: ${_formatCurrency(widget.tagihanBulanIni)}\n';
      message += 'Jenis Pembayaran: $_selectedJenisPembayaran\n';

      if (_selectedJenisPembayaran == 'Manual Transfer') {
        message += 'Rekening Tujuan: $_selectedRekeningTujuan\n';
      } else if (_selectedJenisPembayaran == 'Otomatis') {
        message += 'Metode Otomatis: $_selectedMetodeOtomatis\n';
        if (_selectedMetodeOtomatis == 'Virtual Account Bank') {
          message += 'Bank VA: $_selectedBankVA\n';
          message += 'Nomor VA: $_displayedVANumber\n';
        } else if (_selectedMetodeOtomatis == 'E-Wallet') {
          message += 'E-Wallet: $_selectedEwallet\n';
          message += 'Nomor E-Wallet: $_displayedEwalletNumber\n';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.teal.shade700, // Warna disesuaikan
        ),
      );
      // Anda bisa menambahkan navigasi kembali atau reset form di sini
      // Navigator.pop(context);
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
        title: const Text('Bayar Tagihan Bulan Ini',
          style: TextStyle(
            color: Colors.white
          )
        ), // Diubah
        backgroundColor: Color(0xFFE30031), // Warna tema disesuaikan
      ),
      body: SingleChildScrollView(
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
                  color: Color(0xFFE30031).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Color(0xFFE30031))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tagihan Bulan Ini:',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFFE30031),
                        fontWeight: FontWeight.w500
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
                    // Reset pilihan terkait jika jenis pembayaran berubah
                    _selectedRekeningTujuan = null;
                    _selectedMetodeOtomatis = null;
                    _selectedBankVA = null;
                    _displayedVANumber = null;
                    _selectedEwallet = null;
                    _displayedEwalletNumber = null;
                  });
                },
                validator: (value) => value == null ? 'Jenis pembayaran tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20.0),

              // --- Conditional Fields ---
              if (_selectedJenisPembayaran == 'Manual Transfer')
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
                  validator: (value) => value == null ? 'Rekening tujuan tidak boleh kosong' : null,
                ),

              if (_selectedJenisPembayaran == 'Otomatis') ...[
                _buildDropdownFormField(
                  value: _selectedMetodeOtomatis,
                  hintText: 'Pilih Metode Pembayaran Otomatis',
                  labelText: 'Metode Otomatis*',
                  items: _metodeOtomatisOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedMetodeOtomatis = value;
                      // Reset pilihan terkait jika metode otomatis berubah
                      _selectedBankVA = null;
                      _displayedVANumber = null;
                      _selectedEwallet = null;
                      _displayedEwalletNumber = null;
                    });
                  },
                  validator: (value) => value == null ? 'Metode otomatis tidak boleh kosong' : null,
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
                        _displayedVANumber = _bankVANumbers[value]; // Tampilkan nomor VA
                      });
                    },
                    validator: (value) => value == null ? 'Bank VA tidak boleh kosong' : null,
                  ),
                  if (_displayedVANumber != null) ...[
                    const SizedBox(height: 10.0),
                    _buildInfoDisplay('Nomor Virtual Account:', _displayedVANumber!),
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
                        _displayedEwalletNumber = _ewalletNumbers[value]; // Tampilkan nomor E-Wallet
                      });
                    },
                    validator: (value) => value == null ? 'E-Wallet tidak boleh kosong' : null,
                  ),
                  if (_displayedEwalletNumber != null) ...[
                    const SizedBox(height: 10.0),
                    _buildInfoDisplay('Nomor E-Wallet Tujuan:', _displayedEwalletNumber!),
                  ],
                ],
              ],
              const SizedBox(height: 30.0),

              // Tombol Bayar
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE30031), // Warna disesuaikan
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                  )
                ),
                child: const Text('Bayar Sekarang',
                style: TextStyle(
                  color: Colors.white
                )), // Diubah
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk DropdownButtonFormField
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  // Helper widget untuk menampilkan informasi (Nomor VA / E-Wallet)
  Widget _buildInfoDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0
              ),
            ),
          ),
        ],
      ),
    );
  }
}
