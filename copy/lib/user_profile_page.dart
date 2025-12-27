import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// UPDATED COLOR THEME
const Color primaryBlue = Color(0xFF1F4E79);
const Color darkBlue = Color(0xFF153759);
const Color lightBackground = Color(0xFFF4F7F3);
const Color accentGold = Color(0xFFC48A3A);
const Color textDark = Color(0xFF1E1E1E);
const Color lightSand = Color(0xFFF4F7F3);

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _name = '';
  String _mobile = '';
  String _email = '';
  String _address = '';
  String _state = '';
  String _district = '';
  String _taluka = '';
  String _village = '';
  String _landmark = '';
  String _pincode = '';
  String _altContact = '';
  String _photo = '';

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _altContactController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final String _apiUrl = 'https://api.bhangarseva.com/user_prof/user_info/';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to get data from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_profile');

      if (savedData != null) {
        final userData = json.decode(savedData);
        _updateLocalVariables(userData);
      }

      // Always fetch fresh data from API
      await _fetchUserDataFromAPI();
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserDataFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'].isNotEmpty) {
          final userData = data['data'][0];

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile', json.encode(userData));

          if (mounted) {
            _updateLocalVariables(userData);
          }
        } else {
          throw Exception('No user data found in response');
        }
      } else {
        throw Exception('Failed to load profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from API: $e');
      rethrow;
    }
  }

  void _updateLocalVariables(Map<String, dynamic> userData) {
    if (!mounted) return;

    setState(() {
      _firstNameController.text = userData['first_name']?.toString() ?? '';
      _middleNameController.text = userData['middle_name']?.toString() ?? '';
      _lastNameController.text = userData['last_name']?.toString() ?? '';
      _emailController.text = userData['user']?.toString() ?? '';
      _mobileController.text = userData['contact']?.toString() ?? '';
      _altContactController.text = userData['alt_contact']?.toString() ?? '';
      _stateController.text = userData['state']?.toString() ?? '';
      _districtController.text = userData['district']?.toString() ?? '';
      _talukaController.text = userData['taluka']?.toString() ?? '';
      _villageController.text = userData['village']?.toString() ?? '';
      _addressController.text = userData['address']?.toString() ?? '';
      _landmarkController.text = userData['landmark']?.toString() ?? '';
      _pincodeController.text = userData['pincode']?.toString() ?? '';
      _photo = userData['photo']?.toString() ?? '';

      // Update display variables
      _email = userData['user']?.toString() ?? '';
      _mobile = userData['contact']?.toString() ?? '';
      _altContact = userData['alt_contact']?.toString() ?? '';
      _state = userData['state']?.toString() ?? '';
      _district = userData['district']?.toString() ?? '';
      _taluka = userData['taluka']?.toString() ?? '';
      _village = userData['village']?.toString() ?? '';
      _address = userData['address']?.toString() ?? '';
      _landmark = userData['landmark']?.toString() ?? '';
      _pincode = userData['pincode']?.toString() ?? '';
      _photo = userData['photo']?.toString() ?? '';

      // Combine name parts
      final firstName = userData['first_name']?.toString() ?? '';
      final middleName = userData['middle_name']?.toString() ?? '';
      final lastName = userData['last_name']?.toString() ?? '';
      _name = '$firstName${middleName.isNotEmpty ? ' $middleName' : ''}${lastName.isNotEmpty ? ' $lastName' : ''}'.trim();

      if (_name.isEmpty && firstName.isEmpty && lastName.isEmpty) {
        _name = 'User';
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        "user": _emailController.text.trim(),
        "photo": _photo,
        "first_name": _firstNameController.text.trim(),
        "middle_name": _middleNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "state": _stateController.text.trim(),
        "district": _districtController.text.trim(),
        "taluka": _talukaController.text.trim(),
        "village": _villageController.text.trim(),
        "address": _addressController.text.trim(),
        "landmark": _landmarkController.text.trim(),
        "pincode": _pincodeController.text.trim(),
        "contact": _mobileController.text.trim(),
        "alt_contact": _altContactController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'].isNotEmpty) {
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile', json.encode(data['data'][0]));

          // Update local variables
          _updateLocalVariables(data['data'][0]);

          if (mounted) {
            setState(() {
              _isEditing = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } else {
        throw Exception('Failed to update profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEditing() {
    // Reload original data
    _loadUserData().then((_) {
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
    });
  }

  void _refreshProfile() {
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _altContactController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: primaryBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No Profile Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Unable to load profile information',
            style: TextStyle(
              fontSize: 16,
              color: darkBlue.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'RETRY',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshProfile,
              tooltip: 'Refresh',
            ),
          if (!_isLoading && _name.isNotEmpty && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Profile',
            ),
          if (!_isLoading && _isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      )
          : _name.isEmpty && _mobile.isEmpty && _email.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryBlue,
                backgroundImage: _photo.isNotEmpty
                    ? NetworkImage(_photo)
                    : null,
                child: _photo.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                )
                    : null,
              ),
              const SizedBox(height: 10),

              // Name
              if (_name.isNotEmpty)
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                  textAlign: TextAlign.center,
                ),

              // Mobile
              if (_mobile.isNotEmpty)
                Text(
                  _mobile,
                  style: const TextStyle(
                    fontSize: 16,
                    color: darkBlue,
                  ),
                ),

              const SizedBox(height: 30),

              // Stats Card
              _buildStatsCard(),
              const SizedBox(height: 30),

              // Personal Information Section
              _buildSectionTitle('Personal Information'),

              // First Name
              _buildDetailField(
                label: 'First Name *',
                icon: Icons.person_outline,
                controller: _firstNameController,
                isEditing: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),

              // Middle Name
              _buildDetailField(
                label: 'Middle Name',
                icon: Icons.person_outline,
                controller: _middleNameController,
                isEditing: _isEditing,
              ),

              // Last Name
              _buildDetailField(
                label: 'Last Name',
                icon: Icons.person_outline,
                controller: _lastNameController,
                isEditing: _isEditing,
              ),

              // Email
              _buildDetailField(
                label: 'Email Address *',
                icon: Icons.email_outlined,
                controller: _emailController,
                isEditing: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              // Mobile
              _buildDetailField(
                label: 'Mobile Number *',
                icon: Icons.phone_android,
                controller: _mobileController,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (value.length != 10) {
                    return 'Enter 10 digit mobile number';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter numbers only';
                  }
                  return null;
                },
              ),

              // Alternate Contact
              _buildDetailField(
                label: 'Alternate Contact',
                icon: Icons.phone_outlined,
                controller: _altContactController,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 10) {
                      return 'Enter 10 digit mobile number';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Enter numbers only';
                    }
                  }
                  return null;
                },
              ),

              // Address Information Section
              _buildSectionTitle('Address Information'),

              // State
              _buildDetailField(
                label: 'State',
                icon: Icons.location_city_outlined,
                controller: _stateController,
                isEditing: _isEditing,
              ),

              // District
              _buildDetailField(
                label: 'District',
                icon: Icons.map_outlined,
                controller: _districtController,
                isEditing: _isEditing,
              ),

              // Taluka
              _buildDetailField(
                label: 'Taluka',
                icon: Icons.terrain_outlined,
                controller: _talukaController,
                isEditing: _isEditing,
              ),

              // Village
              _buildDetailField(
                label: 'Village',
                icon: Icons.holiday_village_outlined,
                controller: _villageController,
                isEditing: _isEditing,
              ),

              // Address
              _buildDetailField(
                label: 'Address',
                icon: Icons.home_outlined,
                controller: _addressController,
                isEditing: _isEditing,
                maxLines: 3,
              ),

              // Landmark
              _buildDetailField(
                label: 'Landmark',
                icon: Icons.place_outlined,
                controller: _landmarkController,
                isEditing: _isEditing,
              ),

              // Pincode
              _buildDetailField(
                label: 'Pincode *',
                icon: Icons.markunread_mailbox_outlined,
                controller: _pincodeController,
                isEditing: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pincode is required';
                  }
                  if (value.length != 6) {
                    return 'Enter 6 digit pincode';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter numbers only';
                  }
                  return null;
                },
              ),

              // Save/Cancel Buttons
              if (_isEditing)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _cancelEditing,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(color: primaryBlue),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: primaryBlue.withOpacity(0.5),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: primaryBlue.withOpacity(0.5),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField({
    required String label,
    required IconData icon,
    bool isEditing = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditing,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: textDark),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: darkBlue,
            fontWeight: label.contains('*') ? FontWeight.bold : FontWeight.normal,
          ),
          prefixIcon: Icon(icon, color: primaryBlue),
          filled: true,
          fillColor: lightSand,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 3,
      color: lightSand,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _StatItem(value: '₹ 0', label: 'Total Earned'),
            VerticalDivider(thickness: 1, color: darkBlue),
            _StatItem(value: '0', label: 'Total Pickups'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: darkBlue,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}