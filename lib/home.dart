import 'dart:io';

import 'package:fingerprint/controller/secure_storage.dart';
import 'package:fingerprint/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'controller/local_auth_api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Securestorage secureStorage = Securestorage();
  String get switchLabel => Platform.isIOS ? 'Face Id' : 'Touch Id';
  late bool isAvailable;
  late bool hasFingerprint;
  late bool hasFaceId;

  checkAvablity() async {
    isAvailable = await LocalAuthApi.hasBiometrics();
    final biometrics = await LocalAuthApi.getBiometrics();

    hasFingerprint = biometrics.contains(BiometricType.fingerprint);
    hasFaceId = biometrics.contains(BiometricType.face);
  }


  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color.fromARGB(255, 37, 58, 245),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 37, 58, 245),
          title: const Text("Two Step Verification"),
          centerTitle: true,
        ),
        body: Container(
          margin: const EdgeInsets.only(
            top: 13,
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello,",
                  style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.8)),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  "let us know it's you by one click authentication",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.withOpacity(0.8)),
                ),
                FutureBuilder(
                    future: checkAvablity(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.green,
                            strokeWidth: 2,
                          ),
                        );
                      } else {
                        return Center(
                            child: isAvailable
                                ? AuthTile(label: switchLabel)
                                : const SizedBox());
                      }
                    })
              ],
            ),
          ),
        ),
      );
}
