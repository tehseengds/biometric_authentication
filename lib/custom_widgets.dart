import 'package:fingerprint/controller/secure_storage.dart';
import 'package:fingerprint/main.dart';
import 'package:flutter/material.dart';
import 'controller/local_auth_api.dart';

bool? enableBioAuth = sharedPreferences.getBool('enableBioAuth');

class AuthTile extends StatefulWidget {
  final String label;
  const AuthTile({super.key, required this.label});

  @override
  State<AuthTile> createState() => _AuthTileState();
}

class _AuthTileState extends State<AuthTile> {
  final Securestorage secureStorage = Securestorage();
  void toggleSwitch(bool value) async {
    if (enableBioAuth == false) {
      final isAuthenticated = await LocalAuthApi.authenticate();
      if (isAuthenticated) {
        setState(() {
          sharedPreferences.setBool('enableBioAuth', true);
          enableBioAuth = sharedPreferences.getBool('enableBioAuth');
        });
      }
    } else {
      setState(() {
        sharedPreferences.setBool('enableBioAuth', false);
        enableBioAuth = sharedPreferences.getBool('enableBioAuth');
        secureStorage.deleteSecureData('email');
        secureStorage.deleteSecureData('password');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 30),
      color: Colors.white.withOpacity(0.5),
      child: ListTile(
        leading: Icon(
          Icons.fingerprint_sharp,
          color: enableBioAuth! ? Colors.green : Colors.grey,
        ),
        title: Text('Login with ${widget.label}'),
        trailing: Switch.adaptive(
            activeColor: Colors.green,
            value: enableBioAuth!,
            onChanged: toggleSwitch),
      ),
    );
  }
}
