import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// === Jeu (rébus) ===
import 'rebus_game.dart';
// === Page spéciale (chalet Landerneau Boutiques) ===
import 'roulotte_lb.dart';

class ChaletsPage extends StatefulWidget {
  const ChaletsPage({super.key});

  @override
  _ChaletsPageState createState() => _ChaletsPageState();
}

class _ChaletsPageState extends State<ChaletsPage> {
  double _backgroundOpacity = 1;

  // === OBJET CACHÉ #4 ===
  static const double hiddenFx = 0.07;
  static const double hiddenFy = 0.09;
  static const double hiddenSize = 60;
  static const String hiddenAsset = 'assets/game/object_4.png';
  static const String hiddenImagePath = 'assets/game/rebus_4.png';

  // === LOGIQUE DE LA FINALE ===
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

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openLink(String link) async {
    final uri = Uri.parse(link);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showRebusFoundDialog(
      BuildContext context, {
        required String imagePath,
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
                const Text(
                  'Bravo !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tu as trouvé un nouvel indice du rébus du Marché de Noël.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Note-le bien avant de fermer.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Libellé compact selon le type de lien ---
  String _linkLabelFor(String link) {
    final l = link.toLowerCase();
    if (l.contains('facebook.com')) return 'Suivez-nous';
    if (l.contains('instagram.com')) return 'Suivez-nous';
    if (l.startsWith('mailto:')) return 'Contacter';
    return 'Visiter le site';
  }

  // --- Widget compact pour le lien (icône + texte) ---
  Widget _smallLinkButton(String link) {
    final label = _linkLabelFor(link);
    final l = link.toLowerCase();
    final isFacebook = l.contains('facebook.com');
    final isInstagram = l.contains('instagram.com');
    final isMail = l.startsWith('mailto:');

    // Couleur d’accent par type
    Color accent;
    Widget iconWidget;

    if (isInstagram) {
      accent = Colors.purpleAccent;
      iconWidget = Image.asset(
        'assets/icons/instagram.png', // <-- icône locale
        width: 18,
        height: 18,
        fit: BoxFit.contain,
      );
    } else if (isFacebook) {
      accent = Colors.blueAccent;
      iconWidget = const Icon(Icons.facebook, size: 18, color: Colors.blueAccent);
    } else if (isMail) {
      accent = Colors.blueGrey;
      iconWidget = const Icon(Icons.mail_outline, size: 18, color: Colors.blueGrey);
    } else {
      accent = Colors.blueAccent;
      iconWidget = const Icon(Icons.link, size: 18, color: Colors.blueAccent);
    }

    return Center(
      child: InkWell(
        onTap: () => _openLink(link),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.35), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 14, // discret
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === POPUP CHALET ===
  void _showPopup(
      BuildContext context, {
        required String name,
        required String description,
        required String imagePath,
        String? link,          // ex: site ou facebook
        String? instagramLink, // lien instagram séparé
      }) async {
    final exists = await _assetExists(imagePath);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final media = MediaQuery.of(context);
        final controller = ScrollController();
        bool atBottom = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            controller.addListener(() {
              final max = controller.position.maxScrollExtent;
              final offset = controller.offset;
              final reachedBottom = offset >= (max - 10);
              if (reachedBottom != atBottom) {
                atBottom = reachedBottom;
                setSheetState(() {});
              }
            });

            return SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: controller,
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
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _FormattedDescription(description: description),
                          ),

                          // Boutons “Suivez-nous” (Instagram / Facebook)
                          if (instagramLink != null && instagramLink.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _smallLinkButton(instagramLink),
                          ],
                          if (link != null && link.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _smallLinkButton(link),
                          ],

                          const SizedBox(height: 60),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Fermer"),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (!atBottom)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_upward, size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseWidth = 1125.0;
    const baseHeight = 2436.0;

    // ✅ LISTE COMPLÈTE 1 → 15
    final List<Map<String, dynamic>> chalets = [
      {
        "number": 1,
        "x": 760 / baseWidth,
        "y": 1980 / baseHeight,
        "name": "MINERAUX & BIJOUX",
        "description":
        "✨ Venez découvrir le langage des pierres\n\n"
            "• Collections de minéraux sélectionnés\n"
            "• Bijoux & objets artisanaux signés\nPierre Monfort\n"
            "• Livres de vulgarisation sur la minéralogie\n\n"
            "Par Pierre et Chantal.",
        "imageFile": "chalet_1.png",
      },
      {
        "number": 2,
        "x": 850 / baseWidth,
        "y": 1700 / baseHeight,
        "name": "CONFISERIE",
        "description":
        "✨ Confiseries traditionnelles & douceurs\n\n"
            "🍬 Large choix : de la barbe à papa aux bonbons au poids\n"
            "🍭 Pralines maison, sucettes, langues de chat\n\n"
            "Charl et Annick",
        "imageFile": "chalet_2.png",
        "link": "https://www.apg-29.fr",
      },
      {
        "number": 3,
        "x": 850 / baseWidth,
        "y": 1430 / baseHeight,
        "name": "Les Ateliers du Père Noël",
        "description":
        "🎄 Les Ateliers du Père Noël – Artisan & Magie\n\n"
            "🧩 Jouets créatifs\n"
            "Inspirez-vous du style Shashibo :\n"
            "cubes magiques, formes évolutives,\n"
            "imagination et exploration\n"
            "au bout des doigts.\n"
            "Un cadeau ludique pour petits\n"
            "et grands curieux.\n\n"
            "🪢 Cordonnerie du Père Noël\n"
            "Ceintures en cuir italien de haute qualité,\n"
            "boucle automatique\n"
            "pour un ajustement parfait,\n"
            "élégance et durabilité réunies.\n\n"
            "✨ Deux univers, une seule magie :\n"
            "offrir avec cœur.\n\n"
            "🎁 Venez nous voir au Marché de Noël !",
        "imageFile": "chalet_9.png"
      },
      {
        "number": 4,
        "x": 850 / baseWidth,
        "y": 1160 / baseHeight,
        "name": "FROMAGERIE",
        "description":
        "🧀 La Fromagerie du Marché de Noël\n\n"
            "Découvrez une sélection de fromages affinés,\n"
            "choisis pour leur caractère et leur authenticité.\n\n"
            "🥖 Saveurs douces ou corsées,\n"
            "pâtes crémeuses ou croûtes fleuries :\n"
            "il y en a pour tous les palais !\n\n"
            "🍷 À offrir ou à savourer sur place,\n"
            "la convivialité est au rendez-vous.\n\n"
            "🎄 Une halte gourmande à ne pas manquer !",
        "imageFile": "chalet_4.png"
      },

      {
        "number": 5,
        "x": 850 / baseWidth,
        "y": 850 / baseHeight,
        "name": "FRAMBOIZINE",
        "description":
        "✨ CONFITURES, SIROPS & COFFRETS GOURMANDS\n\n"
            "Agricultrice-transformatrice locale\n"
            "Fruits récoltés à Landerneau et Pencran.\n\n"
            "🍓 Confitures traditionnelles\n"
            "Fraise, framboise, cassis, mûre sauvage, rhubarbe…\n"
            "4,50 € le pot de 200g\n\n"
            "🌟 Confitures originales\n"
            "Fraise-tonka, fraise aux 6 épices,\n"
            "pomme-cassis épices de Noël,\n"
            "« cheveux d'anges »…\n"
            "4,50 € le pot de 200g\n\n"
            "🍶 Sirops artisanaux\n"
            "7,50 € la bouteille de 25cl\n\n"
            "🎁 Coffrets cadeaux\n"
            "À partir de 15 €\n\n"
            "🍽️ Dégustation sur place\n\n",
        "imageFile": "chalet_8.png",
        "link": "https://www.facebook.com/share/1DJAw2GNSs/"
      },
      {
        "number": 6,
        "x": 750 / baseWidth,
        "y": 370 / baseHeight,
        "name": "GOURMANDISES & MARRONS CHAUDS",
        "description":
        "✨ La cabane à chi-chi\n"
            "• Chichis / churros sucrés — faits & cuits sur place\n"
            "• Croustillons, mini beignets sucrés\n\n"
            "✨ La cabane gourmande\n"
            "• Pommes d’amour, donuts, brochettes de fruits au chocolat\n\n"
            "🔥 Marrons chauds servis sur place",
        "imageFile": "chichi_1.png",
      },
      {
        "number": 7,
        "x": 340 / baseWidth,
        "y": 320 / baseHeight,
        "name": "Spécialités Alsaciennes",
        "description":
        "🍷 Saveurs d’Alsace au Marché de Noël\n\n"
            "Un détour gourmand qui réchauffe le cœur :\n"
            "vin chaud parfumé aux épices,\n"
            "bretzels dorés et douceurs typiques d’hiver.\n\n"
            "🥨 Entre traditions et authenticité,\n"
            "retrouvez les petits plaisirs chaleureux\n"
            "qui font la magie des marchés de Noël.\n\n"
            "🔥 Une pause conviviale et généreuse,\n"
            "à partager sans modération.\n\n"
            "🎄 L’esprit alsacien, tout simplement.",
        "imageFile": "chalet_14.png"
      },

      {
        "number": 8,
        "x": 185 / baseWidth,
        "y": 680 / baseHeight,
        "name": "Planches Apéro",
        "description":
        "🪵 100% LOCALES, 100% ORIGINALES\n"
            "Fabriquées et gravées dans l’atelier de Marc.\n\n"
            "🍷 Modèles tout prêts : 20 €\n"
            "📝 Commandes personnalisées : à partir de 30 €\n"
            "(prénoms, animaux, dictons...)\n",
        "imageFile": "chalet_12.png",
        "link": "mailto:voilaxvoila@hotmail.com?subject=Commande%20de%20planche%20ap%C3%A9ro",
      },
      {
        "number": 9,
        "x": 185 / baseWidth,
        "y": 1000 / baseHeight,
        "name": "ÉCHARPES & ÉTOLES",
        "description":
        "🧣 ÉCHARPES 100% LAINE\n• Maille fine & maille abeille\nPrix : 15€ / 50€ les 4\n\n"
            "🪶 ÉTOLES 70% LAINE / 30% SOIE\nPrix : 20€ / 50€ les 3\npar Olivier",
        "imageFile": "chalet_11.png",
      },
      {
        "number": 10,
        "x": 185 / baseWidth,
        "y": 1330 / baseHeight,
        "name": "Miellerie de\nla Vallée de l'Elorn",
        "description":
        "🍯 Miel de Printemps, Miel de Fleurs et Miel des Monts d’Arrée.\n\n"
            "🐝 Le Bee Miel et coffrets de miels\n🍬 Bonbons au miel nature ou aromatisés\n🕯️ Savons & bougies cire d’abeille\n🍹 Punch au rhum & bière au miel\n\nFabien et Carole",
        "imageFile": "chalet_10.png",
        "link": "https://www.mielleriedelavalleedelelorn.fr/",
      },
      {
        "number": 11,
        "x": 230 / baseWidth,
        "y": 1660 / baseHeight,
        "name": "Atelier du Moino",
        "description":
        "✨ Atelier du Moino\n"
            "Créations d’objets et accessoires inspirés de la Fantasy et des jeux de rôle.\n\n"
            "🎲 Sur le chalet\n"
            "Pistes à dés, sets de dés, boîtes en bois, pochons à dés,\n"
            "décorations et objets du quotidien.\n\n"
            "🎄 Collection spéciale Noël\n"
            "Idées cadeaux, décorations uniques et pièces artisanales.\n\n"
            "🖋️ Bar à personnalisation\n"
            "Boules en verre et chaussettes à suspendre\n"
            "personnalisées avec vos prénoms.\n\n"
            "À très vite !",
        "imageFile": "chalet_3.png",
        "link": "https://atelierdemoino.com", // Visiter le site
        "instagram": "https://www.instagram.com/latelierdemoino" // Suivez-nous
      },
      {
        "number": 12,
        "x": 700 / baseWidth,
        "y": 1330 / baseHeight,
        "name": "Delbano’s Crochet\n& Natural Mood",
        "description":
        "🧶 Delbano’s Crochet\n"
            "Création d’accessoires au crochet : bandeaux, mitaines, porte-clés, dessous de verre et suspensions étoiles pour sapin.\n\n"
            "Fleurs au crochet : roses, œillets, tournesols, tulipes et autres.\n\n"
            "🕯️ Natural Mood\n"
            "Bougies florales et poétiques en cire végétale, parfumées à Grasse, sans perturbateurs endocriniens, sans phtalates, végan.\n\n"
            "Fondants pour armoire ou brûle-parfums, suspensions de Noël.\n"
            "Couture : sacs et coussins en tissus recyclés.\n",
        "imageFile": "chalet_15.png",
        "link": "https://naturalmoodbougies.com/",
      },
      {
        "number": 13,
        "x": 700 / baseWidth,
        "y": 1110 / baseHeight,
        "name": "Art Landerne - Liane Lhéret",
        "description":
        "🎨 Artiste peintre à Landerneau\n\n"
            "Je peins les petits souffles du monde :\n"
            "un regard, une lumière,\n"
            "un instant de douceur.\n"
            "Retrouvez-moi bientôt au Marché de Noël\n"
            "de Landerneau, pour découvrir\n"
            "mes impressions d’art pleines de tendresse et de magie d’hiver.\n\n"
            "🖼️ Ici, chaque image a une âme :\n"
            "• Le lapin écoute la neige,\n"
            "• le faon découvre le monde,\n"
            "• l’ourson rêve tout doux,\n"
            "• le caneton glisse sur la lumière,\n"
            "• le marcassin trotte joyeux,\n"
            "• l’agneau respire la paix,\n"
            "• le cerf garde les étoiles,\n"
            "• le hibou blanc veille en silence,\n"
            "• et le chaton roux joue avec la lune.\n\n"
            "✨ Même le Père Noël s’arrête un instant :\n"
            "ici, la magie ne se cache pas\n"
            "dans les paquets, mais dans le regard\n"
            "de ceux qui croient encore à la tendresse.",
        "imageFile": "chalet_7.png",
        "link": "https://liane-lheret.com"
      },


      {
        "number": 14,
        "x": 350 / baseWidth,
        "y": 1120 / baseHeight,
        "name": "Saucissons du Terroir",
        "description":
        "🥓 Saucissons artisanaux du terroir\n\n"
            "Un choix de saucissons authentiques,\n"
            "préparés dans la plus pure tradition.\n\n"
            "🌿 Saveurs variées, parfums délicats\n"
            "et recettes transmises avec passion.\n\n"
            "🔥 Séchage naturel et savoir-faire artisanal\n"
            "pour une qualité qui se goûte.\n\n"
            "🎄 Une halte idéale pour les gourmands\n"
            "et les amateurs de charcuterie de caractère.",
        "imageFile": "chalet_14.png"
      },

      {
        "number": 15,
        "x": 350 / baseWidth,
        "y": 1350 / baseHeight,
        "name": "Landerneau Boutiques",
        "description":
        "🏠 Chalet collectif de l’association des commerçants et artisans de Landerneau.\n\n"
            "Découvertes locales, cadeaux, bons d’achat et produits des enseignes adhérentes.\n"
            "Retrouvez aussi la roulotte gourmande à proximité !",
        "imageFile": "chalet_lb.png",
        "isLB": true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Chalets du Marché de Noël',
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

          return Stack(
            children: [
              // fond
              Positioned.fill(
                child: Opacity(
                  opacity: _backgroundOpacity,
                  child: Image.asset('assets/maps/map_background2.png', fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Image.asset('assets/maps/market_map.png', fit: BoxFit.cover),
              ),

              // objet caché
              Builder(
                builder: (context) {
                  final size = MediaQuery.of(context).size;
                  final left =
                  (size.width * hiddenFx).clamp(0.0, size.width - hiddenSize);
                  final top =
                  (size.height * hiddenFy - hiddenSize).clamp(0.0, size.height - hiddenSize);
                  return Positioned(
                    left: left,
                    top: top,
                    child: RebusHiddenTap(
                      pointId: 'chalets:4',
                      callFinaleAfterFound: false,
                      onFound: () {
                        _showRebusFoundDialog(
                          context,
                          imagePath: hiddenImagePath,
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

              // chalets
              ...List.generate(chalets.length, (index) {
                final chalet = chalets[index];
                final left = (chalet["x"] as num).toDouble() * width;
                final top = (chalet["y"] as num).toDouble() * height;
                final imagePath = 'assets/icons/${chalet["imageFile"] as String}';
                final link = chalet["link"] as String?;
                final insta = chalet["instagram"] as String?;
                final number = chalet["number"]?.toString() ?? (index + 1).toString();

                return Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    onTap: () {
                      if (chalet["isLB"] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RoulotteLBPage()),
                        );
                      } else {
                        _showPopup(
                          context,
                          name: chalet["name"] as String,
                          description: chalet["description"] as String,
                          imagePath: imagePath,
                          link: link,
                          instagramLink: insta,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// === Description formatée ===
class _FormattedDescription extends StatelessWidget {
  final String description;
  const _FormattedDescription({required this.description});

  static const Set<String> _headingMarkers = {
    '✨',
    '🧣',
    '🪶',
    '🍫',
    '🔥',
    '🍯',
    '🐝',
    '🍬',
    '🥧',
    '🕯️',
    '🍹',
    '🧶'
  };

  static final RegExp _stripEmojis = RegExp(
    r'[🎄🎁📍❓🎅📸🍡🍭🖋️🌙⭐💫🎶🎷🎺🎹🎨🧑‍🎄🎂🎈🎊🎉🔔🔴🟢🟡🟣🔵🌬]',
    unicode: true,
  );

  String _sanitize(String line) => line.replaceAll(_stripEmojis, '').trimRight();

  @override
  Widget build(BuildContext context) {
    final lines = description.split('\n');
    final spans = <TextSpan>[];
    for (final raw in lines) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }
      final firstChar = trimmed.characters.first;
      if (_headingMarkers.contains(firstChar)) {
        final withoutMarker =
        _sanitize(trimmed.characters.skip(1).string.trimLeft());
        spans.add(
          TextSpan(
            text: '$firstChar $withoutMarker\n',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        );
        continue;
      }
      final clean = _sanitize(trimmed);
      spans.add(
        TextSpan(
          text: '$clean\n',
          style: const TextStyle(
            fontSize: 15.5,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      );
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
}
