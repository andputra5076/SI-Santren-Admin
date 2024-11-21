import 'package:flutter/material.dart';
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/pendaftaran.dart';
import 'package:sipinter_admin/tentang.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({Key? key}) : super(key: key);

  @override
  _PengumumanPageState createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  late ScrollController _scrollController;
  double _scrollPercentage = 0.0;
  String _selectedMenu = 'Pengumuman'; // Set the default active menu item

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final totalScrollHeight = _scrollController.position.maxScrollExtent;
    final currentScrollPosition = _scrollController.position.pixels;
    final scrollPercentage =
        (currentScrollPosition / totalScrollHeight).clamp(0.0, 1.0) * 100;

    setState(() {
      _scrollPercentage = scrollPercentage;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onPageScroll();
              }
              return true;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height:
                                    80.0), // Adjust this height based on the header's height
                            Text(
                              'Pengumuman',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF37818A),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Selamat datang di halaman Pengumuman. Berikut adalah informasi terkini mengenai pendaftaran dan berita penting.',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFe0f7fa),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendaftaran PAUD:',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00796b),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    'Pendaftaran PAUD (Pendidikan Anak Usia Dini) dibuka mulai tanggal 1 hingga 30 September 2024. Silakan kunjungi situs kami untuk mendaftar.',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFe1bee7),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendaftaran SD:',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6a1b9a),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    'Pendaftaran SD (Sekolah Dasar) dimulai pada tanggal 1 hingga 31 Oktober 2024. Kunjungi situs kami untuk pendaftaran online.',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFfbe9e7),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendaftaran SMA:',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFd32f2f),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    'Pendaftaran SMA (Sekolah Menengah Atas) akan dilaksanakan dari 1 November hingga 15 Desember 2024. Daftar sekarang melalui situs kami.',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add more content here if needed
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sticky Transparent Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              color: Color(0xFF37818A).withOpacity(0.8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: double
                        .infinity), // Ensures the Row gets a bounded width
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(
                                    context); // Go back to previous screen
                              },
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              "Pengumuman",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 16.0 : 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(width: isMobile ? 8.0 : 8.0),
                        DropdownButton<String>(
                          dropdownColor: Colors.blue,
                          underline: SizedBox(),
                          icon:
                              Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: TextStyle(color: Colors.white),
                          items: <String>['Pengumuman', 'Tentang Kami', 'Pendaftaran']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: _selectedMenu == value
                                      ? Colors.yellow
                                      : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                          value: _selectedMenu,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedMenu = newValue;
                              });
                              if (newValue == 'Pengumuman') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PengumumanPage()),
                                );
                              } else if (newValue == 'Tentang Kami') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfilePage()), // Assuming this is the correct page
                                );
                              }
                              else if (newValue == 'Pendaftaran') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PendaftaranPage()),
                            );
                          }
                            }
                          },
                          hint: const Text(
                            "Menu",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: isMobile ? 4.0 : 8.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginPage()), // Replace with your login page widget
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12.0 : 16.0,
                              vertical: isMobile ? 8.0 : 10.0,
                            ), // Adjust padding based on screen width
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
