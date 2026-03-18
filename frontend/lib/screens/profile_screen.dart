import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  bool _loading = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _updateField(String endpoint, Map<String, String> body) async {
    final token = await _getToken();
    if (token == null) return;

    setState(() => _loading = true);

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/users/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? data['message'] ?? 'Updated'
                : data['error'] ?? 'Error',
          ),
        ),
      );

      if (endpoint == 'update-password' && response.statusCode == 200) {
        _currentPassController.clear();
        _newPassController.clear();
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Network error')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("Edit Informations",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      hintText: "Full Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      _updateField('update-name',
                          {'name': _nameController.text.trim()});
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text("Update Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      hintText: "Email", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_emailController.text.trim().isNotEmpty) {
                      _updateField('update-email',
                          {'email': _emailController.text.trim()});
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text("Update Email"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: "Current Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: "New Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPassController.text.trim().isNotEmpty &&
                        _newPassController.text.trim().isNotEmpty) {
                      _updateField('update-password', {
                        'current_password': _currentPassController.text.trim(),
                        'new_password': _newPassController.text.trim()
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text("Update Password"),
                ),
              ],
            ),
          );
  }
}
