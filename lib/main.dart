import 'package:flutter/material.dart';
import 'package:sipinter_admin/pendaftaran.dart';
import 'package:sipinter_admin/pengumuman.dart';
import 'package:sipinter_admin/tentang.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sipinter_admin/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> _imagePaths = [
    'assets/image/tampil1.gif',
    'assets/image/tampil2.gif',
    'assets/image/tampil3.gif',
    'assets/image/tampil4.gif',
    'assets/image/tampil5.png',
    'assets/image/tampil6.gif',
    'assets/image/tampil7.gif',
    'assets/image/tampil8.gif',
    'assets/image/tampil9.gif',
    'assets/image/tampil10.gif',
    'assets/image/tampil11.gif',
    'assets/image/tampil12.gif',
    'assets/image/tampil13.png',
  ];

  late ScrollController _scrollController;
  double _scrollPercentage = 0.0;

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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return VisibilityDetector(
                        key: Key('image_$index'),
                        onVisibilityChanged: (VisibilityInfo info) {
                          // No animation on visibility change
                        },
                        child: Image.asset(
                          _imagePaths[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    childCount: _imagePaths.length,
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
              color:
                  Color(0xFF37818A).withOpacity(0.3), // Transparent background
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth <
                      600; // Define mobile width threshold
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "YUK HAFALAN AL-QUR'AN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile
                                ? 16.0
                                : 20.0, // Adjust font size based on screen width
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1, // Limit text to a single line
                          overflow: TextOverflow
                              .ellipsis, // Handle overflow with ellipsis
                        ),
                      ),

                      SizedBox(
                          width: isMobile
                              ? 8.0
                              : 8.0), // Adjust spacing based on screen width (reduced)

                      // Pengumuman Dropdown
                      DropdownButton<String>(
                        dropdownColor: Colors.blue,
                        underline: SizedBox(), // Removes underline
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        style: TextStyle(
                            color: Colors.white), // Dropdown text color
                        items: <String>['Pengumuman', 'Tentang Kami', 'Pendaftaran']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue == 'Pengumuman') {
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PengumumanPage()),
                        );
                          } else if (newValue == 'Tentang Kami') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          }
                          else if (newValue == 'Pendaftaran') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PendaftaranPage()),
                            );
                          }
                        },
                        hint: const Text(
                          "Menu",
                          style: TextStyle(
                              color: Colors.white), // Dropdown hint color
                        ),
                      ),

                      SizedBox(
                          width: isMobile
                              ? 4.0
                              : 8.0), // Reduced spacing between dropdown and button

                      // Masuk Button
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

          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50.0, // Reduced size
                  height: 50.0, // Reduced size
                  child: CircularProgressIndicator(
                    value: _scrollPercentage / 100,
                    strokeWidth: 3.0, // Reduced stroke width
                    backgroundColor: Colors.black.withOpacity(0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF37818A)),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _scrollToTop,
                    child: Container(
                      width: 40.0, // Reduced size
                      height: 40.0, // Reduced size
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 24.0, // Reduced icon size
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
