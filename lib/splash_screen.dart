// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Pour utiliser Timer ou Future.delayed

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer; // Déclare un Timer

  @override
  void initState() {
    super.initState();
    // Définit la durée pendant laquelle l'écran de démarrage sera affiché.
    const splashDuration = Duration(seconds: 3); // Par exemple, 3 secondes. Ajustez cette valeur.

    // Initialise un Timer qui s'exécutera une seule fois après 'splashDuration'.
    _timer = Timer(splashDuration, () {
      // Cette fonction est appelée quand le timer arrive à expiration.
      // Nous naviguons vers l'écran du jeu et remplaçons l'écran actuel.
      // '/game' est le nom de la route que nous allons définir pour notre GameScreen dans main.dart.
      // pushReplacementNamed empêche l'utilisateur de revenir au splash screen avec le bouton retour.
      Navigator.pushReplacementNamed(context, '/game');
    });
  }

  @override
  void dispose() {
    // Très important : Annuler le timer lorsque le widget de splash screen est détruit.
    // Cela évite que le callback du timer ne s'exécute si l'utilisateur quitte l'écran avant la fin du timer.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Design de votre Écran de Démarrage ---
    // C'est ce que l'utilisateur voit pendant la durée définie ci-dessus.
    return const Scaffold(
      backgroundColor: Colors.blue, // Couleur de fond de l'écran de démarrage. Choisissez une couleur ou utilisez une image.
      body: Center( // Centre le contenu
        child: Column( // Organise les éléments verticalement
          mainAxisAlignment: MainAxisAlignment.center, // Centre la colonne verticalement
          children: [
            // --- Ajoutez ici le contenu de votre splash screen (ex: logo, nom de l'app) ---

            // Exemple : Un simple texte centré. Remplacez ceci par votre logo ou image.
             Text(
              'Lion Warthog Chase',
              style: TextStyle(
                fontSize: 30, // Taille du texte
                fontWeight: FontWeight.bold, // Texte en gras
                color: Colors.white, // Couleur du texte
              ),
            ),
            SizedBox(height: 20), // Un peu d'espace
            // Exemple : Un indicateur de chargement. Optionnel.
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Couleur de l'indicateur
            ),
            // --- Fin du contenu du splash screen ---
          ],
        ),
      ),
    );
  }
}