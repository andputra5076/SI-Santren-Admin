import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:sipinter_admin/datapendaftaran.dart';
import 'package:sipinter_admin/kelas.dart';
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/sekolah.dart';
import 'package:sipinter_admin/tahun_akademik.dart';
import 'package:sipinter_admin/operator.dart';
import 'package:sipinter_admin/guru.dart';
import 'package:sipinter_admin/home.dart';
import 'package:sipinter_admin/murid.dart';
import 'package:sipinter_admin/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters
import 'package:http/http.dart' as http;

class PageOperator extends StatefulWidget {
  @override
  _PageOperatorState createState() => _PageOperatorState();
}

class _PageOperatorState extends State<PageOperator> {
  late String _currentDateTime;
  bool _isDrawerOpen = false;
  String _searchQuery = '';
  int _currentPage = 1;
  String _fullName = '';
  String _email = '';
  final int _rowsPerPage = 10;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _loadUserData();
    _fetchData();
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateFormat('dd MMM yyyy').format(DateTime.now());
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? 'Unknown User';
      _email = prefs.getString('email') ?? 'No Email';
    });
  }

  Future<void> _addOperator(Map<String, String> newOperator) async {
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/tambah-operator'),
      body: newOperator,
    );

    if (response.statusCode == 200) {
      // Assuming the status code for a successful post is 200 instead of 201
      _fetchData();
    } else {
      // Handle error
      print('Failed to add operator');
    }
  }

  // Edit Operator
  Future<void> _editOperator(
      int id, Map<String, dynamic> updatedOperator) async {
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/edit-operator'),
      body: {
        'id': id.toString(),
        ...updatedOperator.map((key, value) => MapEntry(key, value.toString())),
      },
    );

    if (response.statusCode == 200) {
      _fetchData(); // Refresh data
    } else {
      // Handle error
      print('Failed to edit operator. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _deleteOperator(int id) async { // Change to 'Future<void> _deleteSchool(int id) async' for schools
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/hapus-operator'), // Change to 'api/hapus-sekolah' for schools
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      print(response.body);
      _fetchData();
    } else {
      // Handle error
      print('Failed to delete school');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOperators() async {
    final response = await http
        .get(Uri.parse('http://localhost/pesantren_api/api/get-sekolah'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load operators');
    }
  }

  Future<void> _fetchData() async {
    final response = await http
        .get(Uri.parse('http://localhost/pesantren_api/api/get-operator'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _data = jsonData
            .map((item) => {
                  'id': item['id'],
                  'no': _data.length + 1,
                  'fullname': item['fullname'],
                  'username': item['username'],
                  'password': item['password'],
                  'phone_number': item['phone_number'],
                  'email': item['email'],
                  'address': item['address'],
                  'nama_sekolah': item['nama_sekolah'],
                  'npsn': item['npsn'],
                })
            .toList();
      });
    } else {
      // Handle error response
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    final bool isMobile = !isDesktop;
    final double? contentWidth =
        isMobile ? MediaQuery.of(context).size.width - 32 : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('SILENTDRA ASSESSTMEN - ADMIN PANEL'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width - 80 : 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentDateTime,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: _logout,
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        leading: isMobile
            ? IconButton(
                icon: Icon(
                  _isDrawerOpen ? Icons.close : Icons.menu,
                ),
                onPressed: () {
                  setState(() {
                    _isDrawerOpen = !_isDrawerOpen;
                  });
                },
              )
            : null,
      ),
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Stack(
        children: [
          if (isDesktop)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.zero,
                      ),
                      child: _buildDrawer(context),
                    ),
                  ],
                ),
              ),
            ),
          if (isDesktop)
            Positioned(
              left: 250,
              top: 0,
              right: 0,
              child: Container(
                color: Colors.blue[100],
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: MarqueeText(
                  text:
                      'Selamat Datang di Halaman Data Operator - Silentdra Assesstment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          if (isMobile)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                color: Colors.blue[100],
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: MarqueeText(
                    text:
                        'Selamat Datang di Halaman Data Operator - Silentdra Assesstment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: isDesktop ? 250 : 0,
            top: 50,
            right: 0,
            bottom: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _currentPage = 1;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Operator',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  16.0), // Space between search field and button
                          Container(
                            height:
                                47, // Adjust the height to match the search field
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.green, // Set the text color to white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      4), // Match the shape
                                ),
                              ),
                              onPressed: () {
                                _showAddModal(); // Call the function to show the Add modal
                              },
                              child: Center(
                                child: Text(
                                  'Tambah',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth:
                                      contentWidth ?? constraints.maxWidth - 32,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // DataTable section
                                    SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: contentWidth ??
                                              constraints.maxWidth - 32,
                                        ),
                                        child: DataTable(
                                          columnSpacing: 12.0,
                                          headingRowColor:
                                              MaterialStateColor.resolveWith(
                                            (states) => Colors.blue!,
                                          ),
                                          columns: [
                                            DataColumn(label: Text('No')),
                                            DataColumn(
                                                label: Text('Nama Lengkap')),
                                            DataColumn(label: Text('Username')),
                                            DataColumn(label: Text('Password')),
                                            DataColumn(label: Text('Telp')),
                                            DataColumn(label: Text('Email')),
                                            DataColumn(label: Text('Alamat')),
                                            DataColumn(label: Text('Sekolah')),
                                            DataColumn(label: Text('Aksi')),
                                          ],
                                          rows: _buildDataRows(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            16.0), // Add space between DataTable and pagination
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Page $_currentPage'),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: _currentPage > 1
                                                ? () {
                                                    setState(() {
                                                      _currentPage--;
                                                    });
                                                  }
                                                : null,
                                            child: Text('Previous'),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed:
                                                _currentPage * _rowsPerPage <
                                                        _data.length
                                                    ? () {
                                                        setState(() {
                                                          _currentPage++;
                                                        });
                                                      }
                                                    : null,
                                            child: Text('Next'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      color: Colors.grey[300],
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '© 2024 PT. Ronstudio Digital Group. All Rights Reserved.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (isMobile && _isDrawerOpen)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                child: _buildDrawer(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    String? initialValue,
    String? value,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          suffixIcon: obscureText
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility, // Call toggle visibility
                )
              : null,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        inputFormatters: inputFormatters,
        obscureText: obscureText, // Apply the obscureText parameter
      ),
    );
  }

// Show Add Operator Modal
  void _showAddModal() {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String fullname = '';
        String username = '';
        String password = '';
        String email = '';
        String phoneNumber = '';
        String address = '';
        int? idSekolah; // ID Sekolah
        List<Map<String, dynamic>> operators = [];
        bool _obscurePassword = true; // State for password visibility

        void _togglePasswordVisibility() {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchOperators(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No operators available'));
            }

            operators = snapshot.data!;

            return AlertDialog(
              title: Text(
                'Tambah Operator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          label: 'Nama Lengkap',
                          onChanged: (value) => fullname = value,
                          validator: (value) => value!.isEmpty
                              ? 'Full Name tidak boleh kosong'
                              : null,
                        ),
                        _buildTextField(
                          label: 'Username',
                          onChanged: (value) => username = value,
                          validator: (value) => value!.isEmpty
                              ? 'Username tidak boleh kosong'
                              : null,
                        ),
                        _buildTextField(
                          label: 'Password',
                          obscureText: _obscurePassword,
                          onChanged: (value) => password = value,
                          toggleVisibility: _togglePasswordVisibility,
                          validator: (value) => value!.isEmpty
                              ? 'Password tidak boleh kosong'
                              : null,
                        ),
                        _buildTextField(
                          label: 'Email',
                          onChanged: (value) => email = value,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty
                              ? 'Email tidak boleh kosong'
                              : null,
                        ),
                        _buildTextField(
                          label: 'Telp',
                          onChanged: (value) => phoneNumber = value,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) =>
                              value!.isEmpty ? 'Telp tidak boleh kosong' : null,
                        ),
                        _buildTextField(
                          label: 'Alamat',
                          onChanged: (value) => address = value,
                          validator: (value) => value!.isEmpty
                              ? 'Alamat tidak boleh kosong'
                              : null,
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Sekolah',
                            labelStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                          value: idSekolah,
                          onChanged: (value) =>
                              setState(() => idSekolah = value),
                          items: operators.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text(
                                '${school['npsn']} - ${school['nama_sekolah']}',
                                style: TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          validator: (value) =>
                              value == null ? 'Tolong pilih sekolah' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kembali',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addOperator({
                        'fullname': fullname,
                        'username': username,
                        'password': password,
                        'email': email,
                        'phone_number': phoneNumber,
                        'address': address,
                        'id_sekolah':
                            idSekolah.toString(), // Mengirim idSekolah
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Tambah',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditModal(Map<String, dynamic> operator) {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String fullname = operator['fullname'] ?? '';
        String username = operator['username'] ?? '';
        String password = operator['password'] ?? '';
        String email = operator['email'] ?? '';
        String phoneNumber = operator['phone_number'] ?? '';
        String address = operator['address'] ?? '';
        int? idSekolah = operator['id_sekolah']; // ID of selected school
        List<Map<String, dynamic>> operators = [];
        bool _obscurePassword = true; // State for password visibility

        // Toggle password visibility
        void _togglePasswordVisibility() {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchOperators(), // Fetch school data for dropdown
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No operators available'));
            }

            operators = snapshot.data!;

            return AlertDialog(
              title: Text(
                'Edit Operator',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          label: 'Nama Lengkap',
                          initialValue: fullname,
                          onChanged: (value) => fullname = value,
                        ),
                        _buildTextField(
                          label: 'Username',
                          initialValue: username,
                          onChanged: (value) => username = value,
                        ),
                        _buildTextField(
                          label: 'Password',
                          initialValue: password,
                          obscureText: _obscurePassword,
                          onChanged: (value) => password = value,
                          toggleVisibility: _togglePasswordVisibility,
                        ),
                        _buildTextField(
                          label: 'Email',
                          initialValue: email,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => email = value,
                        ),
                        _buildTextField(
                          label: 'Telp',
                          initialValue: phoneNumber,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) => phoneNumber = value,
                        ),
                        _buildTextField(
                          label: 'Alamat',
                          initialValue: address,
                          onChanged: (value) => address = value,
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Sekolah',
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.0),
                            ),
                          ),
                          value:
                              idSekolah, // Ensure this holds the pre-selected school ID
                          onChanged: (value) =>
                              setState(() => idSekolah = value),
                          items: operators.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text(
                                '${school['npsn']} - ${school['nama_sekolah']}',
                                style: TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          validator: (value) =>
                              value == null ? 'Tolong pilih sekolah' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Kembali', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _editOperator(operator['id'], {
                        'fullname': fullname,
                        'username': username,
                        'password': password,
                        'email': email,
                        'phone_number': phoneNumber,
                        'address': address,
                        'id_sekolah': idSekolah,
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show Delete Confirmation Modal
  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Operator',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus operator ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                    color: Colors.grey), // Consistent style with other modals
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteOperator(id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red background for delete action
              ),
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DataRow> _buildDataRows() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;

    // Sort _data based on the 'id' column in descending order
    final sortedData = List<Map<String, dynamic>>.from(_data);
    sortedData.sort((a, b) {
      final idA = a['id'] as int? ?? 0;
      final idB = b['id'] as int? ?? 0;
      return idB.compareTo(idA); // Descending order to get latest data first
    });

    // Filter the data based on the search query
    final filteredData = sortedData.where((row) {
      final searchQueryLower = _searchQuery.toLowerCase();
      return row['fullname']
              .toString()
              .toLowerCase()
              .contains(searchQueryLower) ||
          row['username'].toString().toLowerCase().contains(searchQueryLower) ||
          row['address'].toString().toLowerCase().contains(searchQueryLower) ||
          row['nama_sekolah']
              .toString()
              .toLowerCase()
              .contains(searchQueryLower);
    }).toList();

    // Paginate the filtered data
    final visibleData =
        filteredData.skip(startIndex).take(_rowsPerPage).toList();

    return visibleData.asMap().entries.map<DataRow>((entry) {
      final index = entry.key;
      final row = entry.value;
      return DataRow(cells: [
        DataCell(
            Text((startIndex + index + 1).toString())), // Sequential number
        DataCell(Text(row['fullname'] ?? '')),
        DataCell(Text(row['username'] ?? '')),
        DataCell(Text(row['password'] ?? '')),
        DataCell(Text(row['phone_number'] ?? '')),
        DataCell(Text(row['email'] ?? '')),
        DataCell(Text(row['address'] ?? '')),
        DataCell(Text('${row['nama_sekolah'] ?? ''}')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditModal(row),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(row['id']),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showProfileDialog(context);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/image/profile.png'),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _fullName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  _email,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                    Icons.dashboard, 'Dashboard', false, MyHome()),
                _buildSidebarItem(
                    Icons.school, 'Sekolah', false, PageSekolah()),
                _buildSidebarItem(
                    Icons.headset_mic, 'Operator', true, PageOperator()),
                _buildSidebarItem(Icons.person, 'Guru', false, PageGuru()),
                _buildSidebarItem(
                    Icons.school_outlined, 'Siswa', false, PageSiswa()),
                _buildSidebarItem(Icons.calendar_today, 'Tahun Akademik', false,
                    PageTahunAjaran()),
                _buildSidebarItem(Icons.class_, 'Kelas', false, PageKelas()),
                _buildSidebarItem(Icons.app_registration, 'Data Pendaftaran', false,
                    DataPendaftaran()),
              ],
            ),
          ),
          Container(
            color: Colors.blue[900],
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '© 2024 Silentdra Assesstment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfilPage();
      },
    );
  }

  Widget _buildSidebarItem(
      IconData icon, String title, bool selected, Widget page) {
    return Container(
      color: selected ? Colors.amber : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({required this.text, required this.style});

  @override
  _MarqueeTextState createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(-1.0, 0.0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.stop();
      },
      onExit: (_) {
        _controller.repeat();
      },
      child: ClipRect(
        child: SlideTransition(
          position: _animation,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
