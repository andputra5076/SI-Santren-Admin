import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/pengumuman.dart';

import 'package:flutter/services.dart';
import 'package:sipinter_admin/tentang.dart';

class PendaftaranPage extends StatefulWidget {
  const PendaftaranPage({Key? key}) : super(key: key);

  @override
  _PendaftaranPageState createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _namaSekolahController = TextEditingController();
  final TextEditingController _npsnController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nomorTelpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedMenu = 'Pendaftaran'; // Default active menu item
  bool _isLoading = false; // Loading state for the submit button

  @override
  void dispose() {
    _namaSekolahController.dispose();
    _npsnController.dispose();
    _alamatController.dispose();
    _nomorTelpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to send data to the API
  Future<void> _submitData() async {
  final apiUrl = 'http://localhost/pesantren_api/api/tambah-pendaftaran';

  // Show loading state
  setState(() {
    _isLoading = true;
  });

  try {
    // Make the HTTP POST request with form data
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'nama_sekolah': _namaSekolahController.text,
        'npsn': _npsnController.text,
        'alamat': _alamatController.text,
        'telp': _nomorTelpController.text,
        'email': _emailController.text,
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a success response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan')),
      );

      // Clear the form fields
      _namaSekolahController.clear();
      _npsnController.clear();
      _alamatController.clear();
      _nomorTelpController.clear();
      _emailController.clear();

      // Optionally reset the form key
      _formKey.currentState?.reset();
    } else {
      // If the server returns an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data')),
      );
    }
  } catch (error) {
    // Handle any errors during the request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan')),
    );
  } finally {
    // Hide loading state
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 80.0), // Space for the header
                  Text(
                    'Pendaftaran',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37818A),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _namaSekolahController,
                    decoration: InputDecoration(
                      labelText: 'Nama Sekolah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _npsnController,
                    decoration: InputDecoration(
                      labelText: 'NPSN',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NPSN harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _alamatController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                   TextFormField(
                    controller: _nomorTelpController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor Telepon harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      } else if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+') // Simple email validation
                          .hasMatch(value)) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _submitData(); // Call the API to submit the form data
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF37818A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              color: Color(0xFF37818A).withOpacity(0.8),
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
                              Navigator.pop(context); // Go back to previous screen
                            },
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "Pendaftaran",
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
                      DropdownButton<String>(
                        dropdownColor: Colors.blue,
                        underline: SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
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
                                    builder: (context) => const ProfilePage()),
                              );
                            } else if (newValue == 'Pendaftaran') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PendaftaranPage()),
                              );
                            }
                          }
                        },
                                                hint: const Text(
                          "Menu",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
        ],
      ),
    );
  }
}

