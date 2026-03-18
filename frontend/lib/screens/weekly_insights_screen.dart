import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyInsightsScreen extends StatefulWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  State<WeeklyInsightsScreen> createState() => _WeeklyInsightsScreenState();
}

class _WeeklyInsightsScreenState extends State<WeeklyInsightsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyInsights();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchWeeklyInsights() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/insights/weekly'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Widget _buildDayCard(String day, Map<String, dynamic> mood) {
    String display = mood["value"] != null ? "${mood['value']} - ${mood['label']}" : "No entry";
    String note = mood["note"] ?? "";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(display),
            if (note.isNotEmpty) Text("Note: $note", style: const TextStyle(fontStyle: FontStyle.italic)),
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
    if (_data == null) {
      return const Center(child: Text("No insights available"));
    }

    final dailyMoods = _data!["daily_moods"] as Map<String, dynamic>;
    final totals = _data!["totals"] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Mood across the week ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...dailyMoods.entries.map((e) => _buildDayCard(e.key, e.value)),
          const Divider(height: 30, thickness: 1.5),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text("Summary: ${_data!['summary']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Average mood: ${_data!['average']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Trend: ${_data!['trend']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Totals - Happy: ${totals['happy']}, Neutral: ${totals['neutral']}, Sad: ${totals['sad']}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
