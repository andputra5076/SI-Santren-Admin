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

class PageSekolah extends StatefulWidget {
  @override
  _PageSekolahState createState() => _PageSekolahState();
}

class _PageSekolahState extends State<PageSekolah> {
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

  Future<void> _addSchool(Map<String, String> newSchool) async {
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/tambah-sekolah'),
      body: newSchool,
    );

    if (response.statusCode == 200) {
      // Assuming the status code for a successful post is 200 instead of 201
      _fetchData();
    } else {
      // Handle error
      print('Failed to add school');
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? 'Unknown User';
      _email = prefs.getString('email') ?? 'No Email';
    });
  }

  // Edit School
  Future<void> _editSchool(int id, Map<String, dynamic> updatedSchool) async {
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/edit-sekolah'),
      body: {
        'id': id.toString(),
        ...updatedSchool.map((key, value) => MapEntry(key, value.toString())),
      },
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      _fetchData();
    } else {
      // Handle error
      print('Failed to edit school');
    }
  }

  // Delete School
  Future<void> _deleteSchool(int id) async {
    final response = await http.post(
      Uri.parse('http://localhost/pesantren_api/api/hapus-sekolah'),
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

  Future<void> _fetchData() async {
    final response = await http
        .get(Uri.parse('http://localhost/pesantren_api/api/get-sekolah'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _data = jsonData
            .map((item) => {
                  'id': item['id'],
                  'no': _data.length + 1,
                  'nama_sekolah': item['nama_sekolah'],
                  'npsn': item['npsn'],
                  'alamat': item['alamat'],
                  'phone_number_sekolah': item['phone_number_sekolah'],
                  'email_sekolah': item['email_sekolah'],
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
                      'Selamat Datang di Halaman Data Sekolah - Silentdra Assesstment',
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
                        'Selamat Datang di Halaman Data Sekolah - Silentdra Assesstment',
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
                                labelText: 'Cari Sekolah',
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
                                                label: Text('Nama Sekolah')),
                                            DataColumn(label: Text('NPSN')),
                                            DataColumn(label: Text('Alamat')),
                                            DataColumn(label: Text('Telp')),
                                            DataColumn(label: Text('Email')),
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
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters, // Add this parameter
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
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        inputFormatters: inputFormatters, // Apply input formatters
      ),
    );
  }

  // Show Add School Modal
  void _showAddModal() {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String namaSekolah = '';
        String npsn = '';
        String alamat = '';
        String telp = '';
        String email = '';

        return AlertDialog(
          title: Text(
            'Tambah Sekolah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Set a maximum width for the modal dialog
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      label: 'Nama Sekolah',
                      onChanged: (value) => namaSekolah = value,
                      validator: (value) => value!.isEmpty
                          ? 'Nama Sekolah tidak boleh kosong'
                          : null,
                    ), // Add spacing between fields
                    _buildTextField(
                      label: 'NPSN',
                      onChanged: (value) => npsn = value,
                      keyboardType: TextInputType.number, // Numeric keyboard
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only digits allowed
                      validator: (value) =>
                          value!.isEmpty ? 'NPSN tidak boleh kosong' : null,
                    ), // Add spacing between fields
                    _buildTextField(
                      label: 'Alamat',
                      onChanged: (value) => alamat = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                    ),// Add spacing between fields
                    _buildTextField(
                      label: 'Telp',
                      onChanged: (value) => telp = value,
                      keyboardType: TextInputType.number, // Numeric keyboard
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only digits allowed
                      validator: (value) =>
                          value!.isEmpty ? 'Telp tidak boleh kosong' : null,
                    ),// Add spacing between fields
                    _buildTextField(
                      label: 'Email',
                      onChanged: (value) => email = value,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email tidak boleh kosong' : null,
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
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addSchool({
                    'nama_sekolah': namaSekolah,
                    'npsn': npsn,
                    'alamat': alamat,
                    'phone_number_sekolah': telp,
                    'email_sekolah': email,
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
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
  }

  void _showEditModal(Map<String, dynamic> school) {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String namaSekolah = school['nama_sekolah'].toString();
        String npsn = school['npsn'].toString();
        String alamat = school['alamat'].toString();
        String telp = school['phone_number_sekolah'].toString();
        String email = school['email_sekolah'].toString();

        return AlertDialog(
          title: Text('Edit Sekolah',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    label: 'Nama Sekolah',
                    initialValue: namaSekolah,
                    onChanged: (value) => namaSekolah = value,
                  ),
                  _buildTextField(
                    label: 'NPSN',
                    initialValue: npsn,
                    onChanged: (value) => npsn = value,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only digits allowed
                  ),
                  _buildTextField(
                    label: 'Alamat',
                    initialValue: alamat,
                    onChanged: (value) => alamat = value,
                  ),
                  _buildTextField(
                    label: 'Telp',
                    initialValue: telp,
                    onChanged: (value) => telp = value,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only digits allowed
                  ),
                  _buildTextField(
                    label: 'Email',
                    initialValue: email,
                    onChanged: (value) => email = value,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _editSchool(school['id'], {
                    'nama_sekolah': namaSekolah,
                    'npsn': npsn,
                    'alamat': alamat,
                    'phone_number_sekolah': telp,
                    'email_sekolah': email,
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
  }

  // Show Delete Confirmation Modal
  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Sekolah',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus sekolah ini?'),
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
                _deleteSchool(id);
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
      return idB.compareTo(idA); // Descending order
    });

    final visibleData = sortedData
        .where((row) =>
            row['nama_sekolah']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            row['npsn']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            row['alamat']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .skip(startIndex)
        .take(_rowsPerPage)
        .toList();

    return visibleData.asMap().entries.map<DataRow>((entry) {
      final index = entry.key;
      final row = entry.value;
      return DataRow(cells: [
        DataCell(
            Text((startIndex + index + 1).toString())), // Sequential number
        DataCell(Text(row['nama_sekolah'] ?? '')),
        DataCell(Text(row['npsn'] ?? '')),
        DataCell(Text(row['alamat'] ?? '')),
        DataCell(Text(row['phone_number_sekolah'] ?? '')),
        DataCell(Text(row['email_sekolah'] ?? '')),
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
                _buildSidebarItem(Icons.school, 'Sekolah', true, PageSekolah()),
                _buildSidebarItem(
                    Icons.headset_mic, 'Operator', false, PageOperator()),
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
