import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome
// Pages
import 'menu.dart';
// Jeu (rébus)
import 'rebus_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mode immersif : masque les barres système (navigation + statut)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Nombre total d’objets cachés pour déclencher la finale.
  RebusGame.I.setTotalExpected(6);
  runApp(
    GameScope(
      game: RebusGame.I,
      child: const MyApp(),
    ),
  );
}

/// --- Racine de l’app -------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Village de Noël',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'GillSansBold', // Police par défaut pour toute l'application
      ),
      home: const HomePage(),
    );
  }
}

/// --- Page d’accueil --------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    if (_navigating) return; // anti double-tap
    setState(() => _navigating = true);
    try {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuPage()));
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Image de fond ---
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // --- Contenu principal ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                // Titre en fondu
                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      border: Border.all(color: Colors.yellow, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Bienvenue\nsur le\nVillage de Noël',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'GillSansBold',
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        height: 0.9, // <-- AJOUTEZ-LE LÀ
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Visuel d’accueil
                const Padding(
                  padding: EdgeInsets.only(top: 150.0),
                  child: Image(
                    image: AssetImage('assets/images/image1.png'), // Utilise l'image uploadée
                    height: 200,
                  ),
                ),
                const Spacer(),
                // Bouton décoratif (le tap global gère la navigation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    onPressed: null, // désactivé pour éviter double navigation
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      side: const BorderSide(color: Colors.yellow, width: 2.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shadowColor: Colors.grey.withOpacity(0.3),
                      elevation: 6,
                      disabledBackgroundColor: Colors.blue.withOpacity(0.2),
                      disabledForegroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Touchez l’écran pour continuer',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'GillSansBold', // Police Gill Sans Bold appliquée ici aussi
                        color: Colors.white,
                        fontWeight: FontWeight.normal, // Gill Sans Bold est déjà en gras
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- Couche de capture : tap n’importe où pour ouvrir le menu ---
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openMenu,
            ),
          ),
        ],
      ),
    );
  }
}