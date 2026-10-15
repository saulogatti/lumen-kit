import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Page dots for onboarding and galleries.
///
/// The active point becomes a pill with glow in the accent.
/// With [controller], follow the drag of the `PageView` frame by frame; without
/// it, use [index] and the point animates when changing.
/// ```dart
/// LumenPageIndicator(count: 4, controller: _pages)
/// ```
class LumenPageIndicator extends StatelessWidget {
  /// Creates the bookmark for [count] pages.
  const LumenPageIndicator({
    required this.count,
    super.key,
    this.controller,
    this.index = 0,
    this.onDotTapped,
    this.accentColor,
    this.dotSize = 8,
    this.activeWidth = 24,
    this.spacing = 8,
    this.semanticsLabel,
  }) : assert(count >= 0, 'count must be non-negative'),
       assert(activeWidth >= dotSize, 'activeWidth must be greater than or equal to dotSize');

  /// Number of pages.
  final int count;

  /// `PageView` Controller.
  ///
  /// Takes precedence over [index].
  final PageController? controller;

  /// Current page when there is no [controller].
  final int index;

  /// Called with the page of the touched point.
  ///
  /// `null` = non-touchable points.
  final ValueChanged<int>? onDotTapped;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Dot diameter.
  final double dotSize;

  /// Hotspot width.
  final double activeWidth;

  /// Space between points.
  final double spacing;

  /// Text read by screen readers for the current page (base 0) and total.
  ///
  /// Default: "2/5".
  final String Function(int index, int count)? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) {
      return _build(context, index.toDouble(), animated: true);
    }
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) =>
          _build(context, _pageOf(c), animated: false),
    );
  }

  Widget _build(BuildContext context, double page, {required bool animated}) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final idle = p.textMuted.scaleAlpha(0.35);
    final current = page.round().clamp(0, count == 0 ? 0 : count - 1);
    final label =
        semanticsLabel ?? (int i, int n) => '${i + 1}/$n';
    final duration = animated
        ? LumenMotion.duration(context, kLumenMediumDuration)
        : Duration.zero;

    Widget dot(int i) {
      final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
      final color = Color.lerp(idle, accent, t)!;
      final Widget body = AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        width: dotSize + (activeWidth - dotSize) * t,
        height: dotSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(dotSize / 2),
          boxShadow: s.shadows(
            t > 0
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55 * t),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      );
      if (onDotTapped == null) {
        return body;
      }
      return LumenPressable(
        onTap: () => onDotTapped!(i),
        borderRadius: BorderRadius.circular(12),
        selected: i == current,
        semanticLabel: label(i, count),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2, vertical: 8),
          child: body,
        ),
      );
    }

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: onDotTapped == null ? spacing : 0,
      children: <Widget>[for (int i = 0; i < count; i++) dot(i)],
    );
    if (onDotTapped != null || count == 0) {
      return row;
    }
    return Semantics(
      container: true,
      label: label(current, count),
      child: ExcludeSemantics(child: row),
    );
  }
}

/// `PageView` with rounded cards, the current page highlighted and a
/// [LumenPageIndicator] below.
///
/// For galleries and onboarding.
/// ```dart
/// LumenCarousel(
///   itemCount: fotos.length,
///   itemBuilder: (BuildContext context, int i) =>
///       Image.network(fotos[i], fit: BoxFit.cover),
/// )
/// ```
class LumenCarousel extends StatefulWidget {
  /// Create the carousel.
  const LumenCarousel({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.controller,
    this.height = 200,
    this.viewportFraction = 0.88,
    this.onPageChanged,
    this.showIndicator = true,
    this.accentColor,
    this.radius = 18,
    this.inactiveScale = 0.92,
  });

  /// Number of pages.
  final int itemCount;

  /// Builds the content of the `index` page.
  final IndexedWidgetBuilder itemBuilder;

  /// External controller.
  ///
  /// Without it, the carousel creates a com [viewportFraction].
  final PageController? controller;

  /// Page height (the indicator is below).
  final double height;

  /// Fraction of width occupied per page when there is no [controller] (below 1
  /// leaves the neighbors appearing).
  final double viewportFraction;

  /// Called when the current page changes.
  final ValueChanged<int>? onPageChanged;

  /// Shows [LumenPageIndicator] below.
  final bool showIndicator;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Radius of page corners.
  final double radius;

  /// Scale of pages out of focus.
  ///
  /// `1` turns off the effect.
  final double inactiveScale;

  @override
  State<LumenCarousel> createState() => _LumenCarouselState();
}

class _LumenCarouselState extends State<LumenCarousel> {
  PageController? _own;

  PageController get _controller =>
      widget.controller ??
      (_own ??= PageController(viewportFraction: widget.viewportFraction));

  @override
  void didUpdateWidget(covariant LumenCarousel old) {
    super.didUpdateWidget(old);
    final own = _own;
    if (own == null) {
      return;
    }
    if (widget.controller != null) {
      _own = null;
    } else if (old.viewportFraction != widget.viewportFraction) {
      _own = PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: _pageOf(own).round(),
      );
    } else {
      return;
    }
    // O PageView só solta o controller antigo no próprio didUpdateWidget,
    // depois deste; descartar agora quebraria o detach.
    WidgetsBinding.instance.addPostFrameCallback((_) => own.dispose());
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final d = LumenMotion.duration(context, kLumenMediumDuration * 2);
    if (d == Duration.zero) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page, duration: d, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final controller = _controller;
    final accent = widget.accentColor ?? p.primary;

    Widget page(BuildContext context, int i) {
      final Widget card = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: s.radius(widget.radius),
            color: p.surface,
            border: s.borderAll(color: accent.withValues(alpha: 0.35)),
            boxShadow: s.shadows(<BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ]),
          ),
          child: ClipRRect(
            borderRadius: s.radius(widget.radius),
            child: widget.itemBuilder(context, i),
          ),
        ),
      );
      if (widget.inactiveScale >= 1) {
        return card;
      }
      return AnimatedBuilder(
        animation: controller,
        child: card,
        builder: (context, child) {
          final current = _pageOf(controller);
          final t = (1 - (current - i).abs()).clamp(0.0, 1.0);
          return Transform.scale(
            scale: widget.inactiveScale + (1 - widget.inactiveScale) * t,
            child: child,
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.itemCount,
            onPageChanged: widget.onPageChanged,
            itemBuilder: page,
          ),
        ),
        if (widget.showIndicator && widget.itemCount > 1)
          LumenPageIndicator(
            count: widget.itemCount,
            controller: controller,
            accentColor: widget.accentColor,
            onDotTapped: _goTo,
          ),
      ],
    );
  }
}

/// Current page (fractional during dragging) of [c], or the initial one while
/// `PageView` has not yet measured the content.
double _pageOf(PageController c) {
  if (c.hasClients && c.positions.length == 1) {
    final pos = c.position;
    if (pos.hasContentDimensions) {
      return c.page ?? c.initialPage.toDouble();
    }
  }
  return c.initialPage.toDouble();
}
