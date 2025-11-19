import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// Pages (alias pour éviter les collisions)
import 'infos_generales.dart' as info;
import 'chalets.dart' as chalets;
import 'roulotte_lb.dart' as lb;
import 'animations.dart' as anim;
import 'maneges.dart' as rides;
import 'food_trucks.dart' as food;
// Jeu (rébus)
import 'rebus_game.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Objet caché (rébus)
  static const double hiddenFx = 0.05;
  static const double hiddenFy = 0.75;
  static const double hiddenSize = 100.0;
  static const String hiddenAsset = 'assets/game/object_1.png';
  static const String hiddenImagePath = 'assets/game/rebus_1.png';

  // Catégories
  late final List<Map<String, dynamic>> categories = [
    {'name': 'Il était une fois Noël', 'builder': () => info.InfoGeneralesPage()},
    {'name': 'Animations', 'builder': () => anim.AnimationsPage()},
    {'name': 'Attractions', 'builder': () => const rides.ManegesPage()},
    {'name': 'Chalets', 'builder': () => const chalets.ChaletsPage()},
    {'name': 'Food-Trucks', 'builder': () => const food.FoodTrucksPage()},
    {'name': 'Landerneau Boutiques', 'builder': () => const lb.RoulotteLBPage()},
  ];

  // --- Palette pastel (douce, non agressive) ---
  final List<Color> colors = const [
    Color(0xFFF6B0B0), // rose pastel
    Color(0xFFA8E6CF), // vert menthe
    Color(0xFFFFD3B6), // pêche
    Color(0xFFF7E7A9), // or très pâle
    Color(0xFFFFF6B3), // jaune beurre
    Color(0xFFBFD7EA), // bleu poudre
  ];

  // Positions asymétriques pour les boules (x, y)
  final List<Offset> positions = const [
    Offset(0.30, 0.10), // Haut droite
    Offset(0.70, 0.20), // Haut gauche
    Offset(0.35, 0.30), // Milieu droite
    Offset(0.70, 0.45), // Milieu gauche
    Offset(0.25, 0.52), // Bas droite
    Offset(0.50, 0.65), // Centre bas
  ];

  // QR / finale
  final GlobalKey _qrKey = GlobalKey();
  String? _userCode;

  @override
  void initState() {
    super.initState();
    _ensureUserCode();
  }

  Future<void> _ensureUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    var code = prefs.getString('lb_user_code');
    if (code == null || code.isEmpty) {
      final rand = math.Random();
      final suffix =
      List.generate(4, (_) => rand.nextInt(16).toRadixString(16)).join().toUpperCase();
      code = 'LB-${DateTime.now().millisecondsSinceEpoch}-$suffix';
      await prefs.setString('lb_user_code', code);
    }
    if (!mounted) return;
    setState(() => _userCode = code);
  }

  Future<void> _launchFacebook() async {
    final Uri fbAppUri = Uri.parse('fb://page/61576020666302');
    final Uri fbWebUri = Uri.parse('https://www.facebook.com/61576020666302');
    try {
      if (!await launchUrl(fbAppUri, mode: LaunchMode.externalApplication)) {
        await launchUrl(fbWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(fbWebUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone() async {
    final uri = Uri(scheme: 'tel', path: '0298250418');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'landerneauboutiques@gmail.com',
      // queryParameters: {'subject': 'Contact depuis l’app Lander’Noël'},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Pop-up animée pour afficher le QR code en grand
  void _showQrPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'QR',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return const SizedBox.shrink(); // contenu géré dans transitionBuilder
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // petit effet “pop” amusant
        );

        return Stack(
          children: [
            Opacity(
              opacity: animation.value,
              child: Container(color: Colors.black54),
            ),
            Center(
              child: Transform.scale(
                scale: curved.value,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/qr_code_ln.png',
                            width: 220,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Scanne ce QR code pour retrouver Lander’Noël.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Color(0xFF6CA8D9), // bleu doux
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          _buildInfoButton(context),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Fond
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

          // Flocons de neige (GIF)
          Positioned.fill(
            child: Image.asset(
              'assets/gifs/snowflakes.gif',
              fit: BoxFit.cover,
              gaplessPlayback: true,
              colorBlendMode: BlendMode.screen,
            ),
          ),

          // Petit QR code en haut à droite (cliquable)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _showQrPopup(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/qr_code_ln.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Boules de Noël pastel
          ...List.generate(categories.length, (idx) {
            final item = categories[idx];
            final position = positions[idx];
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final Color base = colors[idx % colors.length];

            return Positioned(
              left: position.dx * screenWidth - 50,
              top: position.dy * screenHeight - 50,
              child: GestureDetector(
                onTap: () {
                  final builder = item['builder'] as Widget Function();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      pageBuilder: (context, animation, secondaryAnimation) => builder(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Attache
                    Container(
                      width: 10,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFAF9F), // doré désaturé
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    // Boule
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.2),
                          radius: 0.9,
                          colors: [
                            Colors.white.withOpacity(0.85),
                            base.withOpacity(0.90),
                            base.withOpacity(0.95),
                          ],
                          stops: const [0.05, 0.55, 0.95],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: base.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            item['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF2D3A4A),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.2,
                                  color: Colors.white.withOpacity(0.6),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Bouton Facebook
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA7C9EB), Color(0xFF6CA8D9)],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6CA8D9).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _launchFacebook,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fixedSize: const Size(220, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.facebook, size: 32),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Suivez-nous',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Objet caché (rébus)
          Builder(
            builder: (context) {
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              final left = (w * hiddenFx).clamp(0.0, w - hiddenSize);
              final top =
              (h * hiddenFy - hiddenSize).clamp(0.0, h - hiddenSize);
              return Positioned(
                left: left,
                top: top,
                child: RebusHiddenTap(
                  pointId: 'menu:1',
                  callFinaleAfterFound: false,
                  onFound: () {
                    _showRebusFoundDialog(
                      context,
                      imagePath: hiddenImagePath,
                      title: 'Bravo !',
                      message:
                      'Tu as dévoilé la première syllabe du rébus secret...',
                      note:
                      'Note bien cet indice avant qu’il ne disparaisse.',
                      onClosed: () async {
                        final game = GameScope.of(context);
                        if (game.isComplete && !game.finaleShown) {
                          game.setFinaleShown(true);
                          await Future.delayed(
                              const Duration(milliseconds: 20));
                          _showFinalPrizeDialog(context);
                        }
                      },
                    );
                  },
                  child: const SizedBox(
                    width: hiddenSize,
                    height: hiddenSize,
                    child: Image(
                      image: AssetImage(hiddenAsset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSideBar(context),
      child: Container(
        margin: const EdgeInsets.only(right: 16.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFBFD7EA).withOpacity(0.99), // bleu poudre
          border: Border.all(
            color: const Color(0xFFF7E7A9), // doré pâle
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }

  void _showSideBar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),

              // Téléphone cliquable
              InkWell(
                onTap: _callPhone,
                child: const Row(
                  children: [
                    Icon(Icons.phone, size: 16.0),
                    SizedBox(width: 8.0),
                    Text('02 98 25 04 18'),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              // Email cliquable
              InkWell(
                onTap: _sendEmail,
                child: const Row(
                  children: [
                    Icon(Icons.email, size: 16.0),
                    SizedBox(width: 8.0),
                    Text('landerneauboutiques@gmail.com'),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),
              const Text(
                'Réalisation',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://viraje3d.fr/');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: const Text(
                    'VIRAJE 3D',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRebusFoundDialog(
      BuildContext context, {
        required String imagePath,
        String title = 'Bravo !',
        String message = 'Tu as dévoilé la première syllabe du rébus secret...',
        String note = 'Note-la bien avant qu’elle ne disparaisse.',
        VoidCallback? onClosed,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (onClosed != null) Future.microtask(onClosed);
                    },
                    child: const Text('J’ai noté'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinalPrizeDialog(BuildContext context) {
    final code = _userCode ?? 'LB-CODE';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tu as deviné la phrase qui se cache dans le rébus ?"
                      "Viens sur le Marché de Noël au chalet Landerneau Boutiques... "
                      "Un cadeau t'y attend!*",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: QrImageView(
                      data: code,
                      version: QrVersions.auto,
                      size: 180,
                      gapless: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                const Text(
                  "*un seul cadeau par personne, avec le QR code affiché sur le téléphone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Fermer"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
