import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  bool _moodLogged = false;
  bool _loading = true;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, String>> moods = [
    {"label": "Very Happy", "emoji": "😀"},
    {"label": "Happy", "emoji": "🙂"},
    {"label": "Neutral", "emoji": "😐"},
    {"label": "Sad", "emoji": "🙁"},
    {"label": "Very Sad", "emoji": "😢"},
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayMood();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _checkTodayMood() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://better-life-wqk6.onrender.com/moods/today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => _moodLogged = true);
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitMood() async {
    if (_selectedMood == null) return;
    final token = await _getToken();
    if (token == null) return;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://better-life-wqk6.onrender.com/moods/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'mood': _selectedMood,
          'note': _noteController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _moodLogged = true;
          _selectedMood = null;
          _noteController.clear();
        });
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Network error')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildMoodButton(int index) {
    final isSelected = _selectedMood == index + 1;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = index + 1),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[300] : Colors.pink[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(moods[index]["emoji"]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(moods[index]["label"]!, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_moodLogged) {
      return const Center(
        child: Text(
          "Mood already logged today",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Log Your Mood Today", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) => _buildMoodButton(index)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: "Optional note",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitMood,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
