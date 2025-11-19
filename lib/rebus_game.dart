import 'package:flutter/material.dart';
import 'dart:math' as math; // feu d’artifice de la finale

/// --- Store simple pour l'état du rébus (sans syllabe) ----------------------
class RebusGame {
  RebusGame._();
  static final RebusGame I = RebusGame._();

  /// Clés uniques de points trouvés. Ex: "menu:1", "animations:1", ...
  final Set<String> _found = <String>{};

  /// Nombre total attendu (à configurer dans main()).
  int _totalExpected = 6;

  /// Pour ne montrer la finale qu’une seule fois.
  bool _finaleShown = false;

  // --- API publique ---------------------------------------------------------

  void setTotalExpected(int n) {
    if (n > 0) _totalExpected = n;
  }

  int get foundCount => _found.length;
  bool get isComplete => foundCount >= _totalExpected;

  bool get finaleShown => _finaleShown;
  void setFinaleShown(bool v) => _finaleShown = v;

  /// Marque un point comme trouvé. Retourne true si c’est la première fois.
  bool markFound(String pointId) => _found.add(pointId);

  bool isFound(String pointId) => _found.contains(pointId);
}

/// --- Scope optionnel : expose RebusGame via InheritedWidget ----------------
class GameScope extends InheritedWidget {
  final RebusGame game;
  const GameScope({super.key, required this.game, required super.child});

  static RebusGame of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    return scope?.game ?? RebusGame.I;
  }

  @override
  bool updateShouldNotify(GameScope oldWidget) => false;
}

/// --- Widget du point cliquable caché --------------------------------------
class RebusHiddenTap extends StatefulWidget {
  /// Identifiant unique (ex: "menu:1", "animations:1", ...)
  final String pointId;

  final Widget child;

  /// Appelé UNE SEULE FOIS, la première fois que l’utilisateur clique ce point.
  final VoidCallback? onFound;

  /// Appelé si l’utilisateur clique un point déjà trouvé (pour remontrer l’indice, par ex.).
  final VoidCallback? onAlreadyFound;

  /// Si true (défaut), tente d’afficher automatiquement la finale
  /// quand tous les points sont trouvés.
  ///
  /// ⚠️ Si ta page ouvre d’abord une pop-up d’indice, passe `callFinaleAfterFound: false`
  /// et appelle `maybeShowRebusFinale(context)` toi-même **après** la fermeture.
  final bool callFinaleAfterFound;

  const RebusHiddenTap({
    super.key,
    required this.pointId,
    required this.child,
    this.onFound,
    this.onAlreadyFound,
    this.callFinaleAfterFound = true,
  });

  @override
  State<RebusHiddenTap> createState() => _RebusHiddenTapState();
}

class _RebusHiddenTapState extends State<RebusHiddenTap> {
  bool _localFound = false;

  Future<void> _handleTap() async {
    final game = GameScope.of(context);

    // Déjà validé localement (évite double-tap très rapide)
    if (_localFound) {
      widget.onAlreadyFound?.call();
      return;
    }

    final first = game.markFound(widget.pointId);

    // Si ce n’est pas la première fois → callback dédié
    if (!first) {
      widget.onAlreadyFound?.call();
      return;
    }

    // Première découverte
    setState(() => _localFound = true);
    widget.onFound?.call();

    // Éventuelle finale auto (si activée)
    if (widget.callFinaleAfterFound) {
      // Petite micro-tâche pour laisser la pop-up d’indice s’ouvrir si on en a une synchrone
      await Future.microtask(() {});
      await maybeShowRebusFinale(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

/// --- Pop-up finale centralisée --------------------------------------------
Future<void> maybeShowRebusFinale(BuildContext context) async {
  final game = GameScope.of(context);
  if (!game.isComplete || game.finaleShown || game.foundCount == 0) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 90, child: _SmallFireworksFinale()),
            const SizedBox(height: 8),
            const Text(
              "Si tu penses avoir découvert la phrase du rébus,\n"
                  "rendez-vous sur le Marché de Noël\n"
                  "au chalet Landerneau Boutiques\n"
                  "pour venir chercher ton cadeau !*",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              "* un seul cadeau par personne, avec le QR code affiché sur le téléphone.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF666666), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("À très vite !", style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  game.setFinaleShown(true);
}

/// --- Petit feu d’artifice finale ------------------------------------------
class _SmallFireworksFinale extends StatefulWidget {
  const _SmallFireworksFinale({Key? key}) : super(key: key);
  @override
  State<_SmallFireworksFinale> createState() => _SmallFireworksFinaleState();
}

class _SmallFireworksFinaleState extends State<_SmallFireworksFinale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
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
        const count = 10;

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
