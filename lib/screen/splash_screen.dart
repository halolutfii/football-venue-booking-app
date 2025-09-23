import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    // Delay sebentar lalu mulai animasi
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });

    // Setelah 3 detik, pindah ke halaman berikutnya
    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                width: _visible ? 150 : 50,  
                height: _visible ? 150 : 50,
                child: Image.asset(
                  "assets/images/solecode.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: const Text(
                "Empowering Your Digital Journey",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: SizedBox(
                width: 150, 
                child: const LinearProgressIndicator(
                  color: Color(0xFF2E3A59),
                  backgroundColor: Colors.blueGrey,
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}