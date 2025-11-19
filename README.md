// main.dart
import 'package:flutter/material.dart';

// Pages
import 'menu.dart';

// Jeu (rébus) — version sans syllabes, avec pointId
import 'rebus_game.dart';

void main() {
// ➜ Indique le nombre TOTAL de points/objets cachés attendus pour déclencher la pop-up finale.
//    Adapte ce chiffre à ton jeu (6, 7, …).
RebusGame.I.setTotalExpected(6);

runApp(
GameScope(
game: RebusGame.I, // expose l'état du jeu à tout le widget tree
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
// si tu utilises une police perso, pense à la déclarer dans pubspec.yaml
// fontFamily: 'DancingScript',
),
home: const HomePage(),
);
}
}

/// --- Page d’accueil (bouton vers le menu) ----------------------------------
class HomePage extends StatefulWidget {
const HomePage({super.key});
@override
State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _fade;

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

void _openMenu() {
Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: <Widget>[
// --- Image de fond ---
Container(
decoration: const BoxDecoration(
image: DecorationImage(
image: AssetImage('assets/images/background.png'),
fit: BoxFit.cover,
),
),
),

          // --- Contenu principal ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 80),

                // Titre en fondu
                FadeTransition(
                  opacity: _fade,
                  child: Container
                    (
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
                        fontFamily: 'DancingScript',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // visuel d’accueil
                const Padding(
                  padding: EdgeInsets.only(top: 150.0),
                  child: Image(
                    image: AssetImage('assets/images/image1.png'),
                    height: 200,
                  ),
                ),

                const Spacer(),

                // Bouton bas : accéder au Menu
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    onPressed: _openMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      side: const BorderSide(color: Colors.yellow, width: 2.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shadowColor: Colors.grey.withOpacity(0.3),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Découvrir le programme',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
}

