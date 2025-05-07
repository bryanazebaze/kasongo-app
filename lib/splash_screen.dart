// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Pour utiliser Timer ou Future.delayed
import 'package:audioplayers/audioplayers.dart'; // Importez le package audioplayers
import 'package:flutter/scheduler.dart'; // Pour addPostFrameCallback

// StatefulWidget pour pouvoir gérer l'état (timer, animation, audio)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Mixin pour les animations (nécessaire pour vsync)
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  Timer? _timer; // Timer pour la navigation
  final _audioPlayer = AudioPlayer(); // Instance du lecteur audio

  // Contrôleur et Animation pour le logo
  late AnimationController _animationController;
  late Animation<double> _animation; // Utilisé ici pour un fade-in

  // Définis ici la durée totale du splash screen
  final Duration splashDuration = const Duration(seconds: 10); // Splash screen dure 5 secondes
  // Durée de l'animation du logo (peut être plus courte que la durée totale)
  final Duration logoAnimationDuration = const Duration(seconds: 2); // Par exemple, le logo fade-in sur 2 secondes

  @override
  void initState() {
    super.initState();

    // --- Configuration et démarrage de l'Animation du Logo ---
    _animationController = AnimationController(
      duration: logoAnimationDuration, // L'animation dure N secondes (le fade-in/scale)
      vsync: this, // Nécessaire pour synchroniser l'animation
    );

    // Animation simple (fade-in)
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn, // Une courbe d'animation (fade-in doux)
    );

    // Pour une animation scale + fade:
    // _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    // Puis utilise ScaleTransition + FadeTransition

    // Lance l'animation
    _animationController.forward();


    // --- Démarrage de l'Audio ---
    // Configure le mode de relâchement (important !) - relâche les ressources une fois joué.
    _audioPlayer.setReleaseMode(ReleaseMode.release);

    // Utilise addPostFrameCallback pour être sûr que le widget est construit
    // avant d'essayer de jouer l'audio.
    SchedulerBinding.instance.addPostFrameCallback((_) {
       // Joue le son du splash screen depuis les assets
       // ASSURE-TOI QUE CE FICHIER EXISTE ET EST DÉCLARÉ CORRECTEMENT DANS pubspec.yaml
       // ET QUE LE CHEMIN EST CORRECT ('audio/...')
      _audioPlayer.play(AssetSource('audio/music2.mp3')); // <-- REMPLACE PAR LE CHEMIN DE TON SON SPLASH

       // Par exemple: 'audio/splash_sound.mp3' si tu as un fichier dédié
       // Ou utilise music2.mp3 : AssetSource('audio/music2.mp3')
    });


    // --- Démarrage du Timer de Navigation ---
    // Ce timer attend la durée totale du splash screen (5 secondes)
    _timer = Timer(splashDuration, () {
      // Cette fonction est appelée quand le timer arrive à expiration.
      // Nous naviguons vers l'écran du jeu et remplaçons l'écran actuel.
      Navigator.pushReplacementNamed(context, '/game');
    });
  }

  @override
  void dispose() {
    // --- Très Important : Nettoyer les ressources quand le widget est détruit ---
    _timer?.cancel(); // Annule le timer
    _animationController.dispose(); // Libère le contrôleur d'animation
    _audioPlayer.dispose(); // Libère les ressources audio natives
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Design de votre Écran de Démarrage ---
    return Scaffold(
      backgroundColor: Colors.green, // <-- FOND VERT
      body: Center( // Centre le contenu (le Stack)
        child: Stack( // Utilise Stack pour mettre l'animation par-dessus le fond
          children: [
            // Pas d'image de fond Positioned.fill, on utilise le backgroundColor du Scaffold.

            // --- Contenu centré (le Logo) avec animation ---
            Center( // Centre le logo dans le Stack
              // Applique l'animation de fade-in au logo
              child: FadeTransition( // Ou ScaleTransition, ou les deux
                opacity: _animation, // Utilise l'animation définie dans initState
                child: Image.asset(
                  'assets/images/logo.webp', // <-- REMPLACEZ PAR LE CHEMIN DE VOTRE LOGO !
                   width: 200, // Ajuste la largeur du logo
                   height: 200, // Ajuste la hauteur du logo (garde les proportions si fit: BoxFit.contain)
                   fit: BoxFit.contain, // Assure que l'image s'adapte sans déformation
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}