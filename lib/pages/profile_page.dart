import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _nameKey = 'user_name';
  static const String _birthDateKey = 'user_birth_date';
  static const String _profileImageKey = 'profile_image_path';
  static const String _retirementAgeKey = 'retirement_age';
  String _name = 'My name';
  DateTime? _birthDate;
  String? _profileImagePath;
  int _retirementAge = 65;

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadBirthDate();
    _loadProfileImage();
    _loadRetirementAge();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString(_nameKey) ?? 'My name';
    });
  }

  Future<void> _loadBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_birthDateKey);
    setState(() {
      _birthDate =
          timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : null;
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString(_profileImageKey);
    });
  }

  Future<void> _loadRetirementAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _retirementAge = prefs.getInt(_retirementAgeKey) ?? 65;
    });
  }

  Future<void> _updateName() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _NameEditDialog(initialName: _name),
    );

    if (newName != null) {
      await prefs.setString(_nameKey, newName);
      setState(() {
        _name = newName;
      });
    }
  }

  Future<void> _updateBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_birthDateKey, picked.millisecondsSinceEpoch);
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = '${directory.path}/$imageName';

      await File(image.path).copy(imagePath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, imagePath);

      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  Future<void> _updateRetirementAge() async {
    final int? newAge = await showDialog<int>(
      context: context,
      builder: (context) => _RetirementAgeDialog(initialAge: _retirementAge),
    );

    if (newAge != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_retirementAgeKey, newAge);
      setState(() {
        _retirementAge = newAge;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _updateProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                child:
                    _profileImagePath == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(_name),
              trailing: const Icon(Icons.edit),
              onTap: _updateName,
            ),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Birth date'),
              subtitle: Text(
                _birthDate != null
                    ? DateFormat.yMMMMd().format(_birthDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.edit),
              onTap: _updateBirthDate,
            ),
            ListTile(
              leading: const Icon(Icons.elderly),
              title: const Text('Retirement age'),
              subtitle: Text('$_retirementAge years'),
              trailing: const Icon(Icons.edit),
              onTap: _updateRetirementAge,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameEditDialog extends StatefulWidget {
  final String initialName;

  const _NameEditDialog({required this.initialName});

  @override
  State<_NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<_NameEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _RetirementAgeDialog extends StatefulWidget {
  final int initialAge;

  const _RetirementAgeDialog({required this.initialAge});

  @override
  State<_RetirementAgeDialog> createState() => _RetirementAgeDialogState();
}

class _RetirementAgeDialogState extends State<_RetirementAgeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAge.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Age'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final age = int.tryParse(_controller.text);
            if (age != null && age > 0 && age < 100) {
              Navigator.of(context).pop(age);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
