// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:math'; // Pour la gestion de l'aléatoire et de PI
import 'dart:async'; // Pour utiliser le Timer
import 'package:flutter/services.dart'; // Importez ce service pour le mode paysage
import 'package:audioplayers/audioplayers.dart'; // Importez le package audioplayers

// Assurez-vous d'importer votre fichier splash screen si vous l'avez séparé.
import 'splash_screen.dart'; // <-- IMPORT DU FICHIER SPLASH SCREEN

void main() {
  // --- AJOUTEZ CE CODE POUR FORCER L'ORIENTATION EN MODE PAYSAGE ---
  // Assure que les bindings Flutter sont initialisés avant de modifier les réglages système.
  WidgetsFlutterBinding.ensureInitialized();
  // Définit les orientations préférées : seulement paysage gauche et paysage droite.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // --- FIN DU CODE À AJOUTER ---

  runApp(const MyApp()); // Votre application démarre normalement après avoir réglé l'orientation.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lion Warthog Chase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Optionnel: pour masquer le bandeau debug
      // --- Configuration de la navigation par routes nommées ---
      initialRoute: '/', // <-- Démarrer l'application sur la route '/' (notre splash screen)
      routes: {
        '/': (context) => const SplashScreen(), // <-- Définir la route '/' pour SplashScreen
        '/game': (context) => const GameScreen(), // <-- Définir la route '/game' pour GameScreen
      },
      // --- Fin de la configuration des routes ---
    );
  }
}

