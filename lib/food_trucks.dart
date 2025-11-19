import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math; // feu d’artifice pour la pop-up
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart'; // <-- pour le téléphone

// === Jeu (rébus) ===
import 'rebus_game.dart';

class FoodTrucksPage extends StatefulWidget {
  const FoodTrucksPage({super.key});
  @override
  _FoodTrucksPageState createState() => _FoodTrucksPageState();
}

class _FoodTrucksPageState extends State<FoodTrucksPage>
    with SingleTickerProviderStateMixin {
  double _backgroundOpacity = 1;

  // === OBJET CACHÉ #5 (modifiable) ===
  static const double hiddenFx = 0.84;
  static const double hiddenFy = 0.46;
  static const double hiddenSize = 32;
  static const String hiddenAsset = 'assets/game/object_5.png';
  static const String hiddenImagePath = 'assets/game/rebus_5.png';

  // === LOGIQUE DE LA FINALE (COPIÉ DE ROULOTTE) ===
  final GlobalKey _qrKey = GlobalKey();
  String? _userCode;

  // === Animation bouton Lokal pulsant ===
  late final AnimationController _lokalController;
  late final Animation<double> _lokalScale;

  @override
  void initState() {
    super.initState();
    _ensureUserCode();

    _lokalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _lokalScale = Tween<double>(begin: 0.9, end: 1.08).animate(
      CurvedAnimation(
        parent: _lokalController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _lokalController.dispose();
    super.dispose();
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

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ---------- Popup (accepts the whole truck map) ----------
  void _showPopup(BuildContext context, {required Map<String, dynamic> truck}) async {
    final String name = (truck["name"] ?? "") as String;
    final String? description = truck["description"] as String?;
    final String? teaser = truck["teaser"] as String?;
    final String? extraNote = truck["extraNote"] as String?;
    final String? footer = truck["footer"] as String?;
    final String? phone = truck["phone"] as String?;
    final String? dates = truck["dates"] as String?;
    final List<dynamic>? rawMenu = truck["menu"] as List<dynamic>?;
    final List<Map<String, String>>? menu = rawMenu
        ?.map(
          (e) => (e as Map).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
      ),
    )
        .toList();

    final String imagePath = 'assets/icons/${truck["imageFile"] as String}';
    final exists = await _assetExists(imagePath);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final media = MediaQuery.of(context);
        bool showHint = true;

        return LayoutBuilder(
          builder: (ctx, constraints) {
            return StatefulBuilder(
              builder: (ctx, setSheetState) {
                return Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 4.0) {
                          if (showHint) {
                            setSheetState(() {
                              showHint = false;
                            });
                          }
                        } else {
                          if (!showHint) {
                            setSheetState(() {
                              showHint = true;
                            });
                          }
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: media.viewInsets.bottom,
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (exists) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    errorBuilder: (ctx, err, stack) =>
                                        _ImageFallback(path: imagePath, error: err),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ] else
                                _ImageFallback(path: imagePath),

                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              if (menu != null && menu.isNotEmpty)
                                ChalkMenu(teaser: teaser, menu: menu, footer: footer)
                              else if (teaser != null && teaser.trim().isNotEmpty)
                                Text(
                                  teaser,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                )
                              else if (description != null &&
                                    description.trim().isNotEmpty)
                                  Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, height: 1.3),
                                  ),

                              if (extraNote != null && extraNote.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F6F8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E6EA)),
                                  ),
                                  child: Text(
                                    extraNote,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],

                              if (dates != null && dates.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  dates,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],

                              if (phone != null && phone.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _callPhone(phone),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: Text(
                                      'Appeler $phone',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Fermer"),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- petite flèche ---
                    if (showHint)
                      const Positioned(
                        bottom: 14,
                        left: 14,
                        child: _ScrollHint(),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ---- Explicit data with stable IDs (numbers won’t shift with list order)
  static const double _baseWidth = 1125.0;
  static const double _baseHeight = 2436.0;

  // === Données (avec 'footer' optionnel par food-truck) ===
  final List<Map<String, dynamic>> _trucks = [
    {
      "id": 1,
      "x": 820 / _baseWidth,
      "y": 2100 / _baseHeight,
      "name": "Mau'Billig",
      "description": "Crêpes salées sur crêpes de sarrasin bio.",
      "imageFile": "Maubillig.png",
      "footer":
      "Galettes tournées à la minute — profitez tant que c’est chaud.",
      "menu": [
        {"item": "Jambon fromage", "price": "5€"},
        {
          "item":
          "Crêpes montagnarde (Jambon, St nectaire AOP ou raclette, pomme de terre)",
          "price": "7.50€"
        },
        {
          "item":
          "Biquette (Chèvre bio de Plougastel, noix, miel, thym, poitrine fumée)",
          "price": "7.50€"
        },
        {
          "item":
          "Galette saucisse (saucisse de la ferme de luzunen, fondue d'oignons maison moutarde)",
          "price": "7.50€"
        },
        {"item": "Beurre sucre", "price": "2.50€"},
        {"item": "Beurre sucre cannelle", "price": "2.50€"},
        {"item": "Chocolat maison", "price": "3€"},
        {"item": "Caramel au beurre salé maison", "price": "3€"},
        {
          "item": "Snickers (chocolat, caramel au beurre salé, cacahuète)",
          "price": "4.50€"
        },
        {"item": "Confiture", "price": "3€"},
        {"item": "Crème de marron", "price": "3€"},
        {"item": "Nutella", "price": "3€"},
        {
          "item": "Supplément : crème fouettée, amande caramélisées, coco",
          "price": "1€"
        },
      ],
    },
    {
      "id": 3,
      "x": 700 / _baseWidth,
      "y": 1290 / _baseHeight,
      "name": "EXŌDE food",
      "description":
      "Maxime et Julie revisitent des recettes du monde entier en version street food.",
      "imageFile": "Exode.png",
      "footer": "Joyeuses fêtes de fin d'année !",
      "menu": [
        {"item": "Vin blanc chaud", "price": "3€"},
        {"item": "Cidre chaud", "price": "3€"},
        {"item": "Chocolat chaud", "price": "3€"},
        {
          "item": "Gaufres de Liège",
          "price": "3€",
          "note": "+1€ de topping"
        },
        {
          "item":
          "Grilled cheese au Beaufort AOP et oignons caramélisés",
          "price": "7€"
        },
      ],
    },
    {
      "id": 5,
      "x": 550 / _baseWidth,
      "y": 560 / _baseHeight,
      "name": "Friterie Belge SERKEN",
      "teaser":
      "Kenny vous accueille les week-ends* avec ses spécialités belges :",
      "imageFile": "Serken.png",
      "extraNote":
      "*les vendredis, samedis et dimanches du 5 au 21 décembre + les lundi 22  et mardi 23 décembre.",
      "footer": "Sauce à part, sourire inclus.",
      "menu": [
        {"item": "Frites maison façon belge – Petite", "price": "4€"},
        {"item": "Frites maison façon belge – Moyenne", "price": "5€"},
        {"item": "Frites maison façon belge – Grande", "price": "6€"},
        {"item": "Frites maison façon belge – Maxi", "price": "7€"},
        {"item": "Fricadelle", "price": "3€"},
        {
          "item": "→ Américain Fricadelle (pain, fricadelle, frites, sauce)",
          "price": "8€",
          "note": "Copieux"
        },
        {"item": "Belcanto", "price": "4€"},
        {
          "item": "→ Américain Belcanto (pain, belcanto, frites, sauce)",
          "price": "8€",
          "note": "Copieux"
        },
        {"item": "Croquette de fromage", "price": "3€"},
      ],
    },
    {
      "id": 4,
      "x": 350 / _baseWidth,
      "y": 1020 / _baseHeight,
      "name": "Spécialités turques DERYA",
      "description":
      "Venez déguster les incontournables gözlemes, préparés sous vos yeux.",
      "imageFile": "Derya.png",
      "footer": "Pâte fine, chaleur du four, parfum des épices.",
      "menu": [
        {
          "item": "Gözleme ISPANAK (Épinards, feta, oignons marinés)",
          "price": "10.00€"
        },
        {
          "item": "Gözleme ETLI (Bœuf, tomates, oignons marinés)",
          "price": "12.00€"
        },
        {
          "item": "Gözleme PATATESLI (Pommes de terre & mozzarella)",
          "price": "10.00€"
        },
        {
          "item": "Gözleme DE NOËL (À découvrir sur place)",
          "price": "12.00€"
        },
        {
          "item": "CACIK (Yaourt concombre ail & menthe)",
          "price": "3.50€"
        },
        {
          "item": "BAKLAVA (Feuilleté aux noix, sirop maison)",
          "price": "5.00€"
        },
        {"item": "Soda / Boisson sucrée", "price": "2.50€"},
        {"item": "Eau", "price": "1.50€"},
        {"item": "Thé turc traditionnel", "price": "2.00€"},
        {"item": "Huile pimentée", "price": "1.50€"},
        {"item": "Supplément mozzarella", "price": "2.00€"},
      ],
    },
    {
      "id": 2,
      "x": 240 / _baseWidth,
      "y": 1750 / _baseHeight,
      "name": "La Bonne Franquette",
      "description": "Que des bonnes choses.",
      "imageFile": "LBF.png",
      "menu": [
        // — Churros / Chichis
        {"item": "Churros (x6)", "price": "5€"},
        {"item": "Churros (x9)", "price": "6,5€"},
        {"item": "Chichis (x6)", "price": "5€"},
        {"item": "Chichis (x9)", "price": "6,5€"},
        {"item": "Supplément Nutella", "price": "1€"},

        // — Gaufres artisanales
        {"item": "— Gaufres artisanales —", "price": ""},
        {"item": "Gaufre sucre", "price": "3€"},
        {"item": "Gaufre confiture", "price": "4€"},
        {"item": "Gaufre caramel", "price": "4€"},
        {"item": "Gaufre chocolat", "price": "4€"},
        {"item": "Gaufre Nutella", "price": "4,5€"},
        {"item": "Supplément chantilly", "price": "1€"},

        // — Panini & spécialité sucrée
        {"item": "Panini Nutella", "price": "4€"},
        {
          "item": "Pangelato (brioche chaude + glace + topping)",
          "price": "5€",
          "note": "Nouveauté"
        },

        // — Boissons chaudes
        {"item": "— Boissons chaudes —", "price": ""},
        {"item": "Café", "price": "1,5€"},
        {"item": "Chocolat chaud", "price": "3€"},
        {"item": "Thé", "price": "2,5€"},
        {
          "item": "Cappuccino / Macchiato / Latte",
          "price": "3€"
        },

        // — Boissons fraîches & bières
        {"item": "— Boissons fraîches —", "price": ""},
        {
          "item": "Sodas (Coca, Ice Tea, Orangina, Schweppes, etc.)",
          "price": "2,5€"
        },
        {"item": "Bière — canette", "price": "3€"},
        {
          "item": "Bière de Noël Coreff — pression (25cl)",
          "price": "3,5€"
        },
        {
          "item": "Bière de Noël Coreff — pression (50cl)",
          "price": "6,5€"
        },

        // — Snacking salé
        {"item": "— Snacking —", "price": ""},
        {
          "item": "Frites — barquette",
          "price": "5€",
          "note": "1 sauce offerte au choix"
        },
        {"item": "Sauce supplémentaire", "price": "0,5€"},
        {
          "item": "Saucisse — supplément (pièce)",
          "price": "2,5€"
        },

        // — Panini / Hot dog
        {"item": "— Panini / Hot dog —", "price": ""},
        {
          "item": "Panini jambon, tomate, fromage",
          "price": "6,5€"
        },
        {"item": "Panini 3 fromages", "price": "6,5€"},
        {"item": "Hot dog", "price": "4€"},
        {"item": "Supplément cheddar", "price": "1€"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Les Food-Trucks',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.lightBlueAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final trucksSortedForZ = [..._trucks]
            ..sort((a, b) => (a["y"] as double).compareTo(b["y"] as double));

          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: _backgroundOpacity,
                  child: Image.asset(
                    'assets/maps/map_background2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Image.asset(
                  'assets/maps/market_mapFT.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Marqueurs
              ...trucksSortedForZ.map((t) {
                final left = (t["x"] as double) * width;
                final top = (t["y"] as double) * height;
                final number = (t["id"]).toString();

                return Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showPopup(context, truck: t),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            offset: Offset(0, 1),
                            color: Color(0x33000000),
                          )
                        ],
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // === OBJET CACHÉ #5 (rébus) ===
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
                      pointId: 'food:1',
                      callFinaleAfterFound: false,
                      onFound: () {
                        _showRebusFoundDialog(
                          context,
                          imagePath: hiddenImagePath,
                          title: 'Bravo !',
                          message:
                          'Tu as dévoilé la cinquième syllabe du rébus secret...',
                          note:
                          'Note bien cet indice avant qu’il ne disparaisse.',
                          onClosed: () async {
                            final game = GameScope.of(context);
                            if (game.isComplete && !game.finaleShown) {
                              game.setFinaleShown(true);
                              await Future.delayed(
                                  const Duration(milliseconds: 20));
                              if (mounted) {
                                _showFinalPrizeDialog(context);
                              }
                            }
                          },
                        );
                      },
                      child: SizedBox(
                        width: hiddenSize,
                        height: hiddenSize,
                        child:
                        Image.asset(hiddenAsset, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
              ),

              // === Bouton pulsant Lokal Fish & Trucks ===
              Positioned(
                bottom: 30,
                left: 30,
                child: ScaleTransition(
                  scale: _lokalScale,
                  child: GestureDetector(
                    onTap: () {
                      _showPopup(
                        context,
                        truck: {
                          "name": "Lokal Fish & Trucks",
                          "description":
                          "🐟 Lokal Fish & Trucks\n\n"
                              "🍽️ Traiteur & 🚚 Food truck :\n"
                              "envie d’un service pour un mariage, un séminaire,\n"
                              "un anniversaire ou un événement local ?\n\n"
                              "Nous préparons des bouchées salées autour de la mer,\n"
                              "des fish & chips croustillants avec des produits frais\n"
                              "et locaux, des alternatives végétariennes 🌱 et une\n"
                              "petite touche sucrée 🍬.\n\n"
                              "🎄 Pendant le Marché de Noël de Landerneau,\n"
                              "passez nous voir pour imaginer ensemble\n"
                              "votre prochain événement gourmand ✨.",
                          "imageFile": "lokal.png",
                          "footer":
                          "Lokal Fish & Trucks — la mer en version street-food pour vos événements.",
                          "dates":
                          "Présents sur le Marché de Noël les 14, 20, 21 et 23 décembre.",
                          "phone": "0698435008",
                        },
                      );
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.lightBlueAccent,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 6,
                            offset: Offset(0, 2),
                            color: Color(0x33000000),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/icons/lokal.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Popup rébus bloquante ---
  void _showRebusFoundDialog(
      BuildContext context, {
        required String imagePath,
        String title = 'Bravo !',
        String message = 'Tu as dévoilé la cinquième syllabe du rébus secret...',
        String note = 'Note bien cet indice avant qu’il ne disparaisse.',
        VoidCallback? onClosed,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 90,
                  child: Center(child: SmallFireworks()),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (onClosed != null) Future.microtask(onClosed);
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'J’ai noté',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Pop-up finale (avec QR + instruction capture) ---
  void _showFinalPrizeDialog(BuildContext context) {
    final code = _userCode ?? 'LB-CODE';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tu as deviné la phrase qui se cache dans le rébus ? "
                      "Viens sur le Marché de Noël au chalet Landerneau Boutiques... "
                      "Un cadeau t'y attend !*",
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
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "Pour retrouver ce QR code, clique sur l'icône bleue qui se trouve en bas à droite de la page Landerneau Boutiques !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "*un seul cadeau par personne, avec le QR code affiché sur le téléphone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
} // Fin de _FoodTrucksPageState

// --- Widget de fallback pour image manquante ---
class _ImageFallback extends StatelessWidget {
  final String path;
  final Object? error;
  const _ImageFallback({required this.path, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((255 * 0.08).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlueAccent),
      ),
      child: Column(
        children: [
          const Text(
            'Image introuvable ou illisible',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text('Chemin essayé : $path', textAlign: TextAlign.center),
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              'Erreur: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'Vérifiez nom, extension, casse et pubspec.yaml.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------- Widget pour afficher le menu façon tableau noir ----------
class ChalkMenu extends StatelessWidget {
  final String? teaser;
  final List<Map<String, String>> menu;
  final String? footer;
  const ChalkMenu({Key? key, this.teaser, required this.menu, this.footer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textBase = Theme.of(context).textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (teaser != null && teaser!.trim().isNotEmpty) ...[
          Text(
            teaser!,
            textAlign: TextAlign.center,
            style: textBase.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1410),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(0, 2),
                color: Color(0x33000000),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Menu",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: Colors.white.withOpacity(0.35),
                thickness: 1,
              ),
              const SizedBox(height: 6),
              ...menu.map((row) {
                final item = row["item"] ?? "";
                final price = row["price"] ?? "";
                final note = row["note"];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 0.8,
                                    color: Color(0x66FFFFFF),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              shadows: [
                                Shadow(
                                  blurRadius: 0.8,
                                  color: Color(0x66FFFFFF),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (note != null && note.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            note,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontStyle: FontStyle.italic,
                              fontSize: 12.5,
                              shadows: const [
                                Shadow(
                                  blurRadius: 0.8,
                                  color: Color(0x4DFFFFFF),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (footer != null && footer!.trim().isNotEmpty)
          Text(
            footer!,
            textAlign: TextAlign.center,
            style: textBase.copyWith(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
      ],
    );
  }
}

// ====== Petit feu d'artifice sans package ======
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
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
            final angle =
                (2 * math.pi / count) * i + (2 * math.pi) * t;
            final r = baseRadius + extra;
            final dx = r * math.cos(angle);
            final dy = r * math.sin(angle);
            return Transform.translate(
              offset: Offset(dx, dy),
              child: const Icon(
                Icons.star,
                size: 18,
                color: Colors.orangeAccent,
              ),
            );
          }),
        );
      },
    );
  }
}

// --- petit widget flèche discrète ---
class _ScrollHint extends StatelessWidget {
  const _ScrollHint({Key? key}) : super(key: key);

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
