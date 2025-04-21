import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

import 'models/frequency_period.dart';

import 'pages/profile_page.dart';

import 'services/exponential_countdown.dart';
import 'services/retirement_service.dart';
import 'services/user_preferences_service.dart';

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

enum PurchaseType { oneTime, recurring }

class _MyHomePageState extends State<MyHomePage> {
  final _exponentialService = ExponentialCountdownService();
  final _prefsService = UserPreferencesService();
  final _retirementService = RetirementService();
  String? _profileImagePath;
  DateTime? _birthDate;
  int _retirementAge = 65;

  // === State ===
  String? _dailyBudget;
  String _selectedCurrency = 'BGN';

  PurchaseType _purchaseType = PurchaseType.oneTime;
  int _frequencyCount = 1;
  FrequencyPeriod _frequencyPeriod = FrequencyPeriod.month;

  double? _opportunityInvested;
  double? _opportunityInterest;
  double? _opportunityTotal;

  bool _showOpportunityDetails = false;

  // Countdown state
  bool _isCountdownRunning = false;
  DateTime? _countdownStartTime;
  String _countdownValue = '0:00';
  Timer? _countdownTimer;

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

  void _calculateOpportunityCost() {
    final amount = _opportunityController.numberValue;
    if (amount <= 0) {
      setState(() {
        _opportunityInvested = null;
        _opportunityInterest = null;
        _opportunityTotal = null;
      });
      return;
    }

    final result =
        _purchaseType == PurchaseType.oneTime
            ? _retirementService.calculateOneTimeOpportunityCost(
              amount,
              _birthDate,
              _retirementAge,
            )
            : _retirementService.calculateRecurringOpportunityCost(
              amount,
              _birthDate,
              _retirementAge,
              _frequencyCount,
              _frequencyPeriod,
            );

    setState(() {
      _opportunityInvested = result.invested;
      _opportunityInterest = result.interest;
      _opportunityTotal = result.total;
    });
  }

  void _startCountdown() {
    setState(() {
      _isCountdownRunning = true;
      _countdownStartTime = DateTime.now();
      _countdownValue = _exponentialService.formatValue(
        _exponentialService.calculateValue(0),
      );
    });

    // Update twice per second (every 500ms)
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (_countdownStartTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_countdownStartTime!);
        final hours =
            difference.inMilliseconds / (1000 * 60 * 60); // Convert to hours
        final value = _exponentialService.calculateValue(-hours);

        setState(() {
          _countdownValue = _exponentialService.formatValue(value);
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownRunning = false;
      _countdownStartTime = null;
      _countdownValue = '0:00';
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final imagePath = await _prefsService.getProfileImagePath();
    final birthDate = await _prefsService.getBirthDate();
    final retirementAge = await _prefsService.getRetirementAge();

    setState(() {
      _profileImagePath = imagePath;
      _birthDate = birthDate;
      _retirementAge = retirementAge;
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
                )
                // Make sure to reload the user preferences after returning from
                // the profile page, since the preferences might have changed.
                .then((_) => _loadUserPreferences());
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
                      SegmentedButton<PurchaseType>(
                        segments: const [
                          ButtonSegment(
                            value: PurchaseType.oneTime,
                            label: Text('One Time'),
                          ),
                          ButtonSegment(
                            value: PurchaseType.recurring,
                            label: Text('Recurring'),
                          ),
                        ],
                        selected: {_purchaseType},
                        onSelectionChanged: (Set<PurchaseType> selection) {
                          setState(() {
                            _purchaseType = selection.first;
                            _calculateOpportunityCost();
                          });
                        },
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
                              onChanged: (_) => _calculateOpportunityCost(),
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
                      if (_purchaseType == PurchaseType.recurring)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<int>(
                                  value: _frequencyCount,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Frequency',
                                  ),
                                  items:
                                      List.generate(12, (index) => index + 1)
                                          .map(
                                            (count) => DropdownMenuItem(
                                              value: count,
                                              child: Text(count.toString()),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _frequencyCount = value;
                                        _calculateOpportunityCost();
                                      });
                                    }
                                  },
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  'per',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<FrequencyPeriod>(
                                  value: _frequencyPeriod,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Period',
                                  ),
                                  items:
                                      FrequencyPeriod.values
                                          .map(
                                            (period) => DropdownMenuItem(
                                              value: period,
                                              child: Text(period.name),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _frequencyPeriod = value;
                                        _calculateOpportunityCost();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      if (_opportunityTotal != null) ...[
                        Text(
                          '${_opportunityTotal?.toStringAsFixed(2)} $_selectedCurrency',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32.0,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showOpportunityDetails =
                                  !_showOpportunityDetails;
                            });
                          },
                          icon: Icon(
                            _showOpportunityDetails
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          label: Text(
                            _showOpportunityDetails
                                ? 'Hide details'
                                : 'Show details',
                          ),
                        ),
                        if (_showOpportunityDetails) ...[
                          Text(
                            'Invested: ${_opportunityInvested?.toStringAsFixed(2)} $_selectedCurrency',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Interest earned: ${_opportunityInterest?.toStringAsFixed(2)} $_selectedCurrency',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.green),
                          ),
                          Text(
                            'Time until retirement: ${_retirementService.formatDaysUntilRetirement(_birthDate, _retirementAge)}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              // === Screen time countdown ===
              const SizedBox(height: 16.0),
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Screen time countdown',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        _countdownValue,
                        style: const TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed:
                            _isCountdownRunning
                                ? _stopCountdown
                                : _startCountdown,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 12.0,
                          ),
                          backgroundColor:
                              _isCountdownRunning ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          _isCountdownRunning ? 'Stop' : 'Start',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (_countdownStartTime != null)
                        Text(
                          'Started at: ${_countdownStartTime!.hour}:${_countdownStartTime!.minute.toString().padLeft(2, '0')}:${_countdownStartTime!.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
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
