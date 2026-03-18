import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'mood_screen.dart';
import 'weekly_insights_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'delete_account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentPage = "Mood Log";

  Widget _getPage() {
    switch (_currentPage) {
      case "Mood Log":
        return const MoodScreen();
      case "Weekly Insights":
        return const WeeklyInsightsScreen();
      case "Profile":
        return const ProfileScreen();
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  void _selectPage(String page) {
    setState(() => _currentPage = page);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentPage)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
                child: Image.asset(
                    'assets/logo.png',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                ),
            ),
            ),
            ListTile(
              title: const Text("Mood Log"),
              onTap: () => _selectPage("Mood Log"),
            ),
            ListTile(
              title: const Text("Weekly Insights"),
              onTap: () => _selectPage("Weekly Insights"),
            ),
            ListTile(
              title: const Text("Profile"),
              onTap: () => _selectPage("Profile"),
            ),
            ListTile(
                title: const Text("Logout"),
                onTap: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');
                Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                );
                },
            ),
            ListTile(
                title: const Text("Delete Account"),
                onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
                );
                },
            ),
          ],
        ),
      ),
      body: _getPage(),
    );
  }
}
