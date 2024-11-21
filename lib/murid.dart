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
import 'package:http/http.dart' as http;

class PageSiswa extends StatefulWidget {
  @override
  _PageSiswaState createState() => _PageSiswaState();
}

class _PageSiswaState extends State<PageSiswa> {
  late String _currentDateTime;
  bool _isDrawerOpen = false;
  String _fullName = '';
  String _email = '';
  String _searchQuery = '';
  int _currentPage = 1;
  final int _rowsPerPage = 10;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateDateTime();
    
    _fetchData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? 'Unknown User';
      _email = prefs.getString('email') ?? 'No Email';
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

  void _updateDateTime() {
    setState(() {
      _currentDateTime =
          DateFormat('dd MMM yyyy').format(DateTime.now());
    });
  }

  Future<void> _fetchData() async {
    final response = await http
        .get(Uri.parse('http://localhost/pesantren_api/api/get-murid'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      setState(() {
        _data = responseData
            .map((item) => {
                  'nama_lengkap': item['nama_lengkap'],
                  'nis': item['nis'],
                  'nisn': item['nisn'],
                  'password': item[
                      'password'], // Ensure that 'password' is handled securely
                  'alamat': item['alamat'],
                  'no_telepon': item['no_telepon'],
                  'email': item['email'],
                  'wali_murid': item['wali_murid'],
                  'no_telepon_wali_murid': item['no_telepon_wali_murid'],
                  'kelas': item['kelas'],
                  'nama_sekolah': item['nama_sekolah'],
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
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
                      'Selamat Datang di Halaman Data Siswa - Silentdra Assesstment',
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
                        'Selamat Datang di Halaman Data Siswa - Silentdra Assesstment',
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
                                  _currentPage = 1; // Reset to first page
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Cari Siswa',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
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
                                            DataColumn(label: Text('NIS')),
                                            DataColumn(label: Text('NISN')),
                                            DataColumn(label: Text('Password')),
                                            DataColumn(label: Text('Alamat')),
                                            DataColumn(label: Text('Telepon')),
                                            DataColumn(label: Text('Email')),
                                            DataColumn(
                                                label: Text('Wali Murid')),
                                            DataColumn(
                                                label: Text('Telp Wali Murid')),
                                            DataColumn(label: Text('Kelas')),
                                            DataColumn(label: Text('Sekolah')),
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
                                            onPressed: _data.length >
                                                    _rowsPerPage * _currentPage
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
                    // Footer for both mobile and desktop views
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

  List<DataRow> _buildDataRows() {
    final filteredData = _data.where((row) {
      final name = row['nama_lengkap'].toString().toLowerCase();
      final nis = row['nis'].toString().toLowerCase();
      final nisn = row['nisn'].toString().toLowerCase();
      final kelas = row['kelas'].toString().toLowerCase();
      final wali = row['wali_murid'].toString().toLowerCase();
      final sekolah = row['nama_sekolah'].toString().toLowerCase();
      final searchQuery = _searchQuery.toLowerCase();
      return name.contains(searchQuery) ||
          nis.contains(searchQuery) ||
          nisn.contains(searchQuery) ||
          kelas.contains(searchQuery) ||
          wali.contains(searchQuery) ||
          sekolah.contains(searchQuery);
    }).toList();

    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredData.length);

    return List<DataRow>.generate(
      endIndex - startIndex,
      (index) {
        final item = filteredData[startIndex + index];
        return DataRow(
          cells: [
            DataCell(Text('${startIndex + index + 1}')),
            DataCell(Text(item['nama_lengkap'] ?? '')),
            DataCell(Text(item['nis'] ?? '')),
            DataCell(Text(item['nisn'] ?? '')),
            DataCell(Text(item['password'] ??
                '')), // Ensure that 'password' is handled securely
            DataCell(Text(item['alamat'] ?? '')),
            DataCell(Text(item['no_telepon'] ?? '')),
            DataCell(Text(item['email'] ?? '')),
            DataCell(Text(item['wali_murid'] ?? '')),
            DataCell(Text(item['no_telepon_wali_murid'] ?? '')),
            DataCell(Text(item['kelas'] ?? '')),
            DataCell(
                Text(item['nama_sekolah'] ?? '')), // Add this line for Sekolah
          ],
        );
      },
    );
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
                    Icons.headset_mic, 'Operator', false, PageOperator()),
                _buildSidebarItem(Icons.person, 'Guru', false, PageGuru()),
                _buildSidebarItem(
                    Icons.school_outlined, 'Siswa', true, PageSiswa()),
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
