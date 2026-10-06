import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



import '../../core/theme/app_colors.dart';



class WorkerMenuDrawer extends StatefulWidget {

  final VoidCallback onClose;



  final VoidCallback? onProfile;

  final VoidCallback? onHome;

  final VoidCallback? onJobs;

  final VoidCallback? onEarnings;

  final VoidCallback? onHelp;

  final VoidCallback? onSettings;



  const WorkerMenuDrawer({

    super.key,

    required this.onClose,

    this.onProfile,

    this.onHome,

    this.onJobs,

    this.onEarnings,

    this.onHelp,

    this.onSettings,

  });



  @override

  State<WorkerMenuDrawer> createState() =>

      _WorkerMenuDrawerState();

}



class _WorkerMenuDrawerState extends State<WorkerMenuDrawer>

    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;

  String _workerName = 'Worker';



  @override

  void initState() {

    super.initState();



    _controller = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 280),

    );



    _slideAnimation = Tween<Offset>(

      begin: const Offset(-1.0, 0.0),

      end: Offset.zero,

    ).animate(

      CurvedAnimation(

        parent: _controller,

        curve: Curves.easeOutCubic,

      ),

    );



    _controller.forward();

    _loadWorkerName();

  }



  // =============================================================
  // LOAD REGISTERED WORKER NAME
  // =============================================================

  Future<void> _loadWorkerName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> workerDoc =
          await FirebaseFirestore.instance
              .collection('workers')
              .doc(user.uid)
              .get();

      if (!mounted || !workerDoc.exists) {
        return;
      }

      final Map<String, dynamic>? data = workerDoc.data();

      if (data == null) {
        return;
      }

      final dynamic registeredName =
          data['fullName'] ?? data['name'] ?? data['workerName'];

      if (registeredName is String && registeredName.trim().isNotEmpty) {
        setState(() {
          _workerName = registeredName.trim();
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load worker name: $e');
    }
  }

  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  Future<void> _closeDrawer() async {

    await _controller.reverse();



    if (mounted) {

      widget.onClose();

    }

  }



  @override

  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;



    // Drawer width

    final drawerWidth = screenWidth * 0.78;



    return Material(

      color: Colors.transparent,

      child: Stack(

        children: [

          // =====================================================

          // RIGHT SIDE DARK OVERLAY

          // =====================================================



          Positioned.fill(

            child: GestureDetector(

              onTap: _closeDrawer,

              child: Container(

                color: Colors.black.withOpacity(0.48),

              ),

            ),

          ),



          // =====================================================

          // DRAWER

          // =====================================================



          SlideTransition(

            position: _slideAnimation,

            child: Align(

              alignment: Alignment.centerLeft,

              child: SizedBox(

                width: drawerWidth,

                height: double.infinity,

                child: ClipRRect(

                  borderRadius: const BorderRadius.only(

                    topRight: Radius.circular(26),

                    bottomRight: Radius.circular(26),

                  ),

                  child: Container(

                    color: AppColors.white,

                    child: SafeArea(

                      right: false,

                      child: Column(

                        children: [

                          // =================================================

                          // TOP SECTION + MENU CONTENT

                          // =================================================



                          Expanded(

                            child: Stack(

                              children: [

                                // =================================================

                                // BOTTOM DECORATIVE WAVES

                                // =================================================



                                Positioned(

                                  left: 0,

                                  right: 0,

                                  bottom: 0,

                                  child: _buildBottomWave(),

                                ),



                                // =================================================

                                // MAIN CONTENT

                                // =================================================



                                SingleChildScrollView(

                                  physics:

                                      const BouncingScrollPhysics(),

                                  padding: const EdgeInsets.only(

                                    bottom: 150,

                                  ),

                                  child: Column(

                                    children: [

                                      // =================================================

                                      // HEADER + PROFILE

                                      // =================================================



                                      _buildTopHeader(),



                                      // =================================================

                                      // MY JOBS

                                      // =================================================



                                      _buildMenuItem(

                                        icon: Icons

                                            .business_center_rounded,

                                        title: 'My Jobs',

                                        subtitle:

                                            'Ongoing, completed and upcoming',

                                        onTap: widget.onJobs,

                                      ),



                                      // =================================================

                                      // EARNINGS

                                      // =================================================



                                      _buildMenuItem(

                                        icon: Icons

                                            .bar_chart_rounded,

                                        title: 'Earnings',

                                        subtitle:

                                            'View earnings and payout history',

                                        onTap: widget.onEarnings,

                                      ),



                                      // =================================================

                                      // DIVIDER

                                      // =================================================



                                      Padding(

                                        padding:

                                            const EdgeInsets.symmetric(

                                          horizontal: 18,

                                        ),

                                        child: Divider(

                                          height: 12,

                                          thickness: 1,

                                          color: AppColors.border,

                                        ),

                                      ),



                                      // =================================================

                                      // HELP & SUPPORT

                                      // =================================================



                                      _buildMenuItem(

                                        icon: Icons

                                            .headset_mic_rounded,

                                        title: 'Help & Support',

                                        subtitle:

                                            'Get help, report issues, FAQs',

                                        onTap: widget.onHelp,

                                      ),



                                      // =================================================

                                      // DIVIDER

                                      // =================================================



                                      Padding(

                                        padding:

                                            const EdgeInsets.symmetric(

                                          horizontal: 18,

                                        ),

                                        child: Divider(

                                          height: 12,

                                          thickness: 1,

                                          color: AppColors.border,

                                        ),

                                      ),



                                      // =================================================

                                      // SETTINGS

                                      // =================================================



                                      _buildMenuItem(

                                        icon:

                                            Icons.settings_rounded,

                                        title: 'Settings',

                                        subtitle:

                                            'App preferences and privacy',

                                        onTap: widget.onSettings,

                                      ),

                                    ],

                                  ),

                                ),

                              ],

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }



  // =============================================================

  // TOP HEADER + PROFILE

  // =============================================================



  Widget _buildTopHeader() {

    return Container(

      width: double.infinity,

      height: 285,

      decoration: const BoxDecoration(

        gradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            AppColors.header,

            AppColors.headerMiddle,

            AppColors.headerEnd,

          ],

        ),

        borderRadius: BorderRadius.only(

          bottomLeft: Radius.circular(0),

          bottomRight: Radius.circular(0),

        ),

      ),

      child: Stack(

        children: [

          // =========================================================

          // DECORATIVE CURVED SHAPE

          // =========================================================



          Positioned(

            right: -55,

            top: 55,

            child: Container(

              width: 210,

              height: 150,

              decoration: BoxDecoration(

                color: AppColors.primary.withOpacity(0.18),

                borderRadius: const BorderRadius.only(

                  topLeft: Radius.circular(140),

                  bottomLeft: Radius.circular(140),

                ),

              ),

            ),

          ),



          // =========================================================

          // CLOSE BUTTON

          // =========================================================



          Positioned(

            right: 14,

            top: 12,

            child: GestureDetector(

              onTap: _closeDrawer,

              child: Container(

                width: 48,

                height: 48,

                decoration: BoxDecoration(

                  color: AppColors.white.withOpacity(0.12),

                  shape: BoxShape.circle,

                  border: Border.all(

                    color: AppColors.white.withOpacity(0.08),

                    width: 1,

                  ),

                ),

                child: const Icon(

                  Icons.close_rounded,

                  color: AppColors.white,

                  size: 30,

                ),

              ),

            ),

          ),



          // =========================================================

          // PROFILE CARD

          // =========================================================



          Positioned(

            left: 0,

            right: 0,

            bottom: 0,

            child: _buildProfileCard(),

          ),

        ],

      ),

    );

  }



  // =============================================================

  // PROFILE CARD

  // =============================================================



  Widget _buildProfileCard() {

    return GestureDetector(

      onTap: widget.onProfile,

      child: Container(

        width: double.infinity,

        margin: const EdgeInsets.only(

          top: 0,

        ),

        padding: const EdgeInsets.fromLTRB(

          16,

          14,

          14,

          14,

        ),

        decoration: BoxDecoration(

          color: AppColors.lightMint,

          borderRadius: const BorderRadius.only(

            topLeft: Radius.circular(26),

            topRight: Radius.circular(26),

          ),

          border: Border.all(

            color: AppColors.white,

            width: 2.5,

          ),

          boxShadow: [

            BoxShadow(

              color: AppColors.shadow.withOpacity(0.18),

              blurRadius: 10,

              offset: const Offset(0, 4),

            ),

          ],

        ),

        child: Row(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // =======================================================

            // PROFILE PHOTO

            // =======================================================



            Container(

              width: 78,

              height: 78,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                color: AppColors.mapBackground,

                border: Border.all(

                  color: AppColors.white,

                  width: 3,

                ),

              ),

              child: const ClipOval(

                child: Icon(

                  Icons.person_rounded,

                  size: 49,

                  color: AppColors.primary,

                ),

              ),

            ),



            const SizedBox(width: 12),



            // =======================================================

            // PROFILE DETAILS
  // =======================================================

  Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _workerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 9),

        // ===================================================
        // ONLINE BADGE
        // ===================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.onlineToggle.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                color: AppColors.onlineToggle,
                size: 10,
              ),
              SizedBox(width: 5),
              Text(
                'Online',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),

  const SizedBox(width: 5),

  // PROFILE ARROW

            // =======================================================



            const Icon(

              Icons.chevron_right_rounded,

              color: AppColors.darkIcon,

              size: 29,

            ),

          ],

        ),

      ),

    );

  }



  // =============================================================

  // MENU ITEM

  // =============================================================



  Widget _buildMenuItem({

    required IconData icon,

    required String title,

    required String subtitle,

    VoidCallback? onTap,

  }) {

    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        child: Padding(

          padding: const EdgeInsets.symmetric(

            horizontal: 18,

            vertical: 9,

          ),

          child: Row(

            children: [

              // =====================================================

              // ICON CIRCLE

              // =====================================================



              Container(

                width: 56,

                height: 56,

                decoration: BoxDecoration(

                  color: AppColors.lightMint,

                  shape: BoxShape.circle,

                ),

                child: Icon(

                  icon,

                  color: AppColors.secondary,

                  size: 28,

                ),

              ),



              const SizedBox(width: 14),



              // =====================================================

              // TEXT

              // =====================================================



              Expanded(

                child: Column(

                  crossAxisAlignment:

                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      title,

                      maxLines: 1,

                      overflow:

                          TextOverflow.ellipsis,

                      style: const TextStyle(

                        color:

                            AppColors.textPrimary,

                        fontSize: 16,

                        fontWeight:

                            FontWeight.w800,

                      ),

                    ),



                    const SizedBox(height: 4),



                    Text(

                      subtitle,

                      maxLines: 2,

                      overflow:

                          TextOverflow.ellipsis,

                      style: const TextStyle(

                        color:

                            AppColors.textSecondary,

                        fontSize: 11,

                        fontWeight:

                            FontWeight.w500,

                      ),

                    ),

                  ],

                ),

              ),



              const SizedBox(width: 5),



              // =====================================================

              // ARROW

              // =====================================================



              const Icon(

                Icons.chevron_right_rounded,

                color: AppColors.darkIcon,

                size: 27,

              ),

            ],

          ),

        ),

      ),

    );

  }



  // =============================================================

  // BOTTOM WAVE

  // =============================================================



  Widget _buildBottomWave() {

    return SizedBox(

      height: 150,

      child: Stack(

        children: [

          // =======================================================

          // MAIN MINT WAVE

          // =======================================================



          Positioned(

            left: -50,

            right: -50,

            bottom: -55,

            child: Container(

              height: 145,

              decoration: BoxDecoration(

                color: AppColors.lightMint,

                borderRadius:

                    const BorderRadius.only(

                  topLeft:

                      Radius.elliptical(

                    180,

                    90,

                  ),

                  topRight:

                      Radius.elliptical(

                    180,

                    90,

                  ),

                ),

              ),

            ),

          ),



          // =======================================================

          // PRIMARY WAVE

          // =======================================================



          Positioned(

            left: -70,

            right: -70,

            bottom: -90,

            child: Container(

              height: 145,

              decoration: BoxDecoration(

                color: AppColors.primary

                    .withOpacity(0.28),

                borderRadius:

                    const BorderRadius.only(

                  topLeft:

                      Radius.elliptical(

                    220,

                    100,

                  ),

                  topRight:

                      Radius.elliptical(

                    220,

                    100,

                  ),

                ),

              ),

            ),

          ),



          // =======================================================

          // SLOGAN

          // =======================================================



          Positioned(

            left: 0,

            right: 0,

            top: 12,

            child: Column(

              children: [

                const Text(

                  'Skilled Hands',

                  textAlign:

                      TextAlign.center,

                  style: TextStyle(

                    color:

                        AppColors.secondary,

                    fontSize: 18,

                    fontWeight:

                        FontWeight.w700,

                    fontStyle:

                        FontStyle.italic,

                  ),

                ),



                const Text(

                  'Better Homes ♥',

                  textAlign:

                      TextAlign.center,

                  style: TextStyle(

                    color:

                        AppColors.secondary,

                    fontSize: 17,

                    fontWeight:

                        FontWeight.w700,

                    fontStyle:

                        FontStyle.italic,

                  ),

                ),



                const SizedBox(height: 3),



                Container(

                  width: 105,

                  height: 3,

                  decoration:

                      BoxDecoration(

                    color:

                        AppColors.secondary,

                    borderRadius:

                        BorderRadius.circular(

                      10,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}