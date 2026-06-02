import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import 'plicometry_input_screen.dart';

class MethodSelectionScreen extends StatelessWidget {
  const MethodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text('METODO DI CALCOLO',
            style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Scegli il protocollo più adatto al tuo profilo e obiettivo.',
            style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 20),
          _MethodCard(
            metodo: MetodoPlicometria.jacksonPollock7,
            title: 'Jackson & Pollock',
            subtitle: '7 pliche · Uomo e Donna',
            tag: 'MASSIMA PRECISIONE',
            tagColor: const Color(0xFF00C070),
            icon: Icons.analytics_rounded,
            description:
                'Il protocollo più completo e accurato. Consigliato per atleti e '
                'per chi richiede la massima precisione nella valutazione della '
                'composizione corporea.',
          ),
          const SizedBox(height: 12),
          _MethodCard(
            metodo: MetodoPlicometria.jacksonPollock3,
            title: 'Jackson & Pollock',
            subtitle: '3 pliche · Uomo e Donna',
            tag: 'PALESTRA',
            tagColor: const Color(0xFF3B9FF2),
            icon: Icons.fitness_center_rounded,
            description:
                'Protocollo rapido e affidabile per misurazioni frequenti. Ottimo '
                'rapporto tra semplicità e precisione, ideale per il monitoraggio '
                'settimanale in palestra.',
          ),
          const SizedBox(height: 12),
          _MethodCard(
            metodo: MetodoPlicometria.durninWomersley,
            title: 'Durnin & Womersley',
            subtitle: '4 pliche · Uomo e Donna',
            tag: 'CLINICO',
            tagColor: const Color(0xFF9B6DDE),
            icon: Icons.biotech_rounded,
            description:
                'Validato su ampia casistica, ideale per valutazioni cliniche e '
                'studi epidemiologici. Affidabile per adulti con diversi livelli '
                'di attività fisica, dal sedentario al moderatamente attivo.',
          ),
          const SizedBox(height: 12),
          _MethodCard(
            metodo: MetodoPlicometria.faulkner,
            title: 'Faulkner',
            subtitle: '4 pliche · Atleti',
            tag: 'SPORTIVI',
            tagColor: const Color(0xFFFF8C42),
            icon: Icons.speed_rounded,
            description:
                'Sviluppato specificamente per atleti, con particolare riferimento '
                'ai nuotatori. Semplice e rapido, ampiamente utilizzato in ambito '
                'sportivo agonistico.',
          ),
          const SizedBox(height: 28),
          _SectionDivider(label: 'SENZA PLICOMETRO'),
          const SizedBox(height: 16),
          _MethodCard(
            metodo: MetodoPlicometria.usNavy,
            title: 'US Navy',
            subtitle: '2–3 circonferenze · Uomo e Donna',
            tag: 'FACILE',
            tagColor: const Color(0xFF26C9A7),
            icon: Icons.straighten_rounded,
            description:
                'Sviluppato dalla marina militare americana. Non richiede plicometro: '
                'basta un metro da sarto per misurare collo, vita e fianchi. '
                'Pratico per stime rapide, meno preciso della plicometria.',
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(child: Divider(color: p.cardBorder, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: TextStyle(
                  color: p.textMuted,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: p.cardBorder, height: 1)),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final MetodoPlicometria metodo;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final IconData icon;
  final String description;

  const _MethodCard({
    required this.metodo,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlicometryInputScreen(metodo: metodo)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.accent.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: p.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: p.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(tag,
                      style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description,
                style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.55)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Seleziona',
                    style: TextStyle(color: p.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: p.accent, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
