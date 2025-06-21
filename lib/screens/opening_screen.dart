import 'package:flutter/material.dart';
import 'home_screen.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  void onContinue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hintergrundbild, etwas nach links verschoben
          Positioned(
            top: 0,
            bottom: 0,
            left: -size.width * 0.15,
            right: 0,
            child: Image.asset(
              'assets/images/9B61E793-016F-4BD3-BD32-EDBFEC1D3A9D.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gelber Hintergrund mit Schriftzug
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.15,
            right: size.width * 0.15,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.orange.shade200.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Möhre',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade700,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(2, 2),
                      ),
                    ],
                    // Apple Font (San Francisco) verwenden
                    fontFamily: 'San Francisco',
                  ),
                ),
              ),
            ),
          ),

          // "Let's Go"-Button unten zentriert
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onContinue,
                child: const Text(
                  "Let's Go",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
