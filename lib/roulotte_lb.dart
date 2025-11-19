import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === Jeu (rébus) ===
import 'rebus_game.dart';

class RoulotteLBPage extends StatefulWidget {
  const RoulotteLBPage({super.key});
  @override
  _RoulotteLBPageState createState() => _RoulotteLBPageState();
}

class _RoulotteLBPageState extends State<RoulotteLBPage> {
  final double _backgroundOpacity = 1.0;

  // Réglages “verre givré”
  static const double blurSigma = 12.0;
  static const double panelOpacity = 0.25;
  static const double panelRadius = 20.0;

  // === OBJET CACHÉ #6 (modifiable) ===
  static const double hiddenFx = 0.70;
  static const double hiddenFy = 0.88;
  static const double hiddenSize = 80.0;
  static const String hiddenAsset = 'assets/game/object_6.png';
  static const String hiddenImagePath = 'assets/game/rebus_6.png';

  // Bouton GIF rond
  static const double santaBtnSize = 120.0;

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
      final suffix = List.generate(4, (_) => rand.nextInt(16).toRadixString(16)).join().toUpperCase();
      code = 'LB-${DateTime.now().millisecondsSinceEpoch}-$suffix';
      await prefs.setString('lb_user_code', code);
    }
    if (!mounted) return;
    setState(() => _userCode = code);
  }

  void _showSantaMailPopup(BuildContext context) {
    BuildContext? dialogCtx;
    showDialog(
      context: context,
      builder: (ctx) {
        dialogCtx = ctx;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // ⬇️ IMPORTANT: list NOT const because Image.asset is not const
              children: [
                Image.asset('assets/gifs/santa_mail.gif', height: 150, fit: BoxFit.contain),
                const SizedBox(height: 10.0),
                const Text(
                  'Dépose ta lettre\nau Père Noël dans la boîte\ndevant le chalet !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 6), () {
      if (dialogCtx != null && Navigator.of(dialogCtx!).canPop()) {
        Navigator.of(dialogCtx!).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final size = MediaQuery.of(context).size;
    // final topSafe = MediaQuery.of(context).padding.top; // Non utilisé dans ce layout
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    // SUPPRIMÉ : le calcul de availablePanelHeight n'est plus nécessaire
    // car nous utilisons une SingleChildScrollView.

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Landerneau Boutiques',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // --- Fond principal ---
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundOpacity,
              child: Image.asset(
                'assets/images/trees_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // --- Flocons ---
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/gifs/snowflakes.gif',
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ),

          // ==========================================================
          // --- SECTION MODIFIÉE : Boîtes centrales ---
          //
          // J'ai remplacé le Align/ConstrainedBox par une
          // SingleChildScrollView qui contient plusieurs _InfoCard.
          // ==========================================================
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding pour l'espace en haut et pour ne pas
              // être caché par le bouton GIF en bas.
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                santaBtnSize + bottomSafe + 16.0, // Espace vital en bas
              ),
              child: Column(
                children: const [
                  // Carte 1: Bienvenue
                  _InfoCard(
                    icon: Icons.storefront_rounded,
                    title: "Bienvenue au Chalet",
                    text: "Le chalet Landerneau Boutiques vous accueille sur le village de Noël.",
                  ),
                  // Carte 2: Informations
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    title: "Point d'information",
                    text: "Point central d’information, nous serons là pour répondre à vos questions, vous orienter et gérer les objets perdus.",
                  ),
                  // Carte 3: Chèques cadeaux
                  _InfoCard(
                    icon: Icons.card_giftcard_rounded,
                    title: "Chèques Cadeau",
                    text: "Vous pourrez également acheter des chèques cadeaux Landerneau Boutiques, une excellente idée pour faire plaisir à vos proches.",
                  ),
                  // Carte 4: Conclusion
                  _InfoCard(
                    icon: Icons.celebration_rounded,
                    title: "Profitez des fêtes !",
                    text: "Venez nous rendre visite et profiter pleinement de la magie de Noël ! 🎄",
                  ),
                ],
              ),
            ),
          ),

          // --- Objet caché (rébus) ---
          Builder(
            builder: (context) {
              final w = size.width;
              final h = size.height;

              final left = (w * hiddenFx).clamp(0.0, w - hiddenSize);
              final top = (h * hiddenFy - hiddenSize).clamp(0.0, h - hiddenSize);

              return Positioned(
                left: left,
                top: top,
                child: RebusHiddenTap(
                  pointId: 'lb:1',
                  callFinaleAfterFound: false,
                  onFound: () {
                    _showRebusFoundDialog(
                      context,
                      imagePath: hiddenImagePath,
                      title: 'Bravo !',
                      message: 'Tu as dévoilé la sixième syllabe du rébus secret...',
                      note: 'Note bien cet indice avant qu’il ne disparaisse.',
                      onClosed: () async {
                        final game = GameScope.of(context);
                        if (game.isComplete && !game.finaleShown) {
                          game.setFinaleShown(true);
                          await Future.delayed(const Duration(milliseconds: 20));
                          if (mounted) _showFinalPrizeDialog(context);
                        }
                      },
                    );
                  },
                  child: SizedBox(
                    width: hiddenSize,
                    height: hiddenSize,
                    child: Image.asset(hiddenAsset, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),

          // --- FAB QR ---
          if (game.isComplete)
            Positioned(
              bottom: 16.0 + bottomSafe,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () => _showFinalPrizeDialog(context),
                backgroundColor: Colors.blueAccent.withOpacity(0.9),
                tooltip: 'Afficher le QR Code',
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
              ),
            ),

          // --- GIF Père Noël ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: GestureDetector(
                onTap: () => _showSantaMailPopup(context),
                child: Center(
                  child: Container(
                    width: santaBtnSize,
                    height: santaBtnSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/gifs/santa_mail.gif',
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Popup rébus ---
  void _showRebusFoundDialog(
      BuildContext context, {
        required String imagePath,
        String title = 'Bravo !',
        String message = 'Tu as dévoilé la sixième syllabe du rébus secret...',
        String note = 'Note bien cet indice avant qu’elle ne disparaisse.',
        VoidCallback? onClosed,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(note, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (onClosed != null) Future.microtask(onClosed);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('J’ai noté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Popup finale ---
  void _showFinalPrizeDialog(BuildContext context) {
    final code = _userCode ?? 'LB-CODE';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tu as deviné la phrase qui se cache dans le rébus ?"
                      "Viens sur le Marché de Noël au chalet Landerneau Boutiques... "
                      "Un cadeau t'y attend !*",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "Pour retrouver ce QR code, clique sur l'icône bleue qui se trouve en bas à droite de la page Landerneau Boutiques !",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "*un seul cadeau par personne, avec le QR code affiché sur le téléphone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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

// ==========================================================
// --- NOUVEAU WIDGET : Carte d'information ---
// ==========================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Espace entre les cartes
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _FrostedPanel(
        // Utilise les constantes définies en haut de _RoulotteLBPageState
        blurSigma: _RoulotteLBPageState.blurSigma,
        panelOpacity: _RoulotteLBPageState.panelOpacity,
        panelRadius: _RoulotteLBPageState.panelRadius,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Icon(
              icon,
              color: Colors.white,
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            // Colonne de texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Texte
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      height: 1.3, // Interligne pour meilleure lisibilité
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ---------- Boîte givrée ----------
class _FrostedPanel extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double panelOpacity;
  final double panelRadius;

  const _FrostedPanel({
    Key? key,
    required this.child,
    required this.blurSigma,
    required this.panelOpacity,
    required this.panelRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Flou uniquement sur le fond interne
    return ClipRRect(
      borderRadius: BorderRadius.circular(panelRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Flou contenu dans les bords du panel uniquement
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: Colors.lightBlueAccent.withOpacity(panelOpacity)),
            ),
          ),
          // Contenu net
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}