import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk InputFormatter
import 'package:intl/intl.dart'; // Untuk format mata uang (opsional, tapi baik untuk tagihan)

class BayarListrikFormPage extends StatefulWidget { // Diubah dari TokenListrikFormPage
  const BayarListrikFormPage({super.key});

  @override
  State<BayarListrikFormPage> createState() => _BayarListrikFormPageState(); // Diubah
}

class _BayarListrikFormPageState extends State<BayarListrikFormPage> { // Diubah
  final _formKey = GlobalKey<FormState>();

  // Nomor Meter/ID Pelanggan
  final TextEditingController _nomorMeterController = TextEditingController();
  // Nama Pelanggan (akan diisi otomatis atau placeholder)
  final TextEditingController _namaPelangganController = TextEditingController(text: 'Soni Setiawan (Contoh)'); // Placeholder
  // Total Tagihan (akan diisi otomatis atau placeholder)
  final TextEditingController _totalTagihanController = TextEditingController(text: '175.500'); // Placeholder, tanpa Rp.
  final double _tagihanAmount = 175500; // Angka sebenarnya untuk formatting

  // Periode Tagihan (opsional, bisa ditambahkan)
  // String? _selectedPeriode;
  // final List<String> _periodeOptions = ['Juni 2024', 'Mei 2024', 'April 2024'];


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
    _nomorMeterController.dispose();
    _namaPelangganController.dispose();
    _totalTagihanController.dispose();
    super.dispose();
  }

  void _cekTagihan() {
    if (_nomorMeterController.text.isNotEmpty) {
      // Simulasi pengecekan tagihan
      // Di aplikasi nyata, ini akan memanggil API
      setState(() {
        // Placeholder data, ganti dengan data dari API
        _namaPelangganController.text = "Soni Setiawan (Otomatis)";
        _totalTagihanController.text = "175.500"; // Ini hanya untuk display
        // _tagihanAmount = 175500; // Nilai angka sebenarnya
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tagihan untuk ${_nomorMeterController.text} ditemukan.'),
          backgroundColor: Color(0xFFE30031),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan Nomor Meter / ID Pelanggan terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_totalTagihanController.text.isEmpty || _tagihanAmount <= 0) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap cek tagihan terlebih dahulu.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String message = 'Pembayaran Tagihan Listrik berhasil diproses!\n';
      message += 'Nomor Meter/ID Pel: ${_nomorMeterController.text}\n';
      message += 'Nama Pelanggan: ${_namaPelangganController.text}\n';
      message += 'Total Tagihan: ${_formatCurrency(_tagihanAmount)}\n';
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
        title: const Text('Bayar Tagihan Listrik',
          style: TextStyle(
            color: Colors.white,
          ),
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
                icon: Icons.electrical_services_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Meter/ID Pelanggan tidak boleh kosong';
                  }
                  if (value.length < 10 || value.length > 16) {
                    return 'Format Nomor Meter/ID Pelanggan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _cekTagihan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('Cek Tagihan', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20.0),

              _buildReadOnlyField(
                controller: _namaPelangganController,
                labelText: 'Nama Pelanggan',
                icon: Icons.person_pin_circle_outlined,
              ),

              _buildReadOnlyField(
                controller: _totalTagihanController,
                labelText: 'Total Tagihan (Rp)',
                icon: Icons.receipt_long_outlined,
                prefixText: 'Rp ',
              ),

              // Dropdown untuk Periode Tagihan (Opsional)
              // _buildDropdownFormField(
              //   value: _selectedPeriode,
              //   hintText: 'Pilih Periode Tagihan',
              //   labelText: 'Periode Tagihan*',
              //   icon: Icons.calendar_month_outlined,
              //   items: _periodeOptions,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedPeriode = value;
              //     });
              //   },
              //   validator: (value) => value == null ? 'Periode tagihan tidak boleh kosong' : null,
              // ),


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
              //       _selectedRekeningTujuan = null;
              //       _selectedMetodeOtomatis = null;
              //       _selectedBankVA = null;
              //       _displayedVANumber = null;
              //       _selectedEwallet = null;
              //       _displayedEwalletNumber = null;
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
              
              if (_selectedMetodePembayaran == 'Otomatis') ...[
                const SizedBox(height: 20.0), // Tambahkan jarak sebelum dropdown metode otomatis
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
                    icon: Icons.account_balance_wallet_outlined, // Bisa ganti ikon
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
                icon: const Icon(Icons.receipt_long_outlined), // Icon disesuaikan
                label: const Text('Bayar Tagihan'), // Label tombol diubah
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
          prefixIcon: Icon(icon, color: Colors.lightBlue.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.lightBlue.withOpacity(0.05),
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
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.grey.shade200, // Warna berbeda untuk field read-only
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
          prefixIcon: Icon(icon, color: Colors.lightBlue.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.lightBlue.withOpacity(0.05),
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
