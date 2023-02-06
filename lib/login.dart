import 'package:fingerprint/controller/local_auth_api.dart';
import 'package:fingerprint/controller/secure_storage.dart';
import 'package:fingerprint/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fingerprint/main.dart';

late String email;
late String password;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Securestorage secureStorage = Securestorage();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool lock = true;
  bool? bioAuth;
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    if (sharedPreferences.getBool('enableBioAuth') == null) {
      sharedPreferences.setBool('enableBioAuth', false);
      bioAuth = sharedPreferences.getBool('enableBioAuth') as bool;
    }
    else {
      bioAuth = sharedPreferences.getBool('enableBioAuth');
    }
  }

  authenticate() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (emailController.text == 'test@user.com' &&
          passwordController.text == '12345') {
        Future.delayed(const Duration(seconds: 2));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication Successful')),
        );
        secureStorage.writeSecureData('email', emailController.text);
        secureStorage.writeSecureData('password', passwordController.text);
        setState(() {
          lock = false;
        });
        Get.off(() => const Home());
      } else {
        Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication Fail')),
        );
        setState(() {
          lock = true;
        });
      }
    } else {
      setState(() {
        lock = true;
      });
    }
  }

  biometricLogin() async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      secureStorage
          .readSecureData('email')
          .then((value) => emailController.text = value);
      secureStorage
          .readSecureData('password')
          .then((value) => passwordController.text = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 126, 137, 228),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                lock
                    ? Icon(Icons.lock_outline,
                        size: 75, color: Colors.blueGrey[900])
                    : Icon(Icons.lock_open,
                        size: 75, color: Colors.blueGrey[900]),
                const Text(
                  'Log In Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                Text(
                  'Please login to continue using our app',
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      // height: 1.5,
                      fontSize: 15),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  height: 260,
                  width: MediaQuery.of(context).size.width / 1.1,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20, top: 20),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 37, 58, 245),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Email",
                            hintText: 'your-email@domain.com',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 37, 58, 245)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: passwordController,
                            obscuringCharacter: '*',
                            obscureText: true,
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                color: Color.fromARGB(255, 37, 58, 245),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Password",
                              hintText: '*********',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 37, 58, 245)),
                            ),
                            validator: (value) {
                              if (value!.isEmpty && value.length < 5) {
                                return 'Enter a valid password';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: SizedBox(
                          height: 60,
                          width: Get.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  backgroundColor:
                                      const Color.fromARGB(255, 37, 58, 245)),
                              onPressed: authenticate,
                              child: const Text(
                                'Log In',
                                style: TextStyle(fontSize: 17),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                bioAuth! ? GestureDetector(
                  onTap: () {
                    biometricLogin();
                  },
                  child: Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Icon(
                          Icons.fingerprint_sharp,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
