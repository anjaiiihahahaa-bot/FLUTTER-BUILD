import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import 'login_page.dart'; 

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late VideoPlayerController _videoController;

  final Color darkBg = const Color(0xFF050505);
  final Color grayPrimary = const Color(0xFF6E6E6E);
  final Color grayAccent = const Color(0xFFBDBDBD);
  final Color grayGlow = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();

    // Inisialisasi Animasi
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    // Inisialisasi Video
    _videoController = VideoPlayerController.asset('assets/videos/bnb.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0); // Mute video jika hanya untuk background visual
        _videoController.play();
        setState(() {}); // Memperbarui tampilan setelah video siap
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Error launching $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- HEADER VIDEO ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.black26, // Fallback color
                      child: _videoController.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            )
                          : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // --- TITLE ---
                  const Text(
                    "N X O B   A P P S",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- ICON HANDSHAKE ---
                  const FaIcon(
                    FontAwesomeIcons.handshake,
                    color: Colors.white54,
                    size: 40,
                  ),

                  const SizedBox(height: 30),

                  // --- WELCOME TEXT BOX ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A), // Dark gray box
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      "Welcome to the nxob application which will always continue to develop at all times with the best features for all users.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6,
                        fontFamily: 'monospace', // Menggunakan font monospace seperti di gambar
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- SUBTITLE ---
                  const Text(
                    "- Nxob -",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- TOMBOL SIGN IN ---
                  _primaryButton(),
                  
                  const SizedBox(height: 16),

                  // --- TOMBOL JOIN CHANNEL ---
                  _secondaryButton(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Desain tombol Sign In (Gradien Abu-abu)
  Widget _primaryButton() {
    return Container(
      width: double.infinity, 
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [grayAccent, grayPrimary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.rocket, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Desain tombol Join Channel (Outline transparan)
  Widget _secondaryButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55), 
        side: const BorderSide(color: Colors.white24), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
      ), 
      onPressed: () => _openUrl("https://t.me/topsyatim"), 
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.headset, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text("Join Channel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      )
    );
  }
}