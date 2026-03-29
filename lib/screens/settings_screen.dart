// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool(Constants.themeKey) ?? false;
      // Load saved username (hardcoded key)
      _nameController.text = prefs.getString('user_display_name') ?? '';
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.themeKey, value);
    setState(() => _isDarkMode = value);
    widget.onThemeChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🌙 Theme Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle app theme'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
              secondary: const Icon(Icons.brightness_6),
            ),
            const Divider(),

            // 👤 Your Profile
            const Text(
              'Your Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display Name Input
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter at least 6 characters',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                helperText: 'Minimum 6 characters required',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                if (value.length < 6) {
                  return 'Minimum 6 characters';
                }
                return null;
              },
              maxLength: 30,
              buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/30',
                  style: TextStyle(
                    color: currentLength < 6 ? Colors.orange : Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Saved: ${_nameController.text}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  // Save username (hardcoded key)
                  _saveUserName(_nameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Profile'),
            ),

            const SizedBox(height: 30),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About This App',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A lightweight news app powered by AI.\n\n'
                      '• Fetch trending news\n'
                      '• AI-powered summaries\n'
                      '• Works offline\n\n'
                      'Made with ❤️ using Flutter With Gemini API.',
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save username to SharedPreferences
  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    // Use hardcoded key (no Constants dependency)
    await prefs.setString('user_display_name', name);
  }
}
