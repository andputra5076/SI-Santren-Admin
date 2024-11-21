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

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late String _currentDateTime;
  bool _isDrawerOpen = false;

  String _fullName = '';
  String _email = '';

  Future<int> fetchCount(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data is List) ? data.length : 0;
      } else {
        print('Failed to load data');
        return 0;
      }
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  Future<int> getSekolahCount() => fetchCount('http://localhost/pesantren_api/api/get-sekolah');
  Future<int> getOperatorCount() => fetchCount('http://localhost/pesantren_api/api/get-operator');
  Future<int> getGuruCount() => fetchCount('http://localhost/pesantren_api/api/get-guru');
  Future<int> getSiswaCount() => fetchCount('http://localhost/pesantren_api/api/get-murid');
  Future<int> getTahunAkademikCount() => fetchCount('http://localhost/pesantren_api/api/get-tahun');
  Future<int> getKelasCount() => fetchCount('http://localhost/pesantren_api/api/get-kelas');
  Future<int> getPendaftaranCount() => fetchCount('http://localhost/pesantren_api/api/get-pendaftaran');

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateDateTime();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? 'Unknown User';
      _email = prefs.getString('email') ?? 'No Email';
    });
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime =
          DateFormat('dd MMM yyyy').format(DateTime.now());
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

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    final bool isMobile = !isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: Text('SILENTDRA ASSESSTMENT - ADMIN PANEL'),
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
                      'Selamat Datang di Dashboard Utama - Silentdra Assesstment',
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
                        'Selamat Datang di Dashboard Utama - Silentdra Assesstment',
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
                    Expanded(
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20.0,
                          runSpacing: 20.0,
                          children: [
                            FutureBuilder<int>(
                              future: getSekolahCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.school, 'Sekolah', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getOperatorCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.headset_mic, 'Operator', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getGuruCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.person, 'Guru', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getSiswaCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.school_outlined, 'Siswa', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getTahunAkademikCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.calendar_today, 'Tahun Akademik', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getKelasCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.class_, 'Kelas', snapshot.data ?? 0);
                                }
                              },
                            ),
                            FutureBuilder<int>(
                              future: getPendaftaranCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildDashboardItem(Icons.class_, 'Data Pendaftaran', snapshot.data ?? 0);
                                }
                              },
                            ),
                          ],
                        ),
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

  Widget _buildDashboardItem(IconData icon, String label, int count) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.black),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
                _buildSidebarItem(Icons.dashboard, 'Dashboard', true, MyHome()),
                _buildSidebarItem(
                    Icons.school, 'Sekolah', false, PageSekolah()),
                _buildSidebarItem(
                    Icons.headset_mic, 'Operator', false, PageOperator()),
                _buildSidebarItem(Icons.person, 'Guru', false, PageGuru()),
                _buildSidebarItem(
                    Icons.school_outlined, 'Siswa', false, PageSiswa()),
                _buildSidebarItem(Icons.calendar_today, 'Tahun Akademik', false,
                    PageTahunAjaran()),
                _buildSidebarItem(Icons.class_, 'Kelas', false,
                    PageKelas()), // Added this line
                _buildSidebarItem(Icons.app_registration, 'Data Pendaftaran', false,
                    DataPendaftaran()), // Added this line
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
