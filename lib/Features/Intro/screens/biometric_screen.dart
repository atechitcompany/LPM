import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isLoading = false;

  Future<void> enableBiometric() async {
    try {
      setState(() => isLoading = true);

      final bool canAuthenticate =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        showMessage("Biometric not supported on this device");
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        showMessage("Authentication failed");
        return;
      }

      /// ✅ After success → Go Dashboard
      context.go('/dashboard');
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void skipBiometric() {
    context.go('/dashboard');
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 90, color: Colors.blue),

            const SizedBox(height: 30),

            const Text(
              "Enable Biometric Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              "Use fingerprint or face ID for faster and secure login.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 50),

            /// ✅ ENABLE BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : enableBiometric,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  "Enable Biometrics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff46000A),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ❌ SKIP BUTTON
            TextButton(
              onPressed: skipBiometric,
              child: const Text("Skip for now"),
            ),
          ],
        ),
      ),
    );
  }
}
