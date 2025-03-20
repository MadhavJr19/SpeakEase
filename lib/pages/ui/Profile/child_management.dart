import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildManagementPage extends StatefulWidget {
  const ChildManagementPage({super.key});

  @override
  State<ChildManagementPage> createState() => _ChildManagementPageState();
}

class _ChildManagementPageState extends State<ChildManagementPage> {
  bool _contentFilterEnabled = true;
  bool _timeRestrictionsEnabled = false;
  bool _parentalLockEnabled = true;
  String _parentalPin = '1234'; // Default PIN
  bool _isChangingPin = false;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  int _dailyTimeLimit = 60; // in minutes

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contentFilterEnabled = prefs.getBool('content_filter_enabled') ?? true;
      _timeRestrictionsEnabled = prefs.getBool('time_restrictions_enabled') ?? false;
      _parentalLockEnabled = prefs.getBool('parental_lock_enabled') ?? true;
      _parentalPin = prefs.getString('parental_pin') ?? '1234';
      _dailyTimeLimit = prefs.getInt('daily_time_limit') ?? 60;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('content_filter_enabled', _contentFilterEnabled);
    await prefs.setBool('time_restrictions_enabled', _timeRestrictionsEnabled);
    await prefs.setBool('parental_lock_enabled', _parentalLockEnabled);
    await prefs.setString('parental_pin', _parentalPin);
    await prefs.setInt('daily_time_limit', _dailyTimeLimit);
  }

  void _showPinDialog(Function onCorrectPin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Parental PIN'),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
          ),
          maxLength: 4,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pinController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_pinController.text == _parentalPin) {
                Navigator.pop(context);
                onCorrectPin();
                _pinController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _changePin() {
    setState(() {
      _isChangingPin = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Parental PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter new 4-digit PIN',
              ),
              maxLength: 4,
            ),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm new PIN',
              ),
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newPinController.clear();
              _confirmPinController.clear();
              setState(() {
                _isChangingPin = false;
              });
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newPinController.text.length == 4 &&
                  _newPinController.text == _confirmPinController.text) {
                setState(() {
                  _parentalPin = _newPinController.text;
                  _isChangingPin = false;
                });
                _saveSettings();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
                _newPinController.clear();
                _confirmPinController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match or invalid format')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Management'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),

          // Parental Lock Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parental Controls',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Parental Lock'),
                    subtitle: const Text('Require PIN for changing settings'),
                    value: _parentalLockEnabled,
                    onChanged: (value) {
                      if (_parentalLockEnabled) {
                        _showPinDialog(() {
                          setState(() {
                            _parentalLockEnabled = value;
                          });
                          _saveSettings();
                        });
                      } else {
                        setState(() {
                          _parentalLockEnabled = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Parental PIN'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (_parentalLockEnabled) {
                        _showPinDialog(_changePin);
                      } else {
                        _changePin();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content Filter Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Controls',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Content Filter'),
                    subtitle: const Text('Block inappropriate content'),
                    value: _contentFilterEnabled,
                    onChanged: (value) {
                      if (_parentalLockEnabled) {
                        _showPinDialog(() {
                          setState(() {
                            _contentFilterEnabled = value;
                          });
                          _saveSettings();
                        });
                      } else {
                        setState(() {
                          _contentFilterEnabled = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time Controls Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Controls',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Time Restrictions'),
                    subtitle: const Text('Limit daily app usage time'),
                    value: _timeRestrictionsEnabled,
                    onChanged: (value) {
                      if (_parentalLockEnabled) {
                        _showPinDialog(() {
                          setState(() {
                            _timeRestrictionsEnabled = value;
                          });
                          _saveSettings();
                        });
                      } else {
                        setState(() {
                          _timeRestrictionsEnabled = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),

                  // Only show time slider if time restrictions are enabled
                  if (_timeRestrictionsEnabled)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Daily Time Limit (minutes)'),
                        ),
                        Slider(
                          value: _dailyTimeLimit.toDouble(),
                          min: 15,
                          max: 180,
                          divisions: 11,
                          label: _dailyTimeLimit.toString(),
                          onChanged: (double value) {
                            setState(() {
                              _dailyTimeLimit = value.toInt();
                            });
                          },
                          onChangeEnd: (double value) {
                            _saveSettings();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Current limit: $_dailyTimeLimit minutes'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Child Profiles Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Child Profiles',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: const Text('Add Child Profile'),
                    subtitle: const Text('Create a new profile for your child'),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      // Add child profile functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}