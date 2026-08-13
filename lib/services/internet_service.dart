import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class InternetService {
  // ============================================================
  // CHECK ACTUAL INTERNET
  //
  // connectivity_plus only checks whether Wi-Fi/mobile data
  // is connected.
  //
  // We also check an actual internet endpoint.
  // ============================================================

  static Future<bool> hasInternet() async {
    try {
      final List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();

      // No Wi-Fi / mobile network
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }

      // Check actual internet access
      final http.Response response = await http
          .get(
            Uri.parse(
              'https://www.google.com/generate_204',
            ),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      return response.statusCode == 204 ||
          response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // MONITOR INTERNET CONNECTION
  //
  // This can be used later if we need continuous monitoring.
  // ============================================================

  static Stream<bool> internetStatusStream() async* {
    final Connectivity connectivity =
        Connectivity();

    await for (final List<ConnectivityResult> results
        in connectivity.onConnectivityChanged) {
      if (results.contains(
        ConnectivityResult.none,
      )) {
        yield false;
        continue;
      }

      final bool connected =
          await hasInternet();

      yield connected;
    }
  }
}