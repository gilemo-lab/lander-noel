import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour ouvrir le lien web

class CityMapPage extends StatefulWidget {
  @override
  _CityMapPageState createState() => _CityMapPageState();
}

class _CityMapPageState extends State<CityMapPage>
    with SingleTickerProviderStateMixin {
  // Liste des marqueurs
  final List<Map<String, dynamic>> markers = [
    {
      "x": 150.0,
      "y": 30.0,
      "icon": Icons.local_parking,
      "color": Colors.blue,
      "label": null,
      "scale": 1.0,
    },
    {
      "x": 200.0,
      "y": 400.0,
      "icon": Icons.local_parking,
      "color": Colors.blue,
      "label": null,
      "scale": 1.0,
    },
    {
      "x": 100.0,
      "y": 220.0,
      "icon": Icons.location_pin,
      "color": Colors.red,
      "label": "Nous sommes ici",
      "scale": 1.0,
    },
    {
      "x": -260.0,
      "y": -260.0,
      "imagePath": 'assets/icons/ferris_wheel.png',
      "scale": 0.1,
      "label": null,
    },
    {
      "x": 60.0,
      "y": 330.0,
      "imagePath": 'assets/icons/pont_habite.png',
      "scale": 0.12,
      "label": null,
    },
  ];

  // URL de la page stationnement
  final Uri parkingUrl = Uri.parse('https://www.ville-landerneau.fr/le-stationnement'); // <-- adapte ce lien

  Future<void> _openParkingLink() async {
    if (!await launchUrl(parkingUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir $parkingUrl');
    }
  }

  // --- Animation pour le pulse du bouton ---
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carte de la Ville',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.lightBlueAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // --- Carte interactive ---
          InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade700, // gris foncé discret
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Image de fond avec cadre
                    Image.asset(
                      'assets/maps/city_map.png',
                      width: 1080,
                      height: 1920,
                      fit: BoxFit.fill,
                    ),

                    // Marqueurs
                    ...markers.map((marker) {
                      if (marker.containsKey("imagePath")) {
                        return Positioned(
                          left: marker["x"],
                          top: marker["y"],
                          child: Transform.scale(
                            scale: marker["scale"],
                            child: Image.asset(marker["imagePath"]),
                          ),
                        );
                      } else {
                        return Positioned(
                          left: marker["x"],
                          top: marker["y"],
                          child: Column(
                            children: [
                              Icon(
                                marker["icon"],
                                color: marker["color"],
                                size: marker["label"] != null ? 40 : 30,
                              ),
                              if (marker["label"] != null)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    marker["label"],
                                    style: TextStyle(
                                      color: marker["color"],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          // --- Bouton stationnement avec effet pulse global ---
          Positioned(
            left: 16,
            bottom: 16,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: InkWell(
                onTap: _openParkingLink,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_parking,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Où se garer ?",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'arial',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
