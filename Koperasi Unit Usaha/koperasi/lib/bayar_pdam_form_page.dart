import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk InputFormatter
import 'package:intl/intl.dart'; // Untuk format mata uang

class BayarPdamFormPage extends StatefulWidget { // Diubah dari BayarListrikFormPage
  const BayarPdamFormPage({super.key});

  @override
  State<BayarPdamFormPage> createState() => _BayarPdamFormPageState(); // Diubah
}

class _BayarPdamFormPageState extends State<BayarPdamFormPage> { // Diubah
  final _formKey = GlobalKey<FormState>();

  // Nomor Pelanggan PDAM / IDPEL
  final TextEditingController _nomorPelangganPdamController = TextEditingController();
  // Nama Pelanggan (akan diisi otomatis atau placeholder)
  final TextEditingController _namaPelangganPdamController = TextEditingController(text: 'Budi Santoso (Contoh)'); // Placeholder
  // Total Tagihan (akan diisi otomatis atau placeholder)
  final TextEditingController _totalTagihanPdamController = TextEditingController(text: '85.000'); // Placeholder, tanpa Rp.
  double _tagihanPdamAmount = 85000; // Angka sebenarnya untuk formatting

  // Periode Tagihan (opsional, bisa ditambahkan jika API PDAM menyediakan)
  // String? _selectedPeriodePdam;
  // final List<String> _periodePdamOptions = ['Juni 2024', 'Mei 2024', 'April 2024'];


  // Metode Pembayaran
  String? _selectedMetodePembayaran;
  final List<String> _metodePembayaranOptions = ['Saldo Koperasi', 'Transfer Manual', 'Otomatis'];


