import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final emailController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (passwordController.text != confirmController.text) {
      setState(() {
        _error = "Passwords do not match";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:5000/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'birth_date': birthDateController.text.trim(),
          'email': emailController.text.trim(),
          'country': countryController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['msg'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 300,
            margin: const EdgeInsets.symmetric(vertical: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "SIGN-UP",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: "Full Name")),
                const SizedBox(height: 10),
                TextField(controller: birthDateController, decoration: const InputDecoration(hintText: "Birth Date (YYYY-MM-DD)")),
                const SizedBox(height: 10),
                TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email")),
                const SizedBox(height: 10),
                TextField(controller: countryController, decoration: const InputDecoration(hintText: "Country")),
                const SizedBox(height: 10),
                TextField(controller: passwordController, decoration: const InputDecoration(hintText: "Password"), obscureText: true),
                const SizedBox(height: 10),
                TextField(controller: confirmController, decoration: const InputDecoration(hintText: "Confirm Password"), obscureText: true),
                const SizedBox(height: 20),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                _loading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("SIGN-IN"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                            child: const Text("LOGIN"),
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
