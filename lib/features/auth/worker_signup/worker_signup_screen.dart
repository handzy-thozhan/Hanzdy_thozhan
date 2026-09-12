import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/worker_home_screen.dart';

class WorkerSignupScreen extends StatefulWidget {
  final String? userId;
  final String? phoneNumber;

  const WorkerSignupScreen({
    super.key,
    this.userId,
    this.phoneNumber,
  });

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  // ---------------------------------------------------------------------------
  // UI THEME COLORS
  // ---------------------------------------------------------------------------

  static const Color primaryTeal = Color(0xFF009F88);
  static const Color darkText = Color(0xFF132F38);
  static const Color subText = Color(0xFF718792);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE5ECEF);
  static const Color lightTealBg = Color(0xFFE8F8F5);
  static const Color requiredRed = Color(0xFFE53935);

  // ---------------------------------------------------------------------------
  // CONTROLLERS & SERVICES
  // ---------------------------------------------------------------------------

  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // ---------------------------------------------------------------------------
  // FORM STATE
  // ---------------------------------------------------------------------------

  File? _profileImage;
  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _termsAccepted = false;
  bool _isLoading = false;

  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PHOTO SAVE LOCALLY
  // ---------------------------------------------------------------------------

  Future<String?> _saveProfilePhotoLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final fileName =
          'worker_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final savedFile = await imageFile.copy(
        '${directory.path}/$fileName',
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'worker_profile_photo',
        savedFile.path,
      );

      return savedFile.path;
    } catch (e) {
      debugPrint('Local photo save error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // CAMERA DIRECT CAPTURE
  // ---------------------------------------------------------------------------

  Future<void> _takeProfilePhoto() async {
    try {
      final status = await Permission.camera.status;

      if (status.isDenied) {
        final result = await Permission.camera.request();

        if (!result.isGranted) {
          if (mounted) {
            _showMessage(
              'Camera permission is required.',
              isError: true,
            );
          }
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showCameraSettingsDialog();
        }
        return;
      }

      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedImage == null) {
        return;
      }

      final File imageFile = File(pickedImage.path);

      final String? savedPath =
          await _saveProfilePhotoLocally(imageFile);

      if (savedPath != null && mounted) {
        setState(() {
          _profileImage = File(savedPath);
        });
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');

      if (mounted) {
        _showMessage(
          'Unable to open camera.',
          isError: true,
        );
      }
    }
  }

  void _showCameraSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Camera Permission',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Camera access is disabled. Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BLOOD GROUP
  // ---------------------------------------------------------------------------

  Future<void> _selectBloodGroup() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Select Blood Group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                ..._bloodGroups.map(
                  (group) => ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.water_drop_outlined,
                      color: primaryTeal,
                      size: 20,
                    ),
                    title: Text(
                      group,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: _selectedBloodGroup == group
                        ? const Icon(
                            Icons.check_circle,
                            color: primaryTeal,
                            size: 20,
                          )
                        : null,
                    onTap: () => Navigator.pop(
                      context,
                      group,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedBloodGroup = result;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DATE OF BIRTH & 18+ VALIDATION
  // ---------------------------------------------------------------------------

  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();

    final DateTime maxAllowedDate = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    final DateTime initial =
        _selectedDateOfBirth ?? maxAllowedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: maxAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final DateTime today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ---------------------------------------------------------------------------
  // CREATE ACCOUNT
  // ---------------------------------------------------------------------------

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.trim().isEmpty) {
      _showMessage(
        'Please enter your full name.',
        isError: true,
      );
      return;
    }

    if (_selectedBloodGroup == null) {
      _showMessage(
        'Please select your blood group.',
        isError: true,
      );
      return;
    }

    if (_selectedDateOfBirth == null) {
      _showMessage(
        'Please select your date of birth.',
        isError: true,
      );
      return;
    }

    final int age = _calculateAge(
      _selectedDateOfBirth!,
    );

    if (age < 18) {
      _showMessage(
        'You must be 18+ to register.',
        isError: true,
      );
      return;
    }

    if (_selectedGender == null) {
      _showMessage(
        'Please select your gender.',
        isError: true,
      );
      return;
    }

    if (!_termsAccepted) {
      _showMessage(
        'Please accept terms & conditions.',
        isError: true,
      );
      return;
    }

    final User? user = _auth.currentUser;

    if (user == null) {
      _showMessage(
        'Session expired. Please login again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String uid = user.uid;

      String? localPhotoPath;

      if (_profileImage != null) {
        localPhotoPath =
            await _saveProfilePhotoLocally(
          _profileImage!,
        );
      }

      await _firestore
          .collection('workers')
          .doc(uid)
          .set(
        {
          'uid': uid,
          'phoneNumber':
              user.phoneNumber ?? widget.phoneNumber,
          'fullName':
              _nameController.text.trim(),
          'bloodGroup':
              _selectedBloodGroup,
          'gender':
              _selectedGender,
          'dateOfBirth':
              Timestamp.fromDate(
            _selectedDateOfBirth!,
          ),
          'age': age,
          'profilePhotoPath':
              localPhotoPath,
          'profilePhotoStoredLocally':
              localPhotoPath != null,
          'profileCompleted':
              true,
          'isWorker':
              true,
          'createdAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'worker_name',
        _nameController.text.trim(),
      );

      await prefs.setString(
        'worker_blood_group',
        _selectedBloodGroup!,
      );

      await prefs.setString(
        'worker_gender',
        _selectedGender!,
      );

      await prefs.setInt(
        'worker_age',
        age,
      );

      await prefs.setBool(
        'worker_profile_completed',
        true,
      );
       
        await prefs.setBool(
           'user_registered',
          true,
      );

      if (localPhotoPath != null) {
        await prefs.setString(
          'worker_profile_photo',
          localPhotoPath,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Worker Signup Error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Registration failed. Please try again.',
        isError: true,
      );

      // Save/Firestore step itself failed — stop here, do not navigate.
      return;
    }

    // -------------------------------------------------------------------
    // NAVIGATION — kept OUTSIDE the save try/catch above on purpose.
    // Data is already saved successfully at this point, so a routing
    // issue must never be shown to the user as "Registration failed".
    // -------------------------------------------------------------------
    if (!mounted) {
      return;
    }

    try {
      // Direct widget navigation to the real WorkerHomeScreen — does NOT
      // depend on named routes being registered in MaterialApp.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const WorkerHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Navigation to Home failed after successful signup: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Account created! Please restart the app to continue.',
        isError: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  void _showMessage(
    String msg, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor:
            isError ? Colors.redAccent : primaryTeal,
        behavior:
            SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeadline(),
                    const SizedBox(height: 22),
                    _buildProfileAvatar(),
                    const SizedBox(height: 28),
                    _buildFullNameCard(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBloodGroupCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDobCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGenderCard(),
                    const SizedBox(height: 16),
                    _buildTermsRow(),
                    const SizedBox(height: 22),
                    _buildCreateAccountButton(),
                    const SizedBox(height: 20),
                    _buildClosingTagline(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: darkText,
        ),
        children: [
          TextSpan(text: "Let's get to "),
          TextSpan(
            text: 'know you!',
            style: TextStyle(color: primaryTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _takeProfilePhoto,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB4E3DC),
                  width: 1.6,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFD8F2ED),
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 54,
                        color: Color(0xFF83BDB4),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel({
    IconData? icon,
    Color? iconColor,
    required String label,
    bool showRequiredTag = true,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor ?? primaryTeal),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: darkText,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: requiredRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (showRequiredTag)
          const Text(
            'Required',
            style: TextStyle(
              color: Color(0xFF8C9CA6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildFullNameCard() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel(icon: Icons.person, label: 'Full Name'),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: darkText,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: const TextStyle(
                color: Color(0xFF8C9CA6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryTeal, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupCard() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel(
            icon: Icons.water_drop_outlined,
            iconColor: requiredRed,
            label: 'Blood Group',
            showRequiredTag: false,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectBloodGroup,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedBloodGroup ?? 'Blood',
                    style: TextStyle(
                      color: _selectedBloodGroup == null
                          ? const Color(0xFF8C9CA6)
                          : darkText,
                      fontSize: 14,
                      fontWeight: _selectedBloodGroup == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF8C9CA6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDobCard() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel(
            icon: Icons.calendar_today_outlined,
            label: 'DOB (18+)',
            showRequiredTag: false,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDateOfBirth,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _selectedDateOfBirth == null
                          ? 'Date'
                          : _formatDate(_selectedDateOfBirth!),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _selectedDateOfBirth == null
                            ? const Color(0xFF8C9CA6)
                            : darkText,
                        fontSize: 14,
                        fontWeight: _selectedDateOfBirth == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF8C9CA6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel(label: 'Gender'),
          const SizedBox(height: 12),
          Row(
            children: [
              _genderOption(value: 'Male', label: 'Male', icon: Icons.male),
              const SizedBox(width: 8),
              _genderOption(
                  value: 'Female', label: 'Female', icon: Icons.female),
              const SizedBox(width: 8),
              _genderOption(
                  value: 'Other', label: 'Other', icon: Icons.transgender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? lightTealBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryTeal : borderColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 18,
                color: isSelected ? primaryTeal : const Color(0xFF8C9CA6),
              ),
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryTeal : const Color(0xFF8C9CA6),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _termsAccepted = !_termsAccepted;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: lightTealBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _termsAccepted ? primaryTeal : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: primaryTeal, width: 1.4),
              ),
              child: _termsAccepted
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms & Privacy Policy',
                      style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildClosingTagline() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Join Handzy and grow with your trusted service community.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: subText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}