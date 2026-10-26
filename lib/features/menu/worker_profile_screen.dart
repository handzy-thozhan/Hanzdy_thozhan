import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState
    extends State<WorkerProfileScreen> {
  String _name = 'Worker';
  String _phone = '';
  String _email = '';
  String _gender = '';
  String _bloodGroup = '';
  String _address = '';
  String _skill = '';
  String _photoPath = '';
  String _workerId = '';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load existing signup details.
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      String name = prefs.getString('worker_name') ?? '';
      String phone = user?.phoneNumber ??
          prefs.getString('phone_number') ??
          '';
      String gender = prefs.getString('worker_gender') ?? '';
      String blood = prefs.getString('worker_blood_group') ?? '';
      String photo = prefs.getString('worker_profile_photo') ?? '';
      String email = user?.email ?? '';
      String address = '';
      String skill = '';

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('workers')
            .doc(user.uid)
            .get();

        final data = doc.data();

        if (data != null) {
          name = data['fullName']?.toString() ?? name;
          phone = data['phoneNumber']?.toString() ?? phone;
          email = data['email']?.toString() ?? email;
          gender = data['gender']?.toString() ?? gender;
          blood = data['bloodGroup']?.toString() ?? blood;
          address = data['address']?.toString() ?? '';
          skill = data['skill']?.toString() ??
              data['serviceType']?.toString() ??
              '';

          photo = data['profilePhoto']?.toString() ?? photo;
        }
      }

      if (!mounted) return;

      setState(() {
        _name = name.isEmpty ? 'Worker' : name;
        _phone = phone;
        _email = email;
        _gender = gender;
        _bloodGroup = blood;
        _address = address;
        _skill = skill;
        _photoPath = photo;
        _workerId = user == null
            ? ''
            : 'HTZ-${user.uid.substring(0, user.uid.length < 8 ? user.uid.length : 8).toUpperCase()}';
        _loading = false;
      });
    } catch (e) {
      debugPrint('Profile loading error: $e');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showHelp,
            icon: const Icon(Icons.headset_mic_rounded, size: 19),
            label: const Text('Help'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildStatistics(),
                  const SizedBox(height: 14),
                  _buildTagline(),
                  const SizedBox(height: 18),

                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    subtitle: 'View your registered details',
                    onTap: _showPersonalInformation,
                  ),
                  const SizedBox(height: 10),

                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Documents / KYC Verification',
                    subtitle: 'Identity and verification details',
                    onTap: _showKycInformation,
                  ),
                  const SizedBox(height: 22),

                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'ACCOUNT ACTIONS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  _buildAccountAction(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: _confirmLogout,
                  ),
                  const SizedBox(height: 10),

                  _buildAccountAction(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: _confirmDelete,
                  ),
                  const SizedBox(height: 16),

                  _buildSecurityNote(),
                ],
              ),
            ),
    );
  }

  // Profile photo, name, skill and availability.
  Widget _buildProfileHeader() {
    final hasPhoto = _photoPath.isNotEmpty &&
        File(_photoPath).existsSync();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 43,
                backgroundColor: AppColors.lightTeal,
                backgroundImage:
                    hasPhoto ? FileImage(File(_photoPath)) : null,
                child: hasPhoto
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_skill.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _skill,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Worker Account',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Statistics are not fabricated when backend values are unavailable.
  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.star_rounded,
              value: '—',
              label: 'Rating',
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.work_rounded,
              value: '—',
              label: 'Jobs Completed',
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_month_rounded,
              value: '—',
              label: 'Months with Handzy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.primary,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Skilled hands. Better homes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.lightTeal,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 29),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.textSecondary,
            size: 27,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data matters',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep your account information up to date.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Display only the information actually available.
  void _showPersonalInformation() {
    _showDetailsDialog(
      title: 'Personal Information',
      details: {
        'Full Name': _name,
        'Phone Number': _phone,
        'Email': _email,
        'Gender': _gender,
        'Blood Group': _bloodGroup,
        'Address': _address,
      },
    );
  }

  void _showKycInformation() {
    _showDetailsDialog(
      title: 'Documents / KYC Verification',
      details: {
        'Verification Status': 'Not available yet',
      },
    );
  }

  void _showDetailsDialog({
    required String title,
    required Map<String, String> details,
  }) {
    final available = details.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(title),
        content: available.isEmpty
            ? const Text('No saved information available.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: available.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Help & Support'),
        content: const Text(
          'Help and support contact details can be connected here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Logout?'),
        content: const Text('Do you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out. Please sign in again.'),
      ),
    );
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Account?'),
        content: const Text(
          'Account deletion is not connected yet. '
          'No account or data will be deleted by this button.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 25),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 55,
      color: AppColors.border,
    );
  }
}
