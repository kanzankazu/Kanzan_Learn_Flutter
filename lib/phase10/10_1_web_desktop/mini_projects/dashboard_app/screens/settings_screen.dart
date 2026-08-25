/// Settings Screen — Admin Dashboard
import 'package:flutter/material.dart';

class DashboardSettingsScreen extends StatefulWidget {
  const DashboardSettingsScreen({super.key});

  @override
  State<DashboardSettingsScreen> createState() => _DashboardSettingsScreenState();
}

class _DashboardSettingsScreenState extends State<DashboardSettingsScreen> {
  bool _darkMode = false;
  bool _emailNotif = true;
  bool _pushNotif = false;
  double _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                _section('Appearance'),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch to dark theme'),
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),

                const SizedBox(height: 16),
                _section('Notifications'),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: _emailNotif,
                  onChanged: (v) => setState(() => _emailNotif = v),
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  value: _pushNotif,
                  onChanged: (v) => setState(() => _pushNotif = v),
                ),

                const SizedBox(height: 16),
                _section('Tables'),
                ListTile(
                  title: const Text('Default rows per page'),
                  subtitle: Slider(
                    value: _pageSize,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: _pageSize.toInt().toString(),
                    onChanged: (v) => setState(() => _pageSize = v),
                  ),
                  trailing: Text('${_pageSize.toInt()}'),
                ),

                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved'))),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      );
}
