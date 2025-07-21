import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk InputFormatter
// import 'package:intl/intl.dart'; // Tidak digunakan di form ini, bisa dihapus jika tidak ada penggunaan lain

class PaketDataFormPage extends StatefulWidget {
  const PaketDataFormPage({super.key});

  @override
  State<PaketDataFormPage> createState() => _PaketDataFormPageState();
}

class _PaketDataFormPageState extends State<PaketDataFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Nomor HP
  final TextEditingController _nomorHpController = TextEditingController();

  // Operator Seluler
  String? _selectedOperator;
  final List<String> _operatorOptions = [
    'Telkomsel',
    'Indosat Ooredoo',
    'XL Axiata',
    'Tri',
    'Smartfren'
  ];

  // Jenis Transaksi
  String? _selectedJenisTransaksi;
  final List<String> _jenisTransaksiOptions = ['Paket', 'Paket Data'];

  // Nominal Paket (conditional)
  String? _selectedNominalPaket;
  final List<String> _nominalPaketOptions = [
    '10.000',
    '20.000',
    '25.000',
    '50.000',
    '100.000',
    '200.000'
  ];
  final Map<String, double> _hargaPaket = { // Placeholder harga
    '10.000': 11500,
    '20.000': 21500,
    '25.000': 26000,
    '50.000': 50500,
    '100.000': 99500,
    '200.000': 199000,
  };

  // Pilihan Paket Data (conditional)
  String? _selectedPaketData;
  // Opsi paket data bisa lebih kompleks, mungkin Map<String, List<String>> per operator
  final List<String> _paketDataOptionsTelkomsel = [ // Contoh untuk Telkomsel
    'OMG! Nonton 3GB - Rp 25.000',
    'Internet Sakti Harian 1GB - Rp 10.000',
    'Combo Sakti Mingguan 5GB + Telp - Rp 35.000',
    'InternetMAX Bulanan 10GB - Rp 75.000',
  ];
   final List<String> _paketDataOptionsIndosat = [
    'Freedom Internet 2GB/7hr - Rp 15.000',
    'Freedom U 5GB+Apps/30hr - Rp 50.000',
  ];
  // ... tambahkan opsi paket data untuk operator lain
  List<String> _currentPaketDataOptions = [];
  final Map<String, double> _hargaPaketData = { // Placeholder harga
    'OMG! Nonton 3GB - Rp 25.000': 25000,
    'Internet Sakti Harian 1GB - Rp 10.000': 10000,
    'Combo Sakti Mingguan 5GB + Telp - Rp 35.000': 35000,
    'InternetMAX Bulanan 10GB - Rp 75.000': 75000,
    'Freedom Internet 2GB/7hr - Rp 15.000': 15000,
    'Freedom U 5GB+Apps/30hr - Rp 50.000': 50000,
  };


  // Metode Pembayaran (opsional, bisa disederhanakan atau dihilangkan jika pembayaran terpusat)
  String? _selectedMetodePembayaran;
  final List<String> _metodePembayaranOptions = ['Saldo Koperasi', 'Transfer Manual'];
  // Jika ingin detail seperti form simpanan:
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
    _nomorHpController.dispose();
    super.dispose();
  }

  void _updatePaketDataOptions(String? operator) {
    setState(() {
      _selectedPaketData = null; // Reset pilihan paket data
      if (operator == 'Telkomsel') {
        _currentPaketDataOptions = _paketDataOptionsTelkomsel;
      } else if (operator == 'Indosat Ooredoo') {
        _currentPaketDataOptions = _paketDataOptionsIndosat;
      }
      // Tambahkan kondisi untuk operator lain
      else {
        _currentPaketDataOptions = [];
      }
    });
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String message = 'Pembelian berhasil diproses!\n';
      message += 'Nomor HP: ${_nomorHpController.text}\n';
      message += 'Operator: $_selectedOperator\n';
      message += 'Jenis Transaksi: $_selectedJenisTransaksi\n';

      double harga = 0;

      if (_selectedJenisTransaksi == 'Paket') {
        message += 'Nominal Paket: $_selectedNominalPaket\n';
        harga = _hargaPaket[_selectedNominalPaket] ?? 0;
      } else if (_selectedJenisTransaksi == 'Paket Data') {
        message += 'Paket Data: $_selectedPaketData\n';
        harga = _hargaPaketData[_selectedPaketData] ?? 0;
      }
      message += 'Harga: Rp ${harga.toStringAsFixed(0)}\n';
      message += 'Metode Pembayaran: $_selectedMetodePembayaran\n';

      if (_selectedMetodePembayaran == 'Transfer Manual') {
        message += 'Rekening Tujuan: $_selectedRekeningTujuan\n';
      }
      // Tambahkan logika untuk metode pembayaran otomatis jika ada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Color(0xFFE30031),
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
        title: const Text('Beli Paket & Paket Data',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFE30031),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nomorHpController,
                labelText: 'Nomor HP*',
                hintText: 'Masukkan nomor HP tujuan',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  if (value.length < 10 || value.length > 15) {
                    return 'Format nomor HP tidak valid';
                  }
                  return null;
                },
              ),

              _buildDropdownFormField(
                value: _selectedOperator,
                hintText: 'Pilih Operator',
                labelText: 'Operator Seluler*',
                icon: Icons.settings_input_antenna_outlined,
                items: _operatorOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedOperator = value;
                    _updatePaketDataOptions(value); // Update opsi paket data berdasarkan operator
                  });
                },
                validator: (value) => value == null ? 'Operator tidak boleh kosong' : null,
              ),

              if (_selectedOperator != null)
                _buildDropdownFormField(
                  value: _selectedPaketData,
                  hintText: 'Pilih Paket Data',
                  labelText: 'Paket Data*',
                  icon: Icons.data_usage_outlined,
                  items: _currentPaketDataOptions, // Gunakan opsi paket data yang sudah difilter
                  onChanged: (value) {
                    setState(() {
                      _selectedPaketData = value;
                    });
                  },
                  validator: (value) => value == null ? 'Paket data tidak boleh kosong' : null,
                ),
              
              if (_selectedJenisTransaksi == 'Paket Data' && _selectedOperator == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Pilih operator terlebih dahulu untuk melihat pilihan paket data.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),



              // Tambahkan logika untuk VA & E-Wallet jika diperlukan di sini

              const SizedBox(height: 30.0),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.shopping_cart_checkout_outlined),
                label: const Text('Beli Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE30031),
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
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.black.withOpacity(0.05),
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
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.black.withOpacity(0.05),
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
