import 'package:flutter/material.dart';

// === Jeu (rébus) ===
import 'rebus_game.dart';

class AnimationsPage extends StatefulWidget {
  const AnimationsPage({Key? key}) : super(key: key);

  @override
  State<AnimationsPage> createState() => _AnimationsPageState();
}

class _AnimationsPageState extends State<AnimationsPage> {
  // === Rébus (objet caché) ===
  static const double hiddenFx = 0.79;
  static const double hiddenFy = 0.10;
  static const double hiddenSize = 60;
  static const String hiddenAsset = 'assets/game/object_2.png';
  static const String hiddenImagePath = 'assets/game/rebus_2.png';

  // Mois : Déc 2025 + Jan 2026 (2 rangées)
  final DateTime _december = DateTime(2025, 12, 1);
  final DateTime _january = DateTime(2026, 1, 1);

  late final Map<DateTime, List<AnimationEvent>> _events;
  late final Map<String, DateTime> _firstAppearance;

  // ~1 cm ≈ 38 px (ajustable)
  static const double _oneCm = 38.0;

  // UI constants — tailles et espacements uniformes
  static const double kIconSize = 28.0;
  static const double kTitleSize = 16.0;
  static const double kTimeSize = 13.0;
  static const double kDescSize = 13.0;
  static const double kLineGapSmall = 6.0;
  static const double kLineGapTiny = 2.0;

  @override
  void initState() {
    super.initState();
    _events = _buildEvents();
    _firstAppearance = _computeFirstAppearances(_events);
  }

