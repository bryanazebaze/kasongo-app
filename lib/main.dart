// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:math'; // Pour la gestion de l'aléatoire et de PI
import 'dart:async'; // Pour utiliser le Timer
import 'package:flutter/services.dart'; // Importez ce service pour le mode paysage et SystemNavigator
import 'package:audioplayers/audioplayers.dart'; // Importez le package audioplayers

// Assurez-vous d'importer votre fichier splash screen si vous l'avez séparé.
import 'splash_screen.dart'; // <-- IMPORT DU FICHIER SPLASH SCREEN

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lion Warthog Chase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Styles globaux pour les ElevatedButton si nécessaire
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Couleur du texte par défaut pour ElevatedButton
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  double _lionPositionX = 0.0;
  double _warthogPositionX = 0.0;

  final double _minLionSpeed = 1.3;
  final double _maxLionSpeed = 1.7;
  final double _minWarthogSpeed = 0.9;
  final double _maxWarthogSpeed = 1.4;

  double _currentLionSpeed = 0.0;
  double _currentWarthogSpeed = 0.0;

  final Random _random = Random();
  bool _warthogIsFlipped = false;
  double _caveEntranceX = 1.0;

  bool _isGameStarted = false;
  bool _isGameEnded = false;
  String _gameResult = "";
  bool _isGamePaused = false;

  final List<String> _lionRunFrames = [
    'assets/images/lion_run_1.webp', 'assets/images/lion_run_2.webp', 'assets/images/lion_run_3.webp',
    'assets/images/lion_run_4.webp', 'assets/images/lion_run_5.webp', 'assets/images/lion_run_6.webp',
    'assets/images/lion_run_7.webp', 'assets/images/lion_run_8.webp', 'assets/images/lion_run_9.webp',
    'assets/images/lion_run_10.webp', 'assets/images/lion_run_11.webp', 'assets/images/lion_run_12.webp',
  ];

  final List<String> _warthogRunFrames = [
    'assets/images/warthog_run_1.webp', 'assets/images/warthog_run_2.webp', 'assets/images/warthog_run_3.webp',
    'assets/images/warthog_run_4.webp', 'assets/images/warthog_run_5.webp', 'assets/images/warthog_run_6.webp',
    'assets/images/warthog_run_7.webp', 'assets/images/warthog_run_8.webp', 'assets/images/warthog_run_9.webp',
    'assets/images/warthog_run_10.webp', 'assets/images/warthog_run_11.webp', 'assets/images/warthog_run_12.webp',
  ];

  int _currentLionFrameIndex = 0;
  int _currentWarthogFrameIndex = 0;
  Timer? _spriteTimer;
  final Duration _spriteFrameDuration = const Duration(milliseconds: 80);

  static const double _lionWidth = 100.0;
  static const double _lionHeight = 100.0;
  static const double _warthogWidth = 90.0;
  static const double _warthogHeight = 90.0;
  static const double _espaceInitial = 80.0;

  final _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        _caveEntranceX = screenWidth * 0.87;
        _lionPositionX = 0.0;
        _warthogPositionX = _lionPositionX + _lionWidth + _espaceInitial;
        if (mounted) {
          setState(() {});
        }
      }
    });

    _controller.addListener(() {
      if (_isGameStarted && !_isGameEnded && !_isGamePaused) {
        _lionPositionX += _currentLionSpeed;
        _warthogPositionX += _currentWarthogSpeed;

        if (_warthogPositionX + _warthogWidth >= _caveEntranceX + 70) {
          _endGame("Le phacochère a atteint la grotte et est en sécurité !", flipWarthog: true);
        } else if ((_lionPositionX + _lionWidth - 20) >= _warthogPositionX) {
          _endGame("Le lion a attrapé le phacochère !");
        } else {
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached && mounted) {
      _precacheAnimalImages();
      _imagesPrecached = true;
    }
  }

  Future<void> _precacheAnimalImages() async {
    if (mounted) {
      if (_lionRunFrames.isNotEmpty) {
        await precacheImage(AssetImage(_lionRunFrames[0]), context);
      }
      if (_warthogRunFrames.isNotEmpty) {
        await precacheImage(AssetImage(_warthogRunFrames[0]), context);
      }
    }
  }
  
  void _endGame(String result, {bool flipWarthog = false}) {
    if (mounted) {
      setState(() {
        _isGameEnded = true;
        _gameResult = result;
        _warthogIsFlipped = flipWarthog;
        _controller.stop();
        _spriteTimer?.cancel();
        _audioPlayer.stop();
      });
    }
  }

  void _startGame() {
    if (mounted) {
      _audioPlayer.stop();
      _audioPlayer.play(AssetSource('audio/music1.mp3'));

      setState(() {
        _isGameStarted = true;
        _isGameEnded = false;
        _isGamePaused = false;
        _gameResult = "";
        _warthogIsFlipped = false;
        _lionPositionX = 0.0;
        _warthogPositionX = _lionPositionX + _lionWidth + _espaceInitial;
        _currentLionFrameIndex = 0;
        _currentWarthogFrameIndex = 0;

        _currentLionSpeed = _minLionSpeed + _random.nextDouble() * (_maxLionSpeed - _minLionSpeed);
        _currentWarthogSpeed = _minWarthogSpeed + _random.nextDouble() * (_maxWarthogSpeed - _minWarthogSpeed);
        if (_currentWarthogSpeed > _currentLionSpeed * 0.9) {
          _currentWarthogSpeed = _currentLionSpeed * 0.85;
        }
        if (_currentLionSpeed < _currentWarthogSpeed * 1.1) {
          _currentLionSpeed = _currentWarthogSpeed * 1.15;
        }
      });
    }

    _spriteTimer?.cancel();
    _spriteTimer = Timer.periodic(_spriteFrameDuration, (timer) {
      if (!_isGameStarted || _isGameEnded || _isGamePaused) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          if (_lionRunFrames.isNotEmpty) {
            _currentLionFrameIndex = (_currentLionFrameIndex + 1) % _lionRunFrames.length;
          }
          if (_warthogRunFrames.isNotEmpty) {
            _currentWarthogFrameIndex = (_currentWarthogFrameIndex + 1) % _warthogRunFrames.length;
          }
        });
      } else {
        timer.cancel();
      }
    });
    _controller.forward(from: 0.0);
  }

  void _pauseGame() {
    if (_isGameStarted && !_isGameEnded && !_isGamePaused) {
      if (mounted) {
        _audioPlayer.pause();
        _controller.stop();
        _spriteTimer?.cancel();
        setState(() {
          _isGamePaused = true;
        });
      }
    }
  }

  void _resumeGame() {
    if (_isGameStarted && !_isGameEnded && _isGamePaused) {
      if (mounted) {
        _audioPlayer.resume();
        setState(() {
          _isGamePaused = false;
        });
        _spriteTimer?.cancel();
        _spriteTimer = Timer.periodic(_spriteFrameDuration, (timer) {
          if (!_isGameStarted || _isGameEnded || _isGamePaused) {
            timer.cancel();
            return;
          }
          if (mounted) {
            setState(() {
               if (_lionRunFrames.isNotEmpty) {
                _currentLionFrameIndex = (_currentLionFrameIndex + 1) % _lionRunFrames.length;
              }
              if (_warthogRunFrames.isNotEmpty) {
                _currentWarthogFrameIndex = (_currentWarthogFrameIndex + 1) % _warthogRunFrames.length;
              }
            });
          } else {
            timer.cancel();
          }
        });
        _controller.forward();
      }
    }
  }

  void _restartGameFromPause() {
    if (mounted) {
      setState(() {
        _isGamePaused = false;
      });
      _startGame();
    }
  }
  
  void _quitGameFromPause() { // <-- MODIFIÉ pour quitter l'application
     if (mounted) {
      _audioPlayer.stop();
      _controller.stop();
      _spriteTimer?.cancel();
      // Quitte l'application. Sur certaines plateformes (comme iOS), cela peut être contre les directives.
      // Alternative: Navigator.of(context).popUntil((route) => route.isFirst); pour revenir à la première route.
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _spriteTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Style pour les boutons du menu pause (plus petits)
    final ButtonStyle pauseMenuStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding réduit
      textStyle: const TextStyle(fontSize: 16, color: Colors.white), // Taille de texte réduite
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('La Course du Lion et du Phacochère'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Positioned(
            left: _caveEntranceX,
            bottom: 0,
            child: Image.asset('assets/images/cave.png', width: 210, height: 250, fit: BoxFit.contain),
          ),
          if (_lionRunFrames.isNotEmpty)
            Positioned(
              left: _lionPositionX,
              bottom: 50,
              child: Image.asset(
                _lionRunFrames[_currentLionFrameIndex % _lionRunFrames.length],
                width: _lionWidth, height: _lionHeight, fit: BoxFit.contain, gaplessPlayback: true,
              ),
            ),
          if (_warthogRunFrames.isNotEmpty)
            Positioned(
              left: _warthogPositionX,
              bottom: 50,
              child: Transform(
                alignment: Alignment.center,
                transform: _warthogIsFlipped ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)) : Matrix4.identity(),
                child: Image.asset(
                  _warthogRunFrames[_currentWarthogFrameIndex % _warthogRunFrames.length],
                  width: _warthogWidth, height: _warthogHeight, fit: BoxFit.contain, gaplessPlayback: true,
                ),
              ),
            ),

          if ((!_isGameStarted || _isGameEnded) && !_isGamePaused)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGameEnded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            _gameResult,
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _startGame,
                        child: Text(_isGameEnded || !_isGameStarted ? 'Rejouer' : 'Démarrer la Course'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // --- MODIFIÉ: Bouton Pause utilise IconButton ---
          if (_isGameStarted && !_isGameEnded && !_isGamePaused)
            Positioned(
              top: 10,
              right: 10,
              child: Material( // Ajout de Material pour l'effet d'élévation et la forme
                color: Colors.orangeAccent.withOpacity(0.8),
                shape: const CircleBorder(),
                elevation: 4.0,
                child: IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white, size: 28),
                  onPressed: _pauseGame,
                  tooltip: 'Pause',
                ),
              ),
            ),

          if (_isGamePaused)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.85), // Légèrement plus opaque pour mieux voir le menu
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "PAUSE",
                        style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _resumeGame,
                        style: pauseMenuStyle.copyWith( // Appliquer le style et la couleur spécifique
                           backgroundColor: MaterialStateProperty.all(Colors.green.shade600),
                        ),
                        child: const Text("Continuer"),
                      ),
                      const SizedBox(height: 15), // Espacement réduit
                      ElevatedButton(
                        onPressed: _restartGameFromPause,
                        style: pauseMenuStyle.copyWith(
                           backgroundColor: MaterialStateProperty.all(Colors.blueAccent.shade400),
                        ),
                        child: const Text("Recommencer"),
                      ),
                      const SizedBox(height: 15), // Espacement réduit
                      ElevatedButton(
                        onPressed: _quitGameFromPause,
                        style: pauseMenuStyle.copyWith(
                           backgroundColor: MaterialStateProperty.all(Colors.redAccent.shade400),
                        ),
                        child: const Text("Quitter le jeu"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}