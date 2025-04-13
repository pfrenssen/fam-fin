import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  // === Controllers ===
  final _controller = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    precision: 2,
    initialValue: 0,
    rightSymbol: ' BGN',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === App Bar ===
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // === Main Content ===
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Daily budget title.
            const Text('Daily grocery budget'),
            // Daily budget input field.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: TextField(
                key: const Key('budget_input'),
                controller: _controller,
                keyboardType: TextInputType.number,
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
          ],
        ),
      ),
    );
  }
}
