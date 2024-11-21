import 'package:flutter/material.dart';
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/pendaftaran.dart';
import 'package:sipinter_admin/pengumuman.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ScrollController _scrollController;
  double _scrollPercentage = 0.0;
  String _selectedMenu = 'Tentang Kami'; // Set the default active menu item

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
                              'Tentang Kami',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF37818A),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Aplikasi Silentdra Assessment adalah aplikasi monitoring hafalan Al-Quran yang dikembangkan oleh PT. Ronstudio Digital Group. Hak Cipta © 2024 oleh PT. Ronstudio Digital Group. Owner: Tika Wijayanthi. R.',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Text(
                              'Tentang Aplikasi',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF37818A),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Silentdra Assessment adalah aplikasi yang dirancang untuk membantu monitoring hafalan Al-Quran. Dengan berbagai fitur, aplikasi ini memudahkan guru dalam memantau kemajuan hafalan siswa dan memberikan pelaporan untuk walimurid serta memberikan umpan balik yang berguna untuk peningkatan. Aplikasi ini dibuat dengan penuh dedikasi untuk memberikan pengalaman yang terbaik dalam belajar Al-Quran.',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 24.0),
                            // Download Section
                            Text(
                              'Download Aplikasi:',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF37818A),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Dapatkan aplikasi Silentdra Assessment di Play Store dan nikmati fitur-fitur terbaru untuk memantau hafalan Al-Quran dengan lebih mudah.',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                // Replace with the Play Store link
                                const url =
                                    'https://play.google.com/store/apps/details?id=com.yourcompany.yourapp';
                                // Open the Play Store link
                                launch(url);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Button color
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 20.0),
                              ),
                              child: const Text(
                                'Download di Play Store',
                                style: TextStyle(color: Colors.white),
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
                              "Tentang Kami",
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
                          items: <String>[
                            'Pengumuman',
                            'Tentang Kami',
                            'Pendaftaran'
                          ].map((String value) {
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
                                          const ProfilePage()),
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
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12.0 : 16.0,
                              vertical: isMobile ? 8.0 : 10.0,
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
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
