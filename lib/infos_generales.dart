import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import 'city_map.dart';
import 'roulotte_lb.dart';

class InfoGeneralesPage extends StatefulWidget {
  const InfoGeneralesPage({super.key});

  @override
  State<InfoGeneralesPage> createState() => _InfoGeneralesPageState();
}

class _InfoGeneralesPageState extends State<InfoGeneralesPage> {
  static const double blurSigma = 12.0;
  static const double panelOpacity = 0.25;
  static const double panelRadius = 20.0;
  final double _backgroundOpacity = 1.0;
  bool _showScrollHint = true;

  void _showPartnersPopup() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.lightBlueAccent, width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nos Partenaires",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                const _PartnerEntry(
                  name: "Les Alligators de l'Elorn",
                  url: "https://alligatorslanderneau.com/",
                ),
                const SizedBox(height: 16),

                const _PartnerEntry(
                  name: "Légende FM",
                  url: "https://www.legendefm.fr/index.php/fr-fr/",
                ),
                const SizedBox(height: 16),

                const _PartnerEntry(
                  name: "Mairie de Landerneau",
                  url: "https://www.landerneau.bzh/",
                ),
                const SizedBox(height: 16),

                const _PartnerEntry(
                  name: "CCI Finistère",
                  url: "https://www.bretagne.cci.fr/finistere",
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Informations Générales',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundOpacity,
              child: Image.asset(
                'assets/images/trees_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/gifs/snowflakes.gif',
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
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
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 24.0),
                        child: _FrostedPanel(
                          blurSigma: blurSigma,
                          panelOpacity: panelOpacity,
                          panelRadius: panelRadius,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Village de Noël de Landerneau 2025",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12.0),

                              Text.rich(
                                TextSpan(
                                  text: "Du ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: "5 décembre 2025 au 4 janvier 2026",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                      ", la ville s’illumine et s’anime au coucher du soleil.\n\n",
                                    ),
                                    TextSpan(
                                      text:
                                      "Tous les jours, le Village de Noël sera ouvert ",
                                    ),
                                    TextSpan(
                                      text: "de 15h à 20h",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                      ". Ne manquez pas la soirée exceptionnelle du ",
                                    ),
                                    TextSpan(
                                      text: "23 décembre",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                      ", où les festivités se prolongeront jusqu'à 21h30 pour ",
                                    ),
                                    TextSpan(
                                      text:
                                      "un feu d'artifice spectaculaire tiré à 20h",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: " au niveau des Jardins de la Palud.\n",
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8.0),

                              Text.rich(
                                TextSpan(
                                  text:
                                  "Venez profiter des nombreuses animations : le ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "manège",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ", la "),
                                    const TextSpan(
                                      text: "grande roue",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ", et notre "),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const RoulotteLBPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Chalet Point Information Landerneau Boutiques",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            decoration: TextDecoration.underline,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 12.0),

                              const Text(
                                "Plongez dans l’esprit de Noël et partagez des moments chaleureux !",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 12.0, left: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 160,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _showPartnersPopup,
                        child: const _BlueButton(label: "Partenaires"),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CityMapPage(),
                            ),
                          );
                        },
                        child: const FlashingAccessText(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_showScrollHint)
            const Positioned(
              bottom: 90,
              left: 20,
              child: _ScrollHint(),
            ),
        ],
      ),
    );
  }
}

class FlashingAccessText extends StatefulWidget {
  const FlashingAccessText({super.key});

  @override
  State<FlashingAccessText> createState() => _FlashingAccessTextState();
}

class _FlashingAccessTextState extends State<FlashingAccessText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border.all(
          color: Colors.red,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: const Text(
            'Plan d\'accès',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlueButton extends StatelessWidget {
  final String label;
  const _BlueButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        border: Border.all(color: Colors.lightBlueAccent, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.lightBlueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

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

class _PartnerEntry extends StatelessWidget {
  final String name;
  final String url;
  const _PartnerEntry({required this.name, required this.url});

  Future<void> _open() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _open,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.lightBlueAccent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.link,
              size: 18,
              color: Colors.lightBlueAccent,
            ),
          ),
        ),
      ],
    );
  }
}

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
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                color: Colors.lightBlueAccent.withOpacity(panelOpacity),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}
