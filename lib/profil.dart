import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:sipinter_admin/login.dart';
import 'package:sipinter_admin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _obscureText = true;
  String _fullName = '';
  String _email = '';
  String _username = '';
  String _phone_number = '';
  String _address = '';
  String _password = ''; // Variable to hold the password input
  String _id = ''; // ID for the user

  TextEditingController fullNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? 'Unknown User';
      _email = prefs.getString('email') ?? 'No Email';
      _username = prefs.getString('username') ?? 'No Username';
      _phone_number = prefs.getString('phone_number') ?? 'No Phone Number';
      _address = prefs.getString('address') ?? 'No Address';
      _id = prefs.getString('id') ?? ''; // Load user ID

      // Update controllers with the fetched data
      fullNameController.text = _fullName;
      addressController.text = _address;
      phoneNumberController.text = _phone_number;
      emailController.text = _email;
      usernameController.text = _username;
    });
  }

  Future<void> _saveProfile() async {
  // Prepare the updated profile data
  Map<String, dynamic> updatedProfile = {
    'full_name': fullNameController.text,
    'address': addressController.text,
    'phone_number': phoneNumberController.text,
    'email': emailController.text,
    'username': usernameController.text,
  };

  // Only add the password if it was changed
  if (passwordController.text.isNotEmpty) {
    updatedProfile['password'] = passwordController.text;
  }

  // Call the _editAdmin method with the user ID and the updated data
  await _editAdmin(int.parse(_id), updatedProfile);
}

Future<void> _editAdmin(int id, Map<String, dynamic> updatedProfile) async {
  final response = await http.post(
    Uri.parse('http://localhost/pesantren_api/api/edit-admin'),
    body: {
      'id': id.toString(),
      ...updatedProfile.map((key, value) => MapEntry(key, value.toString())),
    },
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  );

  if (response.statusCode == 200) {
    // Handle successful update (e.g., show a success message or navigate)
    print('Profile updated successfully');
    Navigator.of(context).pop();
  } else {
    // Handle error
    print('Failed to update profile');
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pengaturan Akun'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              controller: fullNameController,
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              controller: addressController,
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Telepon',
                border: OutlineInputBorder(),
              ),
              controller: phoneNumberController,
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: emailController,
            ),
            Divider(height: 32.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              controller: usernameController,
            ),
            SizedBox(height: 8.0),
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              controller: passwordController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Simpan'),
          onPressed: _saveProfile, // Save profile when the button is pressed
        ),
      ],
    );
  }
}
