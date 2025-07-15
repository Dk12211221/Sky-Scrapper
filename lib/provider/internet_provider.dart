import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer';

class Internetprovider extends ChangeNotifier {
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  Connectivity connectivity = Connectivity();

  Internetprovider() {
    initconnectivity();
  }

  Future<void> initconnectivity() async {
    List<ConnectivityResult> results = await connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      connectivityResult = ConnectivityResult.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      connectivityResult = ConnectivityResult.mobile;
    } else if (results.contains(ConnectivityResult.none)) {
      connectivityResult = ConnectivityResult.none;
    }

    notifyListeners();

    connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.wifi)) {
        connectivityResult = ConnectivityResult.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        connectivityResult = ConnectivityResult.mobile;
      } else if (results.contains(ConnectivityResult.none)) {
        connectivityResult = ConnectivityResult.none;
      }
    });
    notifyListeners();

    log("$connectivityResult");
  }
}
