import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipinter_admin/home.dart';
import 'package:sipinter_admin/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureTextNewPassword = true;
  bool _isFormVisible = false;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isFormVisible = true;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 10.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -10.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    }
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _triggerShakeAnimation();
      _showErrorDialog('Masukkan Username dan Password Terlebih Dahulu!');
      return;
    }

    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('http://localhost/pesantren_api/api/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is! Map<String, dynamic>) {
          _triggerShakeAnimation();
          _showErrorDialog('Invalid response from the server');
          return;
        }

        final Map<String, dynamic> responseData = jsonResponse;

        if (responseData['status'] == 'success') {
          await _saveSessionData(responseData['user']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHome()),
          );
        } else {
          _triggerShakeAnimation();
          _showErrorDialog(responseData['message'] ?? 'Unknown error occurred');
        }
      } else {
        _triggerShakeAnimation();
        _showErrorDialog('Failed to connect to the server');
      }
    } catch (e) {
      _triggerShakeAnimation();
      _showErrorDialog('An error occurred: $e');
    } finally {
      client.close();
    }
  }

  Future<void> _saveSessionData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'userId', userData['id'].toString()); // Convert to String
    await prefs.setString(
        'username', userData['username'].toString()); // Ensure it's a String
    await prefs.setString(
        'full_name', userData['full_name'].toString()); // Convert to String if necessary
    await prefs.setString(
        'email', userData['email'].toString()); // Convert to String if necessary
    await prefs.setString(
        'phone_number', userData['phone_number'].toString()); // Convert to String if necessary
    await prefs.setString(
        'address', userData['address'].toString()); // Convert to String if necessary
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _triggerShakeAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedOpacity(
                opacity: _isFormVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: <Widget>[
                    Text(
                      'SILENTDRA ASSESSMENT | ADMIN PANEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 600 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: screenWidth < 600 ? double.infinity : 400,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SlideTransition(
                        position: _isFormVisible
                            ? Tween<Offset>(
                                    begin: Offset(0, 0), end: Offset.zero)
                                .animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeInOut,
                              ))
                            : Tween<Offset>(
                                    begin: Offset(0, 0), end: Offset(1.0, 0.0))
                                .animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeInOut,
                              )),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      prefixIcon: const Icon(Icons.person,
                                          color: Color(0xFF37818A)),
                                      hintText: "Username",
                                      fillColor: Colors.grey[100],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscureTextNewPassword,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureTextNewPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Color(0xFF37818A),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureTextNewPassword =
                                                !_obscureTextNewPassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      prefixIcon: const Icon(Icons.lock,
                                          color: Color(0xFF37818A)),
                                      fillColor: Colors.grey[100],
                                      hintText: "Password",
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _isFormVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  '© 2024 RONSTUDIO SOFTWARE Inc.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
