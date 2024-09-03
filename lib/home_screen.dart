import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildUI(),
      floatingActionButton: floatingButtonUI(),
    );
  }

  Widget buildUI() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Account Balance",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          if (isAuthenticated)
            const Text(
              "1,00,00,000",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            )
          else
            const Text(
              "*******",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget floatingButtonUI() {
    return FloatingActionButton(
      onPressed: () async {
        if (!isAuthenticated) {
          bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
          bool didAuthenticate = false;
          try {
            if (canAuthenticateWithBiometrics) {
              // Attempt biometric authentication
              didAuthenticate = await auth.authenticate(
                localizedReason: "Please authenticate to show balance",
                options: const AuthenticationOptions(
                  biometricOnly: true,
                ),
              );
            }
            if (!didAuthenticate) {
              // Fall back to device's PIN, pattern, or password
              didAuthenticate = await auth.authenticate(
                localizedReason: "Please authenticate to show balance",
                options: const AuthenticationOptions(
                  biometricOnly: false,
                ),
              );
            }
            setState(() {
              isAuthenticated = didAuthenticate;
            });
          } on PlatformException catch (e) {
            print("Device authentication error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.code == "NotAvailable"
                      ? "Security credentials not available. Please set up a PIN, pattern, or password."
                      : "Authentication error: $e",
                ),
              ),
            );
          } catch (e) {
            print("Authentication error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Authentication failed. Please try again."),
              ),
            );
          }
        } else {
          setState(() {
            isAuthenticated = false;
          });
        }
      },
      child: isAuthenticated
          ? const Icon(Icons.lock_open)
          : const Icon(Icons.lock),
    );
  }
}