  // ========= ÉVÉNEMENTS =========
  Map<DateTime, List<AnimationEvent>> _buildEvents() {
    DateTime d(int y, int m, int day) => DateTime(y, m, day);
    final map = <DateTime, List<AnimationEvent>>{};
    void add(DateTime day, AnimationEvent e) {
      final key = DateTime(day.year, day.month, day.day);
      map.putIfAbsent(key, () => []);
      map[key]!.add(e);
    }

    // ==== DÉCEMBRE 2025 ====

    // Les petites chansons folk (Mickaël Guerrand) — 6 & 30 déc
    add(
      d(2025, 12, 6),
      const AnimationEvent(
        titre: "Les Petites Chansons Folk",
        horaire: "de 16h à 17h30",
        description:
        "Laissez-vous emporter par l’univers enchanteur de Mickaël Guerrand, musicien brestois. Spectacle musical conçu pour émerveiller les petits (et les grands).",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );
    add(
      d(2025, 12, 30),
      const AnimationEvent(
        titre: "Les Petites Chansons Folk",
        horaire: "de 16h à 17h30",
        description:
        "Retrouvez Mickaël Guerrand et ses chansons folk, un moment magique pour toute la famille !",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );

    // Rue de la Lune (fanfare) — 14, 20, 27 déc
    add(
      d(2025, 12, 14),
      const AnimationEvent(
        titre: "Rue de la Lune",
        horaire: "de 16h à 17h30",
        description:
        "Plongez dans l’ambiance festive du Village de Noël avec la fanfare Rue de la Lune ! Laissez-vous porter par le son chaleureux des cuivres et des tambours, qui résonneront sur le village. Une atmosphère envoûtante et joyeuse, parfaite pour célébrer la magie de Noël en musique !",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );
    add(
      d(2025, 12, 20),
      const AnimationEvent(
        titre: "Rue de la Lune",
        horaire: "de 16h30 à 18h",
        description:
        "Plongez dans l’ambiance festive du Village de Noël avec la fanfare Rue de la Lune ! Laissez-vous porter par le son chaleureux des cuivres et des tambours, qui résonneront sur le village. Une atmosphère envoûtante et joyeuse, parfaite pour célébrer la magie de Noël en musique !",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );
    add(
      d(2025, 12, 27),
      const AnimationEvent(
        titre: "Rue de la Lune",
        horaire: "de 16h30 à 18h",
        description:
        "Ambiance garantie avec la fanfare Rue de la Lune ! Cuivres et tambours résonneront dans le Village de Noël pour une immersion musicale festive et envoûtante.",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );

    // Cracheur de feu — 7, 26, 28 déc
    add(
      d(2025, 12, 7),
      const AnimationEvent(
        titre: "Cracheur de feu",
        horaire: "de 16h à 17h30",
        description:
        "Ne manquez pas ce moment magique et captivant ! Un spectacle de flammes éblouissant vous attend, pour émerveiller toute la famille.",
        iconAsset: "assets/icons/fire_juggler.png",
      ),
    );
    add(
      d(2025, 12, 26),
      const AnimationEvent(
        titre: "Cracheur de feu",
        horaire: "de 16h à 17h30",
        description: "Spectacle de flammes envoûtant pour toute la famille.",
        iconAsset: "assets/icons/fire_juggler.png",
      ),
    );
    add(
      d(2025, 12, 28),
      const AnimationEvent(
        titre: "Cracheur de feu",
        horaire: "de 16h à 17h30",
        description: "Spectacle de flammes envoûtant pour toute la famille.",
        iconAsset: "assets/icons/fire_juggler.png",
      ),
    );

    // L’Art en Soi — 13 & 17 déc
    add(
      d(2025, 12, 13),
      const AnimationEvent(
        titre: "L’Art en Soi",
        horaire: "18h30",
        description:
        "Plongez dans l’univers envoûtant de l’association L’Art en Soi, qui illumine le Village de Noël de ses spectacles vibrants et chaleureux ! Née en terre landernéenne, cette troupe passionnée marie théâtre, musique et danse au service de la création et de l’émotion.",
        iconAsset: "assets/icons/theatre_masks.png",
      ),
    );
    add(
      d(2025, 12, 17),
      const AnimationEvent(
        titre: "L’Art en Soi",
        horaire: "18h puis 19h",
        description:
        "Plongez dans l'univers de L'Art en Soi ! Cette troupe passionnée illumine le Village de Noël avec un spectacle vibrant qui mêle théâtre, musique et danse, pour un moment d'émotion partagé.",
        iconAsset: "assets/icons/theatre_masks.png",
      ),
    );

    // Rêve en Scène — 14 déc
    add(
      d(2025, 12, 14),
      const AnimationEvent(
        titre: "Rêve en Scène (chant/théâtre)",
        horaire: "17h30",
        description: "Comédie musicale : chant, théâtre et féérie.",
        iconAsset: "assets/icons/theatre_masks.png",
      ),
    );

    // Photographe — horaires multiples
    for (final day in [6, 7, 17, 20, 21, 22]) {
      add(
        d(2025, 12, day),
        const AnimationEvent(
          titre: "Florence, photographe",
          horaire: "de 14h à 17h",
          description:
          "Immortalisez vos plus beaux souvenirs en famille ou entre amis ! Au Village de Noël, Florence, notre photographe, sera là pour capturer vos moments de magie et de complicité.",
          iconAsset: "assets/icons/camera2.png",
        ),
      );
    }
    for (final day in [13, 14, 19, 24]) {
      add(
        d(2025, 12, day),
        const AnimationEvent(
          titre: "Florence, photographe",
          horaire: "de 15h à 18h",
          description:
          "Nouveau rendez-vous avec Florence, votre photographe, pour capturer vos plus beaux souvenirs !",
          iconAsset: "assets/icons/camera2.png",
        ),
      );
    }

    // L’Escale du Père Noël — 21 déc
    add(
      d(2025, 12, 21),
      const AnimationEvent(
        titre: "L’Escale du Père Noël",
        horaire: "Vers 18h",
        lieu: "Place de la Mairie → Pont de Rohan",
        description:
        "Show sons & lumières sur l’Elorn. Arrivée du Père Noël en traîneau flottant.",
        iconAsset: "assets/icons/santa.png",
      ),
    );

    // Balades en calèche — 21 & 24 déc
    add(
      d(2025, 12, 21),
      const AnimationEvent(
        titre: "Balades en calèche",
        horaire: "11h30 à 12h30 puis 14h30 à 16h30",
        lieu: "Départs : Village de Noël",
        description: "Promenade conviviale en musique.",
        iconAsset: "assets/icons/caleche.png",
      ),
    );
    add(
      d(2025, 12, 24),
      const AnimationEvent(
        titre: "Balades en calèche avec le Père Noël chanteur",
        horaire: "de 14h à 17h",
        lieu: "Départs : Village de Noël / Centre-ville",
        description:
        "Pour la 3ᵉ année consécutive, le Père Noël chanteur sillonne la ville en calèche et transforme le centre-ville en scène à ciel ouvert. Chants, ambiance festive et rencontres chaleureuses tout au long du parcours.",
        iconAsset: "assets/icons/caleche.png",
      ),
    );

    // Feu d’artifice — 23 déc
    add(
      d(2025, 12, 23),
      const AnimationEvent(
        titre: "Feu d’artifice",
        horaire: "20h",
        lieu: "Jardins de la Palud",
        description:
        "Spectacle pyrotechnique familial organisé par Les Fées du Feu et Bretagne Pyro (attention : la passerelle restera fermée).",
        iconAsset: "assets/icons/fireworks.png",
      ),
    );

    // ==== JANVIER 2026 (2 premières semaines) ====

    // Mascottes — 2 janv
    add(
      d(2026, 1, 2),
      const AnimationEvent(
        titre: "Mascottes (Pat’ Patrouille, Stitch, Pikachu)",
        horaire: "15h30 puis 16h30",
        description:
        "Rencontres féeriques avec les mascottes préférées des enfants.",
        iconAsset: "assets/icons/mascot.png",
      ),
    );

    // Rue de la Lune — 3 janv
    add(
      d(2026, 1, 3),
      const AnimationEvent(
        titre: "Rue de la Lune (fanfare)",
        horaire: "de 16h30 à 18h",
        description:
        "Ambiance garantie avec la fanfare Rue de la Lune ! Cuivres et tambours résonneront dans le Village de Noël pour une immersion musicale festive et envoûtante.",
        iconAsset: "assets/icons/fanfare.png",
      ),
    );

    return map;
  }

  Map<String, DateTime> _computeFirstAppearances(
      Map<DateTime, List<AnimationEvent>> events) {
    final first = <String, DateTime>{};
    events.forEach((day, list) {
      for (final e in list) {
        final key = e.titre.trim().toLowerCase();
        final normDay = DateTime(day.year, day.month, day.day);
        if (!first.containsKey(key) || normDay.isBefore(first[key]!)) {
          first[key] = normDay;
        }
      }
    });
    return first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Le calendrier des animations',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/trees_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              children: [
                _MonthView(
                  monthStart: _december,
                  events: _events,
                  firstAppearance: _firstAppearance,
                  onTapDay: _onTapDay,
                  headerColor: Colors.white,
                  weekdayColor: Colors.white,
                  maxRows: null,
                ),
                const SizedBox(height: _oneCm),
                _MonthView(
                  monthStart: _january,
                  events: _events,
                  firstAppearance: _firstAppearance,
                  onTapDay: _onTapDay,
                  headerColor: Colors.white,
                  weekdayColor: Colors.white,
                  maxRows: 2,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // --- Objet caché (rébus) ---
          Builder(
            builder: (context) {
              final size = MediaQuery.of(context).size;
              final left =
              (size.width * hiddenFx).clamp(0.0, size.width - hiddenSize);
              final top = (size.height * hiddenFy - hiddenSize)
                  .clamp(0.0, size.height - hiddenSize);
              return Positioned(
                left: left,
                top: top,
                child: RebusHiddenTap(
                  pointId: 'animations:1',
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
        ],
      ),
    );
  }

  // --- Tap sur un jour du calendrier ---
  void _onTapDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final list = _events[key];
    if (list == null || list.isEmpty) return;

    final items = [...list]
      ..sort(
            (a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()),
      );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                mq.viewInsets.bottom + mq.padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDateLong(day),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...items.map((e) {
                    final titleKey = e.titre.trim().toLowerCase();
                    final firstDay = _firstAppearance[titleKey];
                    final isFirstForArtist =
                        (firstDay != null) && _isSameDay(firstDay, day);
                    return _ExpandableEventTile(
                      event: e,
                      iconSize: kIconSize,
                      titleSize: kTitleSize,
                      timeSize: kTimeSize,
                      descSize: kDescSize,
                      lineGapSmall: kLineGapSmall,
                      lineGapTiny: kLineGapTiny,
                      initiallyCollapsed: !isFirstForArtist,
                    );
                  }).toList(),
                  const SizedBox(height: 14),
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
          ),
        );
      },
    );
  }

  // --- Dialog Rébus ---
  void _showRebusFoundDialog(
      BuildContext context, {
        required String imagePath,
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bravo !',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu as dévoilé une nouvelle syllabe du rébus secret…',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note-la bien avant de fermer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5),
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

  // --- Helpers Date ---
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateLong(DateTime d) {
    const months = [
      "",
      "janvier",
      "février",
      "mars",
      "avril",
      "mai",
      "juin",
      "juillet",
      "août",
      "septembre",
      "octobre",
      "novembre",
      "décembre"
    ];
    const weekdays = [
      "",
      "Lundi",
      "Mardi",
      "Mercredi",
      "Jeudi",
      "Vendredi",
      "Samedi",
      "Dimanche"
    ];
    final wd = weekdays[d.weekday];
    final m = months[d.month];
    return "$wd ${d.day} $m ${d.year}";
  }

  String _formatDateCourt(DateTime d) {
    const months = [
      "",
      "janv.",
      "févr.",
      "mars",
      "avr.",
      "mai",
      "juin",
      "juil.",
      "août",
      "sept.",
      "oct.",
      "nov.",
      "déc."
    ];
    return "${d.day} ${months[d.month]} ${d.year}";
  }
}

// ================== Widgets de calendrier ==================

class _MonthView extends StatelessWidget {
  final DateTime monthStart;
  final Map<DateTime, List<AnimationEvent>> events;
  final Map<String, DateTime> firstAppearance;
  final void Function(DateTime day) onTapDay;
  final Color headerColor;
  final Color weekdayColor;
  final int? maxRows; // si non nul, tronque le mois à N rangées

  const _MonthView({
    Key? key,
    required this.monthStart,
    required this.events,
    required this.firstAppearance,
    required this.onTapDay,
    required this.headerColor,
    required this.weekdayColor,
    this.maxRows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final year = monthStart.year;
    final month = monthStart.month;
    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Lundi=1 ... Dimanche=7 ; on veut commencer par Lundi
    final startWeekday = firstOfMonth.weekday; // 1..7
    final leadingEmpty =
        (startWeekday + 6) % 7; // nb cases vides avant le 1er (Lundi=0)

    final totalCells = leadingEmpty + daysInMonth;
    final fullRows = (totalCells / 7.0).ceil();
    final rows = (maxRows == null) ? fullRows : maxRows!.clamp(0, fullRows);
    final cellsToShow = rows * 7;

    return Column(
      children: [
        const SizedBox(height: 8),
        _MonthHeader(date: firstOfMonth, color: headerColor),
        const SizedBox(height: 8),
        _WeekHeader(color: weekdayColor),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.02,
          ),
          itemCount: cellsToShow,
          itemBuilder: (context, index) {
            final dayNum = index - leadingEmpty + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final day = DateTime(year, month, dayNum);
            final key = DateTime(day.year, day.month, day.day);
            final hasEvents = events[key]?.isNotEmpty == true;

            return _DayCell(
              day: day,
              hasEvents: hasEvents,
              onTap: hasEvents ? () => onTapDay(day) : null,
            );
          },
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime date;
  final Color color;
  const _MonthHeader({Key? key, required this.date, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const months = [
      "",
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre"
    ];
    final label = "${months[date.month]} ${date.year}";
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black26,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final Color color;
  const _WeekHeader({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const days = ["L", "M", "M", "J", "V", "S", "D"];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool hasEvents;
  final VoidCallback? onTap;

  const _DayCell({
    Key? key,
    required this.day,
    required this.hasEvents,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
          hasEvents ? Colors.lightBlueAccent : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasEvents ? Colors.lightBlueAccent : const Color(0x22000000),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${day.day}",
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hasEvents ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ================== Tuiles d'événements (pop-up, extensibles) ==================

class _ExpandableEventTile extends StatefulWidget {
  final AnimationEvent event;
  final double iconSize;
  final double titleSize;
  final double timeSize;
  final double descSize;
  final double lineGapSmall;
  final double lineGapTiny;
  final bool initiallyCollapsed; // true = description coupée (reprises)

  const _ExpandableEventTile({
    Key? key,
    required this.event,
    required this.iconSize,
    required this.titleSize,
    required this.timeSize,
    required this.descSize,
    required this.lineGapSmall,
    required this.lineGapTiny,
    required this.initiallyCollapsed,
  }) : super(key: key);

  @override
  State<_ExpandableEventTile> createState() => _ExpandableEventTileState();
}

class _ExpandableEventTileState extends State<_ExpandableEventTile> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    String? trimmed(String? s) =>
        (s == null || s.trim().isEmpty) ? null : s.trim();

    final hasLongDesc = (widget.event.description ?? '').trim().length > 140;
    final maxLines = (_collapsed && hasLongDesc) ? 2 : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          if (widget.event.iconAsset != null &&
              widget.event.iconAsset!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Image.asset(
                widget.event.iconAsset!,
                width: widget.iconSize,
                height: widget.iconSize,
                fit: BoxFit.contain,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.event,
                size: 24,
                color: Colors.lightBlueAccent,
              ),
            ),
          const SizedBox(width: 10),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  widget.event.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: widget.titleSize,
                    height: 1.2,
                  ),
                ),

                // Horaire — place/size constantes
                if (trimmed(widget.event.horaire) != null) ...[
                  SizedBox(height: widget.lineGapTiny),
                  Text(
                    trimmed(widget.event.horaire!)!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.timeSize,
                      height: 1.25,
                    ),
                  ),
                ],

                // Lieu
                if (trimmed(widget.event.lieu) != null) ...[
                  SizedBox(height: widget.lineGapSmall),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trimmed(widget.event.lieu!)!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Description (coupée ou complète)
                if (trimmed(widget.event.description) != null) ...[
                  SizedBox(height: widget.lineGapSmall),
                  Text(
                    trimmed(widget.event.description!)!,
                    maxLines: maxLines,
                    overflow: (maxLines == null)
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.descSize,
                      height: 1.25,
                    ),
                  ),

                  // Bouton Voir plus / Voir moins (seulement si longue description)
                  if (hasLongDesc) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () =>
                            setState(() => _collapsed = !_collapsed),
                        child: Text(_collapsed ? 'Voir plus' : 'Voir moins'),
                      ),
                    ),
                  ],
                ],

                // Note
                if (trimmed(widget.event.note) != null) ...[
                  SizedBox(height: widget.lineGapSmall),
                  Text(
                    trimmed(widget.event.note!)!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Modèle d'événement ==================

class AnimationEvent {
  final String titre;
  final String? horaire;
  final String? lieu;
  final String? description;
  final String? note;
  final String? iconAsset;

  const AnimationEvent({
    required this.titre,
    this.horaire,
    this.lieu,
    this.description,
    this.note,
    this.iconAsset,
  });
}
