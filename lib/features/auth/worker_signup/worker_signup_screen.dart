import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // --- UI THEME COLORS ---
  static const Color primaryTeal = Color(0xFF009F88);
  static const Color darkText = Color(0xFF132F38);
  static const Color subText = Color(0xFF718792);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE5ECEF);
  static const Color lightTealBg = Color(0xFFE8F8F5);
  static const Color requiredRed = Color(0xFFE53935);

  // --- CONTROLLERS & SERVICES ---
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // --- FORM STATE ---
  File? _profileImage;
  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _termsAccepted = false;
  bool _isLoading = false;

  final List<String> _bloodGroups = const [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- PHOTO SAVE LOCALLY ---
  Future<String?> _saveProfilePhotoLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'worker_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await imageFile.copy('${directory.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('worker_profile_photo', savedFile.path);
      return savedFile.path;
    } catch (e) {
      debugPrint('Local photo save error: $e');
      return null;
    }
  }

  // --- CAMERA DIRECT CAPTURE ---
  Future<void> _takeProfilePhoto() async {
    try {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) _showMessage('Camera permission is required.', isError: true);
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        if (mounted) _showCameraSettingsDialog();
        return;
      }

      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedImage == null) return;

      final File imageFile = File(pickedImage.path);
      final String? savedPath = await _saveProfilePhotoLocally(imageFile);

      if (savedPath != null && mounted) {
        setState(() => _profileImage = File(savedPath));
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
      if (mounted) _showMessage('Unable to open camera.', isError: true);
    }
  }

  void _showCameraSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Camera access is disabled. Please enable it in Settings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET BLOOD GROUP ---
  Future<void> _selectBloodGroup() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(height: 10),
                const Text('Select Blood Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: darkText)),
                const SizedBox(height: 8),
                ..._bloodGroups.map((group) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.water_drop_outlined, color: primaryTeal, size: 20),
                  title: Text(group, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: _selectedBloodGroup == group ? const Icon(Icons.check_circle, color: primaryTeal, size: 20) : null,
                  onTap: () => Navigator.pop(context, group),
                )),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() => _selectedBloodGroup = result);
    }
  }

  // --- DATE OF BIRTH & 18+ VALIDATION ---
  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime maxAllowedDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime initial = _selectedDateOfBirth ?? maxAllowedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: maxAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryTeal)),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  int _calculateAge(DateTime dob) {
    final DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // --- SUBMIT REGISTRATION ---
  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please enter your full name.', isError: true);
      return;
    }
    if (_selectedBloodGroup == null) {
      _showMessage('Please select your blood group.', isError: true);
      return;
    }
    if (_selectedDateOfBirth == null) {
      _showMessage('Please select your date of birth.', isError: true);
      return;
    }
    final int age = _calculateAge(_selectedDateOfBirth!);
    if (age < 18) {
      _showMessage('You must be 18+ to register.', isError: true);
      return;
    }
    if (_selectedGender == null) {
      _showMessage('Please select your gender.', isError: true);
      return;
    }
    if (!_termsAccepted) {
      _showMessage('Please accept terms & conditions.', isError: true);
      return;
    }

    final User? user = _auth.currentUser;
    if (user == null) {
      _showMessage('Session expired. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = user.uid;
      String? localPhotoPath;

      if (_profileImage != null) {
        localPhotoPath = await _saveProfilePhotoLocally(_profileImage!);
      }

      await _firestore.collection('workers').doc(uid).set(
        {
          'uid': uid,
          'phoneNumber': user.phoneNumber ?? widget.phoneNumber,
          'fullName': _nameController.text.trim(),
          'bloodGroup': _selectedBloodGroup,
          'gender': _selectedGender,
          'dateOfBirth': Timestamp.fromDate(_selectedDateOfBirth!),
          'age': age,
          'profilePhotoPath': localPhotoPath,
          'profilePhotoStoredLocally': localPhotoPath != null,
          'profileCompleted': true,
          'isWorker': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('worker_name', _nameController.text.trim());
      await prefs.setString('worker_blood_group', _selectedBloodGroup!);
      await prefs.setString('worker_gender', _selectedGender!);
      await prefs.setInt('worker_age', age);
      await prefs.setBool('worker_profile_completed', true);
      if (localPhotoPath != null) {
        await prefs.setString('worker_profile_photo', localPhotoPath);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      debugPrint('Worker Signup Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Registration failed. Please try again.', isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFD),
      // ---------------------------------------------------------------
      // FIX: page-fit issue. Body is a Column with two parts:
      // 1) Expanded + SingleChildScrollView -> the form scrolls if it's
      //    taller than the screen (small devices / keyboard open).
      // 2) A fixed footer (terms, CTA, badges) pinned to the bottom of
      //    the screen at all times, right below the form - no big gap.
      // ---------------------------------------------------------------
      body: SafeArea(
        child: Column(
          children: [
            // ---------- SCROLLABLE FORM (takes all available space) ----------
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                          // Top Brand
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: lightTealBg, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.handyman_rounded, color: primaryTeal, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Handzy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: darkText)),
                                  Text('Your Service Partner', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: subText)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Title
                          RichText(
                            text: const TextSpan(
                              text: "Let's get to ",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkText),
                              children: [TextSpan(text: 'know you!', style: TextStyle(color: primaryTeal))],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Profile Avatar
                          GestureDetector(
                            onTap: _takeProfilePhoto,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 78,
                                  height: 78,
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFB4E3DC), width: 1.5),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xFFD8F2ED),
                                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                                    child: _profileImage == null
                                        ? const Icon(Icons.person, size: 44, color: Color(0xFF83BDB4))
                                        : null,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: primaryTeal,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Full Name Card
                          _buildFormCard(
                            icon: Icons.person,
                            iconColor: primaryTeal,
                            label: 'Full Name',
                            child: SizedBox(
                              height: 42,
                              child: TextField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: darkText, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(color: Color(0xFF8C9CA6), fontSize: 13, fontWeight: FontWeight.w400),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: borderColor)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: primaryTeal)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 2-Column Row (Blood Group + DOB)
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormCard(
                                  icon: Icons.water_drop_outlined,
                                  iconColor: requiredRed,
                                  label: 'Blood Group',
                                  showRequiredTag: false,
                                  child: GestureDetector(
                                    onTap: _selectBloodGroup,
                                    child: Container(
                                      height: 42,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedBloodGroup ?? 'Blood',
                                            style: TextStyle(
                                              color: _selectedBloodGroup == null ? const Color(0xFF8C9CA6) : darkText,
                                              fontSize: 13,
                                              fontWeight: _selectedBloodGroup == null ? FontWeight.w400 : FontWeight.w600,
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8C9CA6), size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildFormCard(
                                  icon: Icons.calendar_today_outlined,
                                  iconColor: primaryTeal,
                                  label: 'DOB (18+)',
                                  showRequiredTag: false,
                                  child: GestureDetector(
                                    onTap: _selectDateOfBirth,
                                    child: Container(
                                      height: 42,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _selectedDateOfBirth == null ? 'Date' : _formatDate(_selectedDateOfBirth!),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: _selectedDateOfBirth == null ? const Color(0xFF8C9CA6) : darkText,
                                                fontSize: 13,
                                                fontWeight: _selectedDateOfBirth == null ? FontWeight.w400 : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.calendar_month_outlined, color: Color(0xFF8C9CA6), size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Gender Card
                          _buildFormCard(
                            label: 'Gender',
                            child: Row(
                              children: [
                                _genderOption(value: 'Male', label: 'Male', icon: Icons.male),
                                const SizedBox(width: 6),
                                _genderOption(value: 'Female', label: 'Female', icon: Icons.female),
                                const SizedBox(width: 6),
                                _genderOption(value: 'Other', label: 'Other', icon: Icons.transgender),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),

            // ---------- FIXED FOOTER (always pinned to bottom, doesn't scroll away) ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Terms
                          GestureDetector(
                            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: lightTealBg, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _termsAccepted ? primaryTeal : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: primaryTeal, width: 1.2),
                                    ),
                                    child: _termsAccepted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: const TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: darkText, fontSize: 11.5, fontWeight: FontWeight.w500),
                                      children: [TextSpan(text: 'Terms & Privacy Policy', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w700))],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Create Account CTA
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                        SizedBox(width: 6),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 17),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Trust Badges
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                _footerBadge(icon: Icons.verified_user, bgColor: const Color(0xFFE5F8F2), iconColor: const Color(0xFF00B074), title: 'Trusted', subtitle: 'Verified workers'),
                                Container(height: 22, width: 1, color: borderColor),
                                _footerBadge(icon: Icons.lock, bgColor: const Color(0xFFEBF1FF), iconColor: const Color(0xFF2F66F6), title: 'Safe', subtitle: 'Safety first'),
                                Container(height: 22, width: 1, color: borderColor),
                                _footerBadge(icon: Icons.bolt, bgColor: const Color(0xFFFFF6E6), iconColor: const Color(0xFFFFA927), title: 'Fast', subtitle: 'Quick service'),
                              ],
                            ),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    IconData? icon,
    Color? iconColor,
    String? label,
    bool showRequiredTag = true,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 14, color: iconColor ?? primaryTeal), const SizedBox(width: 4)],
              Text(label ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: darkText)),
              const SizedBox(width: 2),
              const Text('*', style: TextStyle(color: requiredRed, fontWeight: FontWeight.bold, fontSize: 12)),
              if (showRequiredTag) ...[
                const Spacer(),
                const Text('Required', style: TextStyle(color: Color(0xFF8C9CA6), fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _genderOption({required String value, required String label, required IconData icon}) {
    final bool isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? lightTealBg : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? primaryTeal : borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? primaryTeal : const Color(0xFF8C9CA6), width: 1.2),
                ),
                child: isSelected
                    ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle)))
                    : null,
              ),
              const SizedBox(width: 3),
              Icon(icon, size: 13, color: isSelected ? primaryTeal : const Color(0xFF8C9CA6)),
              const SizedBox(width: 2),
              Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: darkText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBadge({required IconData icon, required Color bgColor, required Color iconColor, required String title, required String subtitle}) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(radius: 12, backgroundColor: bgColor, child: Icon(icon, size: 12, color: iconColor)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: darkText)),
          Text(subtitle, style: const TextStyle(fontSize: 8.5, color: subText, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}