// Notre écran de jeu principal qui gérera l'animation et la logique
// C'est un StatefulWidget car son contenu (positions, état du jeu, frames d'animation) va changer.
// Cette classe GameScreen reste dans ce fichier main.dart pour cet exemple complet.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // --- Variables pour le DEPLACEMENT et la logique du jeu ---

  // Positions actuelles des animaux (axe X, de gauche à droite).
  double _lionPositionX = 0.0;
  double _warthogPositionX = 0.0; // Sera calculé dans initState

  // Plages de vitesses de DEPLACEMENT possibles (pixels par "tick" de l'AnimationController)
  final double _minLionSpeed = 1.3;
  final double _maxLionSpeed = 0.7;
  final double _minWarthogSpeed = 0.4; // Peut-être un peu plus rapide en moyenne
  final double _maxWarthogSpeed = 0.9;

  // Vitesses de DEPLACEMENT actuelles (définies aléatoirement au début de CHAQUE course)
  double _currentLionSpeed = 0.0;
  double _currentWarthogSpeed = 0.0;

  // Générateur de nombres aléatoires.
  final Random _random = Random();

  // Variable pour l'angle de rotation du phacochère (en radians). 0 = pas tourné. Utilisé à la fin.
  double _warthogRotationAngle = 0.0;

  // Position de la grotte (ligne d'arrivée). Sera calculée dans initState.
  double _caveEntranceX = 1.0;

  // Variables pour gérer l'état du jeu (commencé, terminé, message de résultat).
  bool _isGameStarted = false;
  bool _isGameEnded = false;
  String _gameResult = "";

  // --- Variables et Timer pour l'animation des SPRITES (pattes qui bougent) ---

  // Liste des chemins vers les images pour l'animation de course du lion.
  // REMPLACEZ CES CHEMINS SI VOS NOMS DE FICHIERS SONT DIFFÉRENTS !
  final List<String> _lionRunFrames = [
    'assets/images/lion_run_1.webp', // <-- VOTRE PREMIER FICHIER WEBP
    'assets/images/lion_run_2.webp', // <-- VOTRE DEUXIÈME FICHIER WEBP
    'assets/images/lion_run_3.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_4.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_5.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_6.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_7.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_8.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_9.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_10.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_11.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    'assets/images/lion_run_12.webp', // <-- VOTRE TROISIÈME FICHIER WEBP
    // Si vous avez plus de 3 frames, ajoutez les chemins ici.
  ];

    // Liste des chemins vers les images pour l'animation de course du phacochère.
  // REMPLACEZ CES CHEMINS SI VOS NOMS DE FICHIERS SONT DIFFÉRENTS !
  final List<String> _warthogRunFrames = [
     // 'assets/images/warthog_run_1.webp', // <-- VOTRE PREMIER FICHIER WEBP
     // 'assets/images/warthog_run_2.webp', // <-- VOTRE DEUXIÈME FICHIER WEBP
     // 'assets/images/warthog_run_3.webp', // <-- VOTRE TROISIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
     // 'assets/images/warthog_run_4.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_1.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_2.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_3.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_4.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_5.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_6.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_7.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_8.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_9.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_10.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_11.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      'assets/images/warthog_run_12.webp', // <-- VOTRE QUATRIÈME FICHIER WEBP (à ajouter dans pubspec.yaml)
      // Si vous avez plus ou moins de frames, AJUSTEZ cette liste et pubspec.yaml.
  ];


  // Index de l'image (frame) actuellement affichée pour chaque animal.
  int _currentLionFrameIndex = 0;
  int _currentWarthogFrameIndex = 0;

  // Timer pour contrôler la vitesse de défilement des images des pattes (pas la vitesse de déplacement).
  // Sera initialisé et démarré dans le onPressed du bouton.
  Timer? _spriteTimer;

  // Durée entre chaque frame de l'animation des pattes (par exemple, 150 ms).
  final Duration _spriteFrameDuration = const Duration(milliseconds: 150);

  // --- Constantes pour les dimensions des animaux (doivent correspondre à celles utilisées dans build) ---
  // Utiles pour la logique de collision et l'affichage.
  static const double _lionWidth = 100.0; // Largeur du lion utilisée dans Image.asset (AJUSTEZ SI CHANGÉE)
  static const double _lionHeight = 100.0; // Hauteur du lion (utile aussi pour ajuster 'bottom')
  static const double _warthogWidth = 90.0; // Largeur du phacochère utilisée dans Image.asset (AJUSTEZ SI CHANGÉE)
  static const double _warthogHeight = 90.0; // Hauteur du phacochère

  // Constante pour l'espace initial entre le lion et le phacochère au départ
  static const double _espaceInitial = 80.0; // Espace entre lion et phacochère au départ (AJUSTEZ cette valeur si besoin)


  // --- Variables pour la gestion Audio ---
  // Instance du lecteur audio
  final _audioPlayer = AudioPlayer(); // <-- GARDEZ CELLE-CI


  // Contrôleur principal de l'animation pour le DEPLACEMENT horizontal.
  late AnimationController _controller;


  // --- Initialisation de l'état ---
  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation pour le DEPLACEMENT.
    // Une durée assez longue, car la course s'arrêtera quand une condition sera remplie.
    // vsync: this est nécessaire pour synchroniser l'animation avec le rafraîchissement de l'écran.
    _controller = AnimationController(
      duration: const Duration(seconds: 60), // Durée maximale de la course
      vsync: this,
    );

    // --- CONFIGURATION INITIALE DU LECTEUR AUDIO ---
    // Met le lecteur en mode boucle pour la musique de fond.
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // --- CALCUL ET DÉFINITION DES POSITIONS INITIALES LORSQUE L'ÉCRAN EST CRÉÉ ---
    // On utilise addPostFrameCallback pour s'assurer que le contexte a une taille et que MediaQuery fonctionne.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final screenWidth = MediaQuery.of(context).size.width;
       // Calculer la position de la grotte (ligne d'arrivée).
       _caveEntranceX = screenWidth * 0.87; // Exemple: 80% de la largeur (AJUSTEZ SELON VOTRE IMAGE DE FOND)

       // Définir les positions de départ pour que les animaux soient corrects AVANT le clic.
       _lionPositionX = 0.0; // Lion commence à l'extrême gauche (X = 0)
       _warthogPositionX = _lionPositionX + _lionWidth + _espaceInitial; // Phacochère commence après le lion

       // Met à jour l'UI pour afficher les animaux dans leurs positions initiales correctes.
       setState(() {});
    });


    // --- Ajout du listener de l'AnimationController (votre boucle de jeu principale pour le DEPLACEMENT) ---
    _controller.addListener(() {
      // --- Logique de jeu ---

      // Mettre à jour la logique de déplacement et de fin de jeu uniquement si le jeu est commencé ET n'est PAS terminé.
      if (_isGameStarted && !_isGameEnded) {

        // 1. Mettre à jour les positions des animaux en utilisant les vitesses ALÉATOIRES actuelles.
        _lionPositionX += _currentLionSpeed;
        _warthogPositionX += _currentWarthogSpeed;

        // Calculer la position de la grotte (assurez-vous que ce calcul est cohérent avec le build).
        // On réutilise _caveEntranceX calculé dans addPostFrameCallback.
        //final screenWidth = MediaQuery.of(context).size.width; // Pas besoin de recalculer ici
        //final double currentCaveEntranceX = screenWidth * 0.8; // Pas besoin de recalculer ici

        // 2. Vérifier les conditions de fin de jeu.
        // On commence par vérifier si le phacochère atteint la grotte.
        if (_warthogPositionX >= _caveEntranceX) { // Utilise _caveEntranceX calculé dans initState
          _isGameEnded = true; // Marque le jeu comme terminé.
          _gameResult = "Le phacochère a atteint la grotte et est en sécurité !"; // Définit le message du résultat.
          _controller.stop(); // Arrête la boucle d'animation de DEPLACEMENT.

          _warthogRotationAngle = pi; // <-- CORRIGÉ : Tourner de 180 degrés (pi) pour regarder en arrière

          _spriteTimer?.cancel(); // <-- ARRÊTE LE TIMER DES SPRITES ICI !
          _audioPlayer.stop(); // <-- ARRÊTE LA MUSIQUE !

          setState(() {}); // Met à jour l'interface (affiche le résultat, fige les positions et la frame du lion/phacochère)

        }
        // Sinon (si le phacochère n'a PAS encore atteint la grotte),
        // on vérifie si le lion a rattrapé le phacochère ("tête du lion touche arrière phacochère").
        // On compare le bord droit du lion (_lionPositionX + _lionWidth) avec le bord gauche du phacochère (_warthogPositionX).
        else if ((_lionPositionX + _lionWidth) >= _warthogPositionX) { // <-- CONDITION DE CAPTURE BASÉE SUR LARGEURS
          _isGameEnded = true; // Marque le jeu comme terminé.
          _gameResult = "Le lion a attrapé le phacochère !"; // Définit le message du résultat.
          _controller.stop(); // Arrête la boucle d'animation de DEPLACEMENT.

          _spriteTimer?.cancel(); // <-- ARRÊTE LE TIMER DES SPRITES ICI !
          _audioPlayer.stop(); // <-- ARRÊTE LA MUSIQUE !


          setState(() {}); // Met à jour l'interface (affiche le résultat, fige les positions et la frame du lion/phacochère)
        } else {
            // Si le jeu est en cours ET PAS terminé...
            setState(() {});
        }
      }
      // Si le jeu n'est pas commencé ou s'il est terminé, le code dans ce "if" n'est pas exécuté.
      // La méthode build sera appelée une dernière fois à la fin du jeu grâce au setState()
      // qui a marqué la fin, ce qui permet d'afficher le résultat.
    });

    // L'animation NE DÉMARRE PAS ICI. Elle attendra le clic sur le bouton.
    // Le Timer des sprites NE DÉMARRE PAS ICI non plus. Il démarrera dans le onPressed.
    // La musique ne démarre pas ici non plus.
  }

  // --- Nettoyage ---
  @override
  void dispose() {
    _controller.dispose();
    // --- Très Important : Annuler le timer des sprites dans dispose ---
    _spriteTimer?.cancel(); // Annule le timer quand le widget n'est plus utilisé.
    // --- Très Important : Libérer l'AudioPlayer dans dispose ---
    _audioPlayer.dispose(); // Libère les ressources audio natives.
    super.dispose();
  }

  // --- Construction de l'interface ---
  @override
  Widget build(BuildContext context) {
    // Obtenir la largeur de l'écran pour aider à positionner des éléments comme la grotte.
    // En mode paysage, screenWidth est la dimension la plus grande.
    // final screenWidth = MediaQuery.of(context).size.width; // Déjà fait dans initState

    // Calculer la position de la grotte (ligne d'arrivée).
    // Ici, on la met à 80% de la largeur de l'écran. Ajustez cette valeur (_caveEntranceX)
    // en fonction de l'emplacement exact de la grotte dans votre image de fond !
    // Assurez-vous que cette valeur est cohérente avec le calcul fait dans le listener.
    // _caveEntranceX est maintenant calculé dans initState.


    return Scaffold( // Un Scaffold fournit une structure d'application de base (AppBar, body)
      appBar: AppBar(
        title: const Text('La Course du Lion et du Phacochère'),
        centerTitle: true,
      ),
      body: Stack( // Stack permet de superposer des widgets (fond, animaux, UI par-dessus)
        children: [
          // --- Image de fond (remplacez par le chemin de votre image) ---
          // Assurez-vous que 'assets/images/background.png' existe et est déclaré dans pubspec.yaml
          Positioned.fill( // L'image remplit tout l'espace du Stack
            child: Image.asset(
              'assets/images/background.png', // <-- VOTRE IMAGE DE FOND
              fit: BoxFit.cover, // Permet à l'image de couvrir l'espace sans déformation excessive
            ),
          ),

          // --- Image de la grotte (remplace la ligne rouge) ---
          // Assurez-vous que 'assets/images/cave.png' existe et est déclaré dans pubspec.yaml
          Positioned(
              // La position "left" peut nécessiter un ajustement (offset)
              // pour que l'entrée de la grotte dans l'image s'aligne
              // avec _caveEntranceX, et non pas le bord gauche de l'image.
              // Par exemple: left: _caveEntranceX - largeur_image_grotte / 2
              // Commencez simple, puis ajustez visuellement.
              left: _caveEntranceX, // Utilise _caveEntranceX calculé dans initState

              // Ajustez bottom et height pour que la grotte soit bien posée sur le sol et ait la bonne taille.
              // En mode paysage, la hauteur de l'écran est plus petite, ajustez 'bottom' et 'height' si besoin.
              bottom: 0, // Ajustez cette valeur (peut-être 0, ou un petit nombre positif)

              child: Image.asset(
                'assets/images/cave.png', // <-- REMPLACEZ PAR LE CHEMIN DE VOTRE IMAGE DE GROTTE
                  width: 210, // <-- AJUSTEZ CETTE LARGEUR SELON VOTRE IMAGE
                  height: 250, // <-- AJUSTEZ CETTE HAUTEUR SELON VOTRE IMAGE
                fit: BoxFit.contain, // ou BoxFit.fill si vous spécifiez width/height
              ),
          ),


          // --- Image du lion (maintenant animée par sprites) ---
          // Assurez-vous que les frames sont dans assets/images/ et déclarées dans pubspec.yaml
          Positioned(
            left: _lionPositionX, // <-- Position horizontale gérée par _lionPositionX
            bottom: 50, // Position verticale fixe (ajustez si besoin pour qu'il soit sur le "sol" de votre fond)
            child: Image.asset(
              // Utilise l'image de la liste _lionRunFrames correspondant à l'index actuel (_currentLionFrameIndex).
              _lionRunFrames[_currentLionFrameIndex], // <-- UTILISE L'IMAGE ANIMÉE DU LION
              width: _lionWidth, // <-- Utilise la constante pour la largeur
              height: _lionHeight, // <-- Utilise la constante pour la hauteur
              fit: BoxFit.contain,
            ),
          ),

          // --- Image du phacochère (maintenant animée par sprites) ---
          // Assurez-vous que les frames sont dans assets/images/ et déclarées dans pubspec.yaml
            Positioned(
             left: _warthogPositionX, // <-- Position horizontale gérée par _warthogPositionX
             bottom: 50, // Ajustez si besoin pour qu'il soit sur le "sol" (probablement la même que le lion)
              // Enveloppé par Transform.rotate pour l'étape 8 (rotation à la fin)
            child: Transform.rotate(
                angle: _warthogRotationAngle, // Utilise la variable d'état pour l'angle (0 par défaut, change à la fin pour le phacochère)
                // Optional: origin: Offset(45, 45), // Point de pivot si vous voulez (ajustez pour le centre de votre image de phacochère)
                child: Image.asset(
                // Utilise l'image de la liste _warthogRunFrames correspondant à l'index actuel (_currentWarthogFrameIndex).
                _warthogRunFrames[_currentWarthogFrameIndex], // <-- UTILISE L'IMAGE ANIMÉE DU PHACOCHÈRE
                width: _warthogWidth, // <-- Utilise la constante pour la largeur
                height: _warthogHeight, // <-- Utilise la constante pour la hauteur
                fit: BoxFit.contain,
                ),
            ),
          ),

          // --- Écran d'accueil/fin de jeu (avec bouton UNIQUEMENT) ---
          // Visible si le jeu n'est pas commencé OU s'il est terminé.
          if (!_isGameStarted || _isGameEnded)
            Positioned.fill( // Remplir tout l'espace pour centrer le contenu
              child: Container(
                  color: Colors.black54, // Optionnel: un fond sombre pour mieux voir les contrôles
                  child: Center( // Centrer le contenu verticalement et horizontalement
                    child: Column( // Organise les éléments verticalement
                      mainAxisAlignment: MainAxisAlignment.center, // Centrer les éléments de la colonne
                      children: [

                        // --- Affichage du résultat (seulement si le jeu est terminé) ---
                        if (_isGameEnded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0), // Espace sous le texte du résultat
                            child: Text(
                              _gameResult,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // --- Bouton Démarrer / Rejouer ---
                        ElevatedButton(
                           onPressed: () {
                             // --- LOGIQUE POUR DÉMARRER LA MUSIQUE ET LE JEU ---
                             print('Bouton Démarrer cliqué !'); // <-- KEEP PRINT

                             // Arrête la musique actuelle si elle joue (utile si on rejoue)
                             _audioPlayer.stop();
                             print('Ancienne musique arrêtée.'); // <-- KEEP PRINT
                             // Joue directement la musique par défaut depuis les assets.
                             // CORRIGÉ : Utilisez le chemin correct 'audio/musicX.mp3'
                             _audioPlayer.play(AssetSource('audio/music1.mp3')); // <-- Vérifiez ce chemin EXACTEMENT
                             print('Essai de lecture de audio/music1.mp3'); // <-- KEEP PRINT

                             // --- LOGIQUE DE DÉMARRAGE DU JEU (comme avant) ---
                             setState(() {
                               // Réinitialise l'état du jeu.
                               _isGameStarted = true;
                               _isGameEnded = false;
                               _gameResult = "";
                               _warthogRotationAngle = 0.0;

                               // Réinitialise les positions au départ (lion derrière phacochère)
                               // Utilisez les mêmes calculs que dans initState pour la position de départ
                               _lionPositionX = 0.0;
                               _warthogPositionX = _lionPositionX + _lionWidth + _espaceInitial; // Recalcule la position de départ du phacochère


                               // Réinitialise les index des frames des pattes.
                               _currentLionFrameIndex = 0;
                               _currentWarthogFrameIndex = 0;

                               // Génère les vitesses de DEPLACEMENT aléatoires.
                               _currentLionSpeed = _minLionSpeed + _random.nextDouble() * (_maxLionSpeed - _minLionSpeed);
                               _currentWarthogSpeed = _minWarthogSpeed + _random.nextDouble() * (_maxWarthogSpeed - _minWarthogSpeed);
                               print('setState pour démarrer le jeu exécuté.'); // <-- KEEP PRINT
                             }); // <-- Fin du setState

                             // --- INITIALISATION ET DÉMARRAGE DU TIMER DES SPRITES ---
                             // Annule l'ancien timer s'il existe (au cas où on recliquerait vite)
                             _spriteTimer?.cancel();
                             // Crée et démarre un NOUVEAU timer pour cette partie.
                             _spriteTimer = Timer.periodic(_spriteFrameDuration, (timer) {
                                 if (_isGameStarted && !_isGameEnded) {
                                     _currentLionFrameIndex = (_currentLionFrameIndex + 1) % _lionRunFrames.length;
                                     _currentWarthogFrameIndex = (_currentWarthogFrameIndex + 1) % _warthogRunFrames.length;
                                     setState(() {});
                                 }
                             });
                             // --- FIN DE L'INITIALISATION ET DÉMARRAGE DU TIMER ---


                             // Démarre l'animation de DEPLACEMENT (AnimationController).
                             _controller.forward(from: 0.0);
                           },
                           // Le texte du bouton change selon si le jeu est terminé ou non.
                           child: Text(_isGameEnded ? 'Rejouer' : 'Démarrer la Course'),
                         ),
                      ],
                    ),
                  ),
                ),
            ),

          // --- L'affichage du résultat précédent est maintenant géré DANS le Column ci-dessus ---
          // Le bloc Positioned.fill du résultat a été déplacé/inclus dans l'écran d'accueil/fin.
        ],
      ),
    );
  }
}