import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'FamFinApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Family Finance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _profileImageKey = 'profile_image_path';
  String? _profileImagePath;

  // === State ===
  String? _dailyBudget;
  String _selectedCurrency = 'BGN';

  // === Controllers ===
  final _controller = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    precision: 2,
    initialValue: 0,
    rightSymbol: ' BGN',
  );

  final _opportunityController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    precision: 2,
    initialValue: 0,
  );

  // === Helpers ===
  int _getRemainingDaysInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day + 1; // +1 to include current day
  }

  void _calculateDailyBudget() {
    final total = _controller.numberValue;
    final days = _getRemainingDaysInMonth();
    if (total > 0) {
      final daily = total / days;
      setState(() {
        _dailyBudget = '${daily.toStringAsFixed(2)} BGN';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString(_profileImageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === App Bar ===
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ).then((_) => _loadProfileImage());
              },
              child: CircleAvatar(
                backgroundImage:
                    _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                child:
                    _profileImagePath == null ? const Icon(Icons.person) : null,
              ),
            ),
          ),
        ],
      ),
      // === Main Content ===
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Daily budget title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          'Daily Grocery Budget',
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Display the days left in the month.
                      Text(
                        'Days left: ${_getRemainingDaysInMonth()}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Remaining budget input field.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        child: TextField(
                          key: const Key('total_remaining_budget_input'),
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateDailyBudget(),
                          style: const TextStyle(fontSize: 24.0),
                          decoration: const InputDecoration(
                            labelText: 'Shared account budget',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24.0,
                            ),
                          ),
                        ),
                      ),
                      if (_dailyBudget != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Daily budget: $_dailyBudget',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Opportunity Cost',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _opportunityController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 24.0),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                labelStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Currency',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'BGN',
                                  child: Text('BGN'),
                                ),
                                DropdownMenuItem(
                                  value: 'EUR',
                                  child: Text('EUR'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCurrency = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
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
