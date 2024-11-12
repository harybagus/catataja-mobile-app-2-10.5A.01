import 'dart:convert';
import 'package:catataja/authentication/login_or_register.dart';
import 'package:catataja/components/catataja_drawer_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class CatatAjaDrawerNavigation extends StatefulWidget {
  final String token;

  const CatatAjaDrawerNavigation({super.key, required this.token});

  @override
  State<CatatAjaDrawerNavigation> createState() =>
      _CatatAjaDrawerNavigationState();
}

class _CatatAjaDrawerNavigationState extends State<CatatAjaDrawerNavigation> {
  String accountName = "";
  String accountEmail = "";

  // API endpoint url
  final String getCurrentUserUrl = "http://10.0.2.2:8000/api/users/current";

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(getCurrentUserUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": widget.token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          accountName = data["data"]["name"];
          accountEmail = data["data"]["email"];
        });
      } else {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Gagal Memuat Data",
            text: "Terjadi kesalahan saat mengambil data pengguna.",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Tidak dapat terhubung ke server.",
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
        child: Column(
          children: [
            // user profile
            GestureDetector(
              onTap: () {
                // Navigate to profile page
              },
              child: UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  radius: 60,
                  backgroundImage: null,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.background,
                    size: 50,
                  ),
                ),
                accountName: Text(
                  accountName.isNotEmpty ? accountName : "Loading...",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                accountEmail: Text(
                  accountEmail.isNotEmpty ? accountEmail : "Loading...",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),

            // home list tile
            CatatAjaDrawerTile(
              onTap: () => Navigator.pop(context),
              icon: Icons.home_outlined,
              text: "Beranda",
            ),

            // settings list tile
            CatatAjaDrawerTile(
              onTap: () {
                // Navigate to settings page
              },
              icon: Icons.settings_outlined,
              text: "Pengaturan",
            ),

            const Spacer(),

            // logout
            CatatAjaDrawerTile(
              onTap: () {},
              icon: Icons.logout,
              text: "Keluar",
            ),
          ],
        ),
      ),
    );
  }
}
