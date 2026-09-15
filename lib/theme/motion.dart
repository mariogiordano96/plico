import 'package:flutter/material.dart';

/// Durate e curve di animazione standard, per un linguaggio di movimento
/// coerente in tutta l'app (Fase 2 di docs/attrattiva_ux.md).
class AppMotion {
  const AppMotion._();

  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 450);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;

  /// Ritardo tra un elemento e il successivo nelle liste con entrata a
  /// cascata (vedi [StaggeredListItem]).
  static const staggerStep = Duration(milliseconds: 40);
}

/// Transizione di pagina custom (fade + leggero slide verticale), usata al
/// posto dello zoom di default su Android/desktop per coerenza col resto
/// dell'app. iOS/macOS restano su [CupertinoPageTransitionsBuilder] per non
/// perdere lo swipe-back nativo.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Fa entrare [child] con un fade + slide verso l'alto, ritardato in base a
/// [index] — usato per far apparire le liste (esercizi, alimenti, storico)
/// a cascata invece che tutte insieme. Il ritardo è limitato ai primi
/// [maxStaggeredItems] elementi: oltre non ha senso accumulare secondi di
/// attesa per gli elementi in fondo a liste lunghe (es. catalogo esercizi).
class StaggeredListItem extends StatefulWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.maxStaggeredItems = 12,
  });

  final int index;
  final Widget child;
  final int maxStaggeredItems;

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.medium);
    final curved = CurvedAnimation(parent: _controller, curve: AppMotion.enter);
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);

    final step = widget.index.clamp(0, widget.maxStaggeredItems);
    final delay = AppMotion.staggerStep * step;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
