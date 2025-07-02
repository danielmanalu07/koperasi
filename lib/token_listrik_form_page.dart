import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk InputFormatter
// import 'package:intl/intl.dart'; // Tidak digunakan di form ini, bisa dihapus jika tidak ada penggunaan lain

class TokenListrikFormPage extends StatefulWidget { // Diubah dari PulsaDataFormPage
  const TokenListrikFormPage({super.key});

  @override
  State<TokenListrikFormPage> createState() => _TokenListrikFormPageState(); // Diubah
}

class _TokenListrikFormPageState extends State<TokenListrikFormPage> { // Diubah
  final _formKey = GlobalKey<FormState>();

  // Nomor Meter/ID Pelanggan
  final TextEditingController _nomorMeterController = TextEditingController();

  // Nominal Token
  String? _selectedNominalToken;
  final List<String> _nominalTokenOptions = [ // Opsi nominal token
    '20.000',
    '50.000',
    '100.000',
    '200.000',
    '500.000',
    '1.000.000'
  ];
  final Map<String, double> _hargaToken = { // Placeholder harga token (termasuk admin)
    '20.000': 22500,
    '50.000': 52500,
    '100.000': 102500,
    '200.000': 202500,
    '500.000': 502500,
    '1.000.000': 1002500,
  };

  // Metode Pembayaran
  String? _selectedMetodePembayaran;
  final List<String> _metodePembayaranOptions = ['Saldo Koperasi', 'Transfer Manual'];
  // Jika ingin detail seperti form simpanan/tabungan:
  // final List<String> _metodePembayaranOptions = ['Saldo Koperasi', 'Manual Transfer', 'Otomatis'];


  // Opsi untuk Manual Transfer (jika dipilih)
  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
  ];

  // (Opsi VA & E-Wallet bisa ditambahkan jika _metodePembayaranOptions diperluas)


  @override
  void dispose() {
    _nomorMeterController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String message = 'Pembelian Token Listrik berhasil diproses!\n';
      message += 'Nomor Meter/ID Pel: ${_nomorMeterController.text}\n';
      message += 'Nominal Token: Rp $_selectedNominalToken\n';

      double harga = _hargaToken[_selectedNominalToken] ?? 0;
      message += 'Total Bayar: Rp ${harga.toStringAsFixed(0)}\n';
      message += 'Metode Pembayaran: $_selectedMetodePembayaran\n';

      if (_selectedMetodePembayaran == 'Transfer Manual') {
        message += 'Rekening Tujuan: $_selectedRekeningTujuan\n';
      }
      // Tambahkan logika untuk metode pembayaran otomatis jika ada

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.blue.shade700, // Warna notifikasi disesuaikan
        ),
      );
      // Navigator.pop(context); // Kembali ke halaman sebelumnya atau reset form
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
        title: const Text('Beli Token Listrik',
          style: TextStyle(color: Colors.white)
        ), // Judul diubah
        backgroundColor: Color(0xFFE30031), // Warna tema diubah
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nomorMeterController,
                labelText: 'Nomor Meter / ID Pelanggan*',
                hintText: 'Masukkan Nomor Meter atau ID Pelanggan',
                icon: Icons.electrical_services_outlined, // Icon disesuaikan
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Meter/ID Pelanggan tidak boleh kosong';
                  }
                  if (value.length < 10 || value.length > 16) { // Contoh validasi panjang
                    return 'Format Nomor Meter/ID Pelanggan tidak valid';
                  }
                  return null;
                },
              ),

              _buildDropdownFormField(
                value: _selectedNominalToken,
                hintText: 'Pilih Nominal Token',
                labelText: 'Nominal Token*',
                icon: Icons.flash_on_outlined, // Icon disesuaikan
                items: _nominalTokenOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedNominalToken = value;
                  });
                },
                validator: (value) => value == null ? 'Nominal token tidak boleh kosong' : null,
              ),

              // const SizedBox(height: 20.0),
              // _buildDropdownFormField(
              //   value: _selectedMetodePembayaran,
              //   hintText: 'Pilih Metode Pembayaran',
              //   labelText: 'Metode Pembayaran*',
              //   icon: Icons.payment_outlined,
              //   items: _metodePembayaranOptions,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedMetodePembayaran = value;
              //       _selectedRekeningTujuan = null; // Reset jika metode berubah
              //     });
              //   },
              //   validator: (value) => value == null ? 'Metode pembayaran tidak boleh kosong' : null,
              // ),

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

              // Tambahkan logika untuk VA & E-Wallet jika diperlukan di sini (jika _metodePembayaranOptions diperluas)

              const SizedBox(height: 30.0),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.offline_bolt_outlined), // Icon disesuaikan
                label: const Text('Beli Token'), // Label tombol diubah
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE30031), // Warna tombol diubah
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
          prefixIcon: Icon(icon, color: Colors.black), // Warna ikon disesuaikan
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.black.withOpacity(0.05), // Warna isian disesuaikan
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
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
          prefixIcon: Icon(icon, color: Colors.black), // Warna ikon disesuaikan
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.black.withOpacity(0.05), // Warna isian disesuaikan
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
}
