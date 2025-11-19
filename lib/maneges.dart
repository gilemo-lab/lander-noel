import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === Jeu (rébus) ===
import 'rebus_game.dart';

class ManegesPage extends StatefulWidget {
  const ManegesPage({super.key});
  @override
  State<ManegesPage> createState() => _ManegesPageState();
}

class _ManegesPageState extends State<ManegesPage> {
  // Réglages “verre givré”
  static const double blurSigma = 12.0;
  static const double panelOpacity = 0.25;
  static const double panelRadius = 20.0;

  // Marge basse
  static const double bottomMargin = 16.0;

  // === OBJET CACHÉ #3 (modifiable) ===
  static const double hiddenFx = 0.84;
  static const double hiddenFy = 0.58;
  static const double hiddenSize = 60;
  static const String hiddenAsset = 'assets/game/object_3.png';
  static const String hiddenImagePath = 'assets/game/rebus_3.png';

  // === LOGIQUE FINALE (QR) ===
  final GlobalKey _qrKey = GlobalKey();
  String? _userCode;

  // --- pour l’indicateur de scroll ---
  bool _showScrollHint = true; // flèche visible au départ

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final double reservedBottomSpace = bottomMargin + bottomSafe;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Les attractions',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset('assets/images/trees_background.png', fit: BoxFit.cover),
          ),

          // Contenu principal
          Positioned.fill(
            top: 0,
            bottom: reservedBottomSpace,
            child: SafeArea(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // quand on atteint le bas → on cache la flèche
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 4) {
                    if (_showScrollHint) {
                      setState(() => _showScrollHint = false);
                    }
                  } else {
                    if (!_showScrollHint) {
                      setState(() => _showScrollHint = true);
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.9,
                        minWidth: 320,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Carte 1 — Manège
                          _AttractionCard(
                            title: "Le Manège",
                            iconPath: "assets/icons/merry_go_round.png",
                            description:
                            "Un tour magique pour petits et grands, plongez dans l’univers féerique du Village de Noël !",
                            price: "Prix : 2 € le ticket",
                            blurSigma: blurSigma,
                            panelOpacity: panelOpacity,
                            panelRadius: panelRadius,
                          ),
                          const SizedBox(height: 16),

                          // Carte 2 — Grande roue
                          _AttractionCard(
                            title: "La Grande-Roue",
                            iconPath: "assets/icons/ferris_wheel.png",
                            description:
                            "Profitez d'une vue imprenable sur le Village et la ville de Landerneau illuminée !",
                            price: "Prix : 3 € par ticket",
                            blurSigma: blurSigma,
                            panelOpacity: panelOpacity,
                            panelRadius: panelRadius,
                            footer: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Image.asset(
                                  'assets/gifs/Santa.gif',
                                  fit: BoxFit.contain,
                                  height: 120,
                                  opacity: const AlwaysStoppedAnimation(0.9),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Horaires
                          _FrostedPanel(
                            blurSigma: blurSigma,
                            panelOpacity: panelOpacity,
                            panelRadius: panelRadius,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Horaires d’ouverture",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontFamily: 'arial',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "- Hors vacances scolaires :",
                                  style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'arial'),
                                ),
                                Center(
                                  child: Text(
                                    "de 15h à 20h",
                                    style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'arial'),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "- Pendant les vacances scolaires :",
                                  style: TextStyle(color: Colors.red, fontSize: 16.0, fontFamily: 'arial'),
                                ),
                                Center(
                                  child: Text(
                                    "de 14h à 20h",
                                    style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'arial'),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "- Nocturne les 21 et 23 décembre.",
                                  style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'arial'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tickets
                          _FrostedPanel(
                            blurSigma: blurSigma,
                            panelOpacity: panelOpacity,
                            panelRadius: panelRadius,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.confirmation_number, size: 28, color: Colors.black87),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Les tickets sont disponibles au stand près du manège.",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontFamily: 'arial',
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === OBJET CACHÉ (rébus) ===
          Builder(
            builder: (context) {
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              final left = (w * hiddenFx).clamp(0.0, w - hiddenSize);
              final top = (h * hiddenFy - hiddenSize).clamp(0.0, h - hiddenSize);

              return Positioned(
                left: left,
                top: top,
                child: RebusHiddenTap(
                  pointId: 'rides:1',
                  callFinaleAfterFound: false,
                  onFound: () {
                    _showRebusFoundDialog(
                      context,
                      imagePath: hiddenImagePath,
                      title: 'Bravo !',
                      message: 'Tu as dévoilé la troisième syllabe du rébus secret...',
                      note: 'Note bien cet indice avant qu’il ne disparaisse.',
                      onClosed: () async {
                        final game = GameScope.of(context);
                        if (game.isComplete && !game.finaleShown) {
                          game.setFinaleShown(true);
                          await Future.delayed(const Duration(milliseconds: 20));
                          _showFinalPrizeDialog(context);
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

          // === Flèche de scroll en bas à gauche ===
          if (_showScrollHint)
            const Positioned(
              bottom: 20,
              left: 20,
              child: _ScrollHint(),
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
        String message = 'Tu as dévoilé la troisième syllabe du rébus secret...',
        String note = 'Note-la bien avant qu’elle ne disparaisse.',
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
                const SizedBox(height: 90, child: Center(child: SmallFireworks())),
                const SizedBox(height: 8),
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

  // --- Pop-up finale (QR) ---
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
                const SizedBox(height: 90, child: Center(child: SmallFireworks())),
                const SizedBox(height: 8),
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
                Text(code, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
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

// --- petite flèche réutilisable ---
class _ScrollHint extends StatelessWidget {
  const _ScrollHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.keyboard_arrow_up_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// ---------- Carte attraction (inchangé) ----------
class _AttractionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final String description;
  final String price;
  final double blurSigma;
  final double panelOpacity;
  final double panelRadius;
  final Widget? footer;

  const _AttractionCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.description,
    required this.price,
    required this.blurSigma,
    required this.panelOpacity,
    required this.panelRadius,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(panelRadius),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: double.infinity,
              color: Colors.lightBlueAccent.withOpacity(panelOpacity),
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.white54, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(iconPath, width: 80, height: 80),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'arial',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'arial'),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'arial',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Panneau givré (inchangé) ----------
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(panelRadius),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: double.infinity,
              color: Colors.lightBlueAccent.withOpacity(panelOpacity),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.white54, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ====== Petit feu d'artifice ======
class SmallFireworks extends StatefulWidget {
  const SmallFireworks({Key? key}) : super(key: key);
  @override
  State<SmallFireworks> createState() => _SmallFireworksState();
}

class _SmallFireworksState extends State<SmallFireworks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) {
        final t = _ctl.value;
        final pulse = 0.4 + 0.6 * (0.5 - (t - 0.5).abs()) * 2;
        final baseRadius = 26.0;
        final extra = 18.0 * pulse;
        const count = 8;

        return Stack(
          alignment: Alignment.center,
          children: List.generate(count, (i) {
            final angle = (2 * math.pi / count) * i + (2 * math.pi) * t;
            final r = baseRadius + extra;
            final dx = r * math.cos(angle);
            final dy = r * math.sin(angle);
            return Transform.translate(
              offset: Offset(dx, dy),
              child: const Icon(Icons.star, size: 18, color: Colors.orangeAccent),
            );
          }),
        );
      },
    );
  }
}
