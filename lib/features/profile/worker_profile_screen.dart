import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({
    super.key,
  });

  @override
  State<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState
    extends State<WorkerProfileScreen> {
  String _workerName = 'Worker';
  String _workerPhone = '';
  String _workerGender = '';
  String _workerBloodGroup = '';
  String _workerAge = '';
  String _workerId = 'HTZ-000001';

  bool _isOnline = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkerProfile();
  }

  // --------------------------------------------------
  // LOAD WORKER PROFILE
  // --------------------------------------------------

  Future<void> _loadWorkerProfile() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final User? user =
          FirebaseAuth.instance.currentUser;

      String name =
          prefs.getString('worker_name') ?? 'Worker';

      String gender =
          prefs.getString('worker_gender') ?? '';

      String bloodGroup =
          prefs.getString('worker_blood_group') ?? '';

      int? age =
          prefs.getInt('worker_age');

      String phone =
          user?.phoneNumber ?? '';

      if (user != null) {
        final DocumentSnapshot<
            Map<String, dynamic>> workerDoc =
            await FirebaseFirestore.instance
                .collection('workers')
                .doc(user.uid)
                .get();

        if (workerDoc.exists) {
          final data = workerDoc.data();

          if (data != null) {
            final String? firestoreName =
                data['fullName']?.toString();

            if (firestoreName != null &&
                firestoreName.trim().isNotEmpty) {
              name = firestoreName.trim();

              await prefs.setString(
                'worker_name',
                name,
              );
            }

            gender =
                data['gender']?.toString() ??
                    gender;

            bloodGroup =
                data['bloodGroup']?.toString() ??
                    bloodGroup;

            if (data['age'] != null) {
              age = int.tryParse(
                data['age'].toString(),
              );
            }

            phone =
                data['phoneNumber']?.toString() ??
                    phone;
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _workerName = name;
        _workerGender = gender;
        _workerBloodGroup = bloodGroup;
        _workerAge =
            age?.toString() ?? '';
        _workerPhone = phone;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        '❌ Failed to load worker profile: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child:
                        _buildProfileContent(),
                  ),
                ],
              ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 82,
      width: double.infinity,
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.headerMiddle,
            AppColors.headerEnd,
          ],
        ),
        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(28),
          bottomRight:
              Radius.circular(28),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            _buildHeaderButton(
              icon:
                  Icons.arrow_back_rounded,
              onTap: () {
                Navigator.of(
                  context,
                ).pop();
              },
            ),

            const SizedBox(
              width: 14,
            ),

            const Expanded(
              child: Text(
                'My Profile',
                style:
                    TextStyle(
                  color:
                      AppColors.white,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            _buildHeaderButton(
              icon:
                  Icons.help_outline_rounded,
              onTap: _showHelp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        width: 46,
        height: 46,
        decoration:
            BoxDecoration(
          color: AppColors.white
              .withValues(
            alpha: 0.12,
          ),
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color:
              AppColors.white,
          size: 25,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PROFILE CONTENT
  // --------------------------------------------------

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        30,
      ),
      child: Column(
        children: [
          _buildProfileCard(),

          const SizedBox(
            height: 18,
          ),

          _buildInformationCard(),

          const SizedBox(
            height: 14,
          ),

          _buildMenuCard(
            icon:
                Icons.badge_rounded,
            title:
                'Handzy Thozhan ID',
            subtitle:
                _workerId,
            onTap:
                _showWorkerId,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildMenuCard(
            icon:
                Icons.handyman_rounded,
            title:
                'My Skills',
            subtitle:
                'View your registered skills',
            onTap:
                _showSkills,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildMenuCard(
            icon:
                Icons.language_rounded,
            title:
                'Language Settings',
            subtitle:
                'Choose your preferred language',
            onTap:
                _showLanguageSettings,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildMenuCard(
            icon:
                Icons.help_outline_rounded,
            title:
                'Help',
            subtitle:
                'Get help and support',
            onTap:
                _showHelp,
          ),

          const SizedBox(
            height: 24,
          ),

          _buildDeleteAccountButton(),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // PROFILE CARD
  // --------------------------------------------------

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color:
            AppColors.card,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color:
              AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow
                .withValues(
              alpha: 0.18,
            ),
            blurRadius: 14,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // PROFILE PHOTO
          Container(
            width: 94,
            height: 94,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              color:
                  AppColors.lightMint,
              border: Border.all(
                color:
                    AppColors.primary,
                width: 2,
              ),
            ),
            child:
                const Icon(
              Icons.person_rounded,
              color:
                  AppColors.primary,
              size: 55,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            _workerName,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _buildOnlineBadge(),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _buildStat(
                  icon:
                      Icons.star_rounded,
                  value:
                      '0.0',
                  label:
                      'Rating',
                ),
              ),

              Container(
                width: 1,
                height: 40,
                color:
                    AppColors.border,
              ),

              Expanded(
                child:
                    _buildStat(
                  icon: Icons
                      .receipt_long_rounded,
                  value:
                      '0',
                  label:
                      'Orders',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ONLINE BADGE
  // --------------------------------------------------

  Widget _buildOnlineBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: AppColors
            .onlineToggle
            .withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color:
                AppColors.onlineToggle,
            size: 9,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            _isOnline
                ? 'Online'
                : 'Offline',
            style:
                const TextStyle(
              color:
                  AppColors.success,
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STAT
  // --------------------------------------------------

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              AppColors.primary,
          size: 25,
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
              const TextStyle(
            color:
                AppColors.textPrimary,
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          label,
          style:
              const TextStyle(
            color:
                AppColors.textSecondary,
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // PROFILE INFORMATION
  // --------------------------------------------------

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            AppColors.card,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon:
                Icons.person_outline_rounded,
            title:
                'Profile Information',
            subtitle:
                'View your registered details',
          ),

          const SizedBox(
            height: 14,
          ),

          _buildDetailRow(
            'Gender',
            _workerGender.isEmpty
                ? 'Not available'
                : _workerGender,
          ),

          const SizedBox(
            height: 8,
          ),

          _buildDetailRow(
            'Blood Group',
            _workerBloodGroup.isEmpty
                ? 'Not available'
                : _workerBloodGroup,
          ),

          const SizedBox(
            height: 8,
          ),

          _buildDetailRow(
            'Age',
            _workerAge.isEmpty
                ? 'Not available'
                : '$_workerAge years',
          ),

          if (_workerPhone.isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),
            _buildDetailRow(
              'Phone',
              _workerPhone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration:
              BoxDecoration(
            color:
                AppColors.lightMint,
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                AppColors.primary,
            size: 25,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color: AppColors
                      .textPrimary,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                subtitle,
                style:
                    const TextStyle(
                  color: AppColors
                      .textSecondary,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              color: AppColors
                  .textSecondary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,
          style:
              const TextStyle(
            color:
                AppColors.textPrimary,
            fontSize: 12,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // MENU CARD
  // --------------------------------------------------

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(15),
          decoration:
              BoxDecoration(
            color:
                AppColors.card,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.lightMint,
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color: AppColors
                            .textPrimary,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    AppColors.darkIcon,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // DELETE ACCOUNT
  // --------------------------------------------------

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
            _confirmDeleteAccount,
        icon: const Icon(
          Icons
              .delete_outline_rounded,
          color:
              Colors.redAccent,
        ),
        label: const Text(
          'Delete Account',
          style:
              TextStyle(
            color:
                Colors.redAccent,
            fontSize: 14,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          side:
              const BorderSide(
            color:
                Colors.redAccent,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HANDZY THOZHAN ID
  // --------------------------------------------------

  void _showWorkerId() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Handzy Thozhan ID',
          ),
          content: Text(
            _workerId,
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.primary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // SKILLS
  // --------------------------------------------------

  void _showSkills() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('My Skills'),
          content:
              const Text(
            'Your registered skills will appear here.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // LANGUAGE SETTINGS
  // --------------------------------------------------

  void _showLanguageSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          AppColors.card,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Language Settings',
                  style:
                      TextStyle(
                    color: AppColors
                        .textPrimary,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _buildLanguageOption(
                  'English',
                ),

                _buildLanguageOption(
                  'Tamil',
                ),

                _buildLanguageOption(
                  'தமிழ்',
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String language,
  ) {
    return ListTile(
      leading: const Icon(
        Icons.language_rounded,
        color:
            AppColors.primary,
      ),
      title: Text(
        language,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w700,
        ),
      ),
      onTap: () {
        Navigator.pop(
          context,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '$language selected',
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // HELP
  // --------------------------------------------------

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Help'),
          content:
              const Text(
            'Need help with your Handzy Thozhan account? Support options will be available here.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // DELETE ACCOUNT CONFIRMATION
  // --------------------------------------------------

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account?',
          ),
          content: const Text(
            'Are you sure you want to delete your Handzy Thozhan account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );

                _showDeleteComingSoon();
              },
              child: const Text(
                'Delete',
                style:
                    TextStyle(
                  color:
                      Colors.redAccent,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Account deletion will be connected later.',
        ),
      ),
    );
  }
}