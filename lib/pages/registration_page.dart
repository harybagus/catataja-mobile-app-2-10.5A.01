import 'dart:convert';
import 'package:catataja/pages/login_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

import 'package:catataja/components/catataja_button.dart';
import 'package:catataja/components/catataja_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';

class RegistrationPage extends StatefulWidget {
  final void Function()? onPressed;

  const RegistrationPage({super.key, required this.onPressed});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // is visible
  bool passwordIsVisisble = true;
  bool confirmPasswordIsVisisble = true;

  // URL endpoint API
  final String registerUrl = "http://10.0.2.2:8000/api/users";

  // registration
  Future<void> registerUser() async {
    // input validaiton
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registrasi Gagal",
        text: "Nama, email, password, dan konfirmasi password harus diisi.",
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }

    // name validaiton
    if (nameController.text.length < 3) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registrasi Gagal",
        text: "Nama minimal harus terdiri dari 3 karakter.",
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }

    // email validaiton
    if (!EmailValidator.validate(emailController.text)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registrasi Gagal",
        text: "Email tidak valid.",
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }

    // password validaiton
    if (passwordController.text.length < 6) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registrasi Gagal",
        text: "Password minimal harus terdiri dari 6 karakter.",
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );
      return;
    }

    // password & confirm password validaiton
    if (passwordController.text != confirmPasswordController.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registrasi Gagal",
        text: "Password dan konfirmasi password tidak sama.",
        confirmBtnColor: Theme.of(context).colorScheme.primary,
      );

      passwordController.clear();
      confirmPasswordController.clear();

      return;
    }

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        // successful registration
        if (mounted) {
          // move to login page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Registrasi Berhasil",
            text: "Akun berhasil dibuat. Silakan masuk.",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      } else if (response.statusCode == 400) {
        // email has been registered
        final data = jsonDecode(response.body);
        final emailErrors = data['errors']?['email'];

        if (emailErrors != null &&
            emailErrors.contains("Email already registered.")) {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: "Registrasi Gagal",
              text: "Email sudah terdaftar. Silakan gunakan email lain.",
              confirmBtnColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: "Registrasi Gagal",
              text: "Terjadi kesalahan pada registrasi.",
              confirmBtnColor: Theme.of(context).colorScheme.primary,
            );
          }
        }
      } else {
        // other errors
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Registrasi Gagal",
            text: "Registrasi gagal: ${response.reasonPhrase}",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      }
    } catch (e) {
      // connection error or other
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Terjadi kesalahan: $e",
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title
                Text(
                  "Daftar Akun",
                  style: GoogleFonts.poppins(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                const SizedBox(height: 20),

                // name textfield
                CatatAjaTextFormField(
                  controller: nameController,
                  hintText: "Nama",
                  prefixIcon: const Icon(Icons.person_outline),
                  obsecureText: false,
                  maxLines: 1,
                ),

                const SizedBox(height: 10),

                // email textfield
                CatatAjaTextFormField(
                  controller: emailController,
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  obsecureText: false,
                  maxLines: 1,
                ),

                const SizedBox(height: 10),

                // password textfield
                CatatAjaTextFormField(
                  controller: passwordController,
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordIsVisisble = !passwordIsVisisble;
                      });
                    },
                    icon: Icon(passwordIsVisisble
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                  obsecureText: passwordIsVisisble,
                  maxLines: 1,
                ),

                const SizedBox(height: 10),

                // password textfield
                CatatAjaTextFormField(
                  controller: confirmPasswordController,
                  hintText: "Konfirmasi password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        confirmPasswordIsVisisble = !confirmPasswordIsVisisble;
                      });
                    },
                    icon: Icon(confirmPasswordIsVisisble
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                  obsecureText: confirmPasswordIsVisisble,
                  maxLines: 1,
                ),

                const SizedBox(height: 20),

                // sign in button
                CatatAjaButton(
                  onPressed: registerUser,
                  color: Theme.of(context).colorScheme.primary,
                  text: "Daftar",
                ),

                const SizedBox(height: 5),

                // Already have an account? sign in now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun?",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onPressed,
                      child: Text(
                        "Masuk sekarang!",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