  // Opsi untuk Manual Transfer (jika dipilih)
  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
    'BNI - 1122334455 (Koperasi Bersama)'
  ];

  // Opsi untuk Pembayaran Otomatis (jika dipilih)
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
    'BCA Virtual Account': '8808 0000 1111 2222',
    'Mandiri Virtual Account': '8950 0000 1111 2223',
    'BNI Virtual Account': '9880 0000 1111 2224',
    'BRI Virtual Account': '7770 0000 1111 2225'
  };
  String? _displayedVANumber;

  // Opsi untuk E-Wallet
  String? _selectedEwallet;
  final List<String> _ewalletOptions = ['GoPay', 'OVO', 'Dana', 'ShopeePay', 'LinkAja'];
  final Map<String, String> _ewalletNumbers = {
    'GoPay': '0811 2233 4455 (a/n Koperasi PDAM)',
    'OVO': '0899 8877 6655 (Koperasi PDAM Kita)',
    'Dana': '0876 5544 3322 (Koperasi PDAM Maju)',
    'ShopeePay': '0852 1122 3344 (Koperasi PDAM Jaya)',
    'LinkAja': '0823 9988 7766 (Koperasi PDAM Sukses)'
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
    _nomorPelangganPdamController.dispose();
    _namaPelangganPdamController.dispose();
    _totalTagihanPdamController.dispose();
    super.dispose();
  }

  void _cekTagihanPdam() {
    if (_nomorPelangganPdamController.text.isNotEmpty) {
      // Simulasi pengecekan tagihan PDAM
      // Di aplikasi nyata, ini akan memanggil API PDAM
      setState(() {
        // Placeholder data, ganti dengan data dari API
        _namaPelangganPdamController.text = "Budi Santoso (Otomatis)";
        _totalTagihanPdamController.text = "85.000"; // Ini hanya untuk display
        _tagihanPdamAmount = 85000; // Nilai angka sebenarnya
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tagihan PDAM untuk ${_nomorPelangganPdamController.text} ditemukan.'),
          backgroundColor: Colors.cyan.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan Nomor Pelanggan PDAM terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_totalTagihanPdamController.text.isEmpty || _tagihanPdamAmount <= 0) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap cek tagihan PDAM terlebih dahulu.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String message = 'Pembayaran Tagihan PDAM berhasil diproses!\n';
      message += 'Nomor Pelanggan: ${_nomorPelangganPdamController.text}\n';
      message += 'Nama Pelanggan: ${_namaPelangganPdamController.text}\n';
      message += 'Total Tagihan: ${_formatCurrency(_tagihanPdamAmount)}\n';
      message += 'Metode Pembayaran: $_selectedMetodePembayaran\n';

      if (_selectedMetodePembayaran == 'Transfer Manual') {
        message += 'Rekening Tujuan: $_selectedRekeningTujuan\n';
      } else if (_selectedMetodePembayaran == 'Otomatis') {
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
          backgroundColor: Colors.cyan.shade700, // Warna notifikasi disesuaikan
        ),
      );
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
        title: const Text('Bayar Tagihan PDAM'), // Judul diubah
        backgroundColor: Colors.cyan.shade700, // Warna tema diubah
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nomorPelangganPdamController,
                labelText: 'Nomor Pelanggan PDAM / IDPEL*',
                hintText: 'Masukkan Nomor Pelanggan PDAM',
                icon: Icons.water_drop_outlined, // Icon disesuaikan
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Pelanggan PDAM tidak boleh kosong';
                  }
                  // Validasi panjang bisa disesuaikan dengan format IDPEL PDAM
                  if (value.length < 5 || value.length > 16) {
                    return 'Format Nomor Pelanggan PDAM tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _cekTagihanPdam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('Cek Tagihan PDAM', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20.0),

              _buildReadOnlyField(
                controller: _namaPelangganPdamController,
                labelText: 'Nama Pelanggan',
                icon: Icons.person_pin_circle_outlined,
              ),

              _buildReadOnlyField(
                controller: _totalTagihanPdamController,
                labelText: 'Total Tagihan PDAM (Rp)',
                icon: Icons.receipt_long_outlined,
                prefixText: 'Rp ',
              ),

              const SizedBox(height: 20.0),
              _buildDropdownFormField(
                value: _selectedMetodePembayaran,
                hintText: 'Pilih Metode Pembayaran',
                labelText: 'Metode Pembayaran*',
                icon: Icons.payment_outlined,
                items: _metodePembayaranOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedMetodePembayaran = value;
                    _selectedRekeningTujuan = null;
                    _selectedMetodeOtomatis = null;
                    _selectedBankVA = null;
                    _displayedVANumber = null;
                    _selectedEwallet = null;
                    _displayedEwalletNumber = null;
                  });
                },
                validator: (value) => value == null ? 'Metode pembayaran tidak boleh kosong' : null,
              ),

              if (_selectedMetodePembayaran == 'Transfer Manual')
                _buildDropdownFormField(
                  value: _selectedRekeningTujuan,
                  hintText: 'Pilih Rekening Tujuan',
                  labelText: 'Rekening Tujuan (Manual)*',
                  icon: Icons.account_balance_outlined,
                  items: _rekeningTujuanOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedRekeningTujuan = value;
                    });
                  },
                  validator: (value) => value == null ? 'Rekening tujuan tidak boleh kosong' : null,
                ),
              
              if (_selectedMetodePembayaran == 'Otomatis') ...[
                const SizedBox(height: 20.0),
                _buildDropdownFormField(
                  value: _selectedMetodeOtomatis,
                  hintText: 'Pilih Metode Pembayaran Otomatis',
                  labelText: 'Metode Otomatis*',
                  icon: Icons.settings_applications_outlined,
                  items: _metodeOtomatisOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedMetodeOtomatis = value;
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
                    icon: Icons.account_balance_wallet_outlined,
                    items: _bankVAOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedBankVA = value;
                        _displayedVANumber = _bankVANumbers[value];
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
                    icon: Icons.account_balance_wallet_outlined,
                    items: _ewalletOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedEwallet = value;
                        _displayedEwalletNumber = _ewalletNumbers[value];
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
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.water_damage_outlined), // Icon disesuaikan
                label: const Text('Bayar Tagihan PDAM'), // Label tombol diubah
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600, // Warna tombol diubah
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.cyan.shade700), // Warna ikon disesuaikan
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.cyan.withOpacity(0.05), // Warna isian disesuaikan
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

   Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          prefixText: prefixText,
          prefixIcon: Icon(icon, color: Colors.cyan.shade700), // Warna ikon disesuaikan
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }


  Widget _buildDropdownFormField({
    required String? value,
    required String hintText,
    required String labelText,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.cyan.shade700), // Warna ikon disesuaikan
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.cyan.withOpacity(0.05), // Warna isian disesuaikan
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
      ),
    );
  }

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
