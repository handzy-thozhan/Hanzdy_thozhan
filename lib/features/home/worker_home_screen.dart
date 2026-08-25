import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({
    super.key,
  });

  Future<
      DocumentSnapshot<
          Map<String, dynamic>>> _getWorkerData() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'User not found',
      );
    }

    return FirebaseFirestore.instance
        .collection('workers')
        .doc(user.uid)
        .get();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar:
          AppBar(
        backgroundColor:
            AppColors.background,

        foregroundColor:
            AppColors.textPrimary,

        elevation:
            0,

        title:
            const Text(
          'HANDZY THOZHAN',

          style:
              TextStyle(
            color:
                AppColors.textPrimary,

            fontSize:
                20,

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      body:
          FutureBuilder<
              DocumentSnapshot<
                  Map<String, dynamic>>>(
        future:
            _getWorkerData(),

        builder:
            (
          BuildContext context,
          AsyncSnapshot<
                  DocumentSnapshot<
                      Map<String, dynamic>>>
              snapshot,
        ) {
          // ====================================================
          // LOADING
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ====================================================
          // ERROR
          // ====================================================

          if (snapshot.hasError) {
            return const Center(
              child:
                  Text(
                'Unable to load your profile',
                style:
                    TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize:
                      18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            );
          }

          // ====================================================
          // NO DATA
          // ====================================================

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child:
                  Text(
                'Worker profile not found',
                style:
                    TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize:
                      18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            );
          }

          // ====================================================
          // WORKER DATA
          // ====================================================

          final Map<String, dynamic> data =
              snapshot.data!.data() ??
                  <String, dynamic>{};

          final String name =
              data['fullName']
                          ?.toString()
                          .trim()
                          .isNotEmpty ==
                      true
                  ? data['fullName']
                      .toString()
                  : 'Worker';

          final String? photoPath =
              data['profileImage']
                  ?.toString();

          // ====================================================
          // HOME
          // ====================================================

          return Center(
            child:
                Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                // ==================================================
                // PROFILE PHOTO
                // ==================================================

                Container(
                  width:
                      140,

                  height:
                      140,

                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,

                    border:
                        Border.all(
                      color:
                          AppColors.primary,

                      width:
                          3,
                    ),
                  ),

                  child:
                      ClipOval(
                    child:
                        photoPath != null &&
                                photoPath
                                    .isNotEmpty
                            ? Image.file(
                                File(
                                  photoPath,
                                ),

                                width:
                                    140,

                                height:
                                    140,

                                fit:
                                    BoxFit.cover,

                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Icon(
                                    Icons
                                        .person,
                                    size:
                                        70,
                                    color:
                                        AppColors
                                            .textSecondary,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                size:
                                    70,
                                color:
                                    AppColors
                                        .textSecondary,
                              ),
                  ),
                ),

                const SizedBox(
                  height:
                      20,
                ),

                // ==================================================
                // NAME
                // ==================================================

                Text(
                  'Welcome, $name',

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,

                    fontSize:
                        26,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                      8,
                ),

                const Text(
                  'Welcome to HANDZY THOZHAN',

                  textAlign:
                      TextAlign.center,

                  style:
                      TextStyle(
                    color:
                        AppColors.textSecondary,

                    fontSize:
                        16,

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}