import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Sliver counterpart of `LumenAppBar`, for a [CustomScrollView] where the
/// app bar scrolls together with the body.
///
/// With [pinned], the bar stays at the top while the content scrolls under
/// it. With [floating], it comes back as soon as the user scrolls up. Set
/// [expandedHeight] to start with a large title that collapses into the
/// toolbar as the content scrolls.
///
/// The bar is transparent at rest. Once content scrolls under it, it gains a
/// background from `palette.backgroundDeep`, blurred when the style has
/// [LumenStyle.blurSigma].
///
/// ```dart
/// CustomScrollView(
///   slivers: <Widget>[
///     const LumenSliverAppBar(
///       title: 'Orders',
///       subtitle: '12 open',
///       expandedHeight: 140,
///     ),
///     LumenSliverList(
///       itemCount: orders.length,
///       itemBuilder: (BuildContext context, int i) =>
///           LumenListTile(title: orders[i].name),
///     ),
///   ],
/// )
/// ```
class LumenSliverAppBar extends StatelessWidget {
  /// Main title displayed in the app bar.
  final String title;

  /// Auxiliary text displayed below [title].
  final String? subtitle;

  /// Widget displayed before the title.
  final Widget? leading;

  /// Actions displayed on the right side.
  final List<Widget>? actions;

  /// Bottom decorative line gradient.
  ///
  /// Default: `palette.accentGradient`.
  final Gradient? accentGradient;

  /// Height of the toolbar, without the status bar inset.
  final double height;

  /// Height of the bar before any scrolling, without the status bar inset.
  ///
  /// The space below the toolbar shows a large [title] and the [subtitle].
  /// `null` keeps the bar at [height]. Must not be smaller than [height].
  final double? expandedHeight;

  /// Whether the toolbar stays visible at the top while the content scrolls.
  final bool pinned;

  /// Whether the bar reappears as soon as the user scrolls towards it.
  final bool floating;

  /// Whether to display the bottom decorative line.
  final bool showDivider;

  /// Whether the bar sits at the top of the screen and pads the status bar.
  ///
  /// Set it to `false` when the scroll view is not under the status bar.
  final bool primary;

  /// Creates a neon app bar for a [CustomScrollView].
  const LumenSliverAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.accentGradient,
    this.height = 64,
    this.expandedHeight,
    this.pinned = true,
    this.floating = false,
    this.showDivider = true,
    this.primary = true,
  }) : assert(height > 0, 'height must be greater than zero.'),
       assert(
         expandedHeight == null || expandedHeight >= height,
         'expandedHeight must not be smaller than height.',
       );

  @override
  Widget build(BuildContext context) {
    final topPadding = primary ? MediaQuery.paddingOf(context).top : 0.0;
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _LumenSliverAppBarDelegate(
        title: title,
        subtitle: subtitle,
        leading: leading,
        actions: actions,
        accentGradient: accentGradient,
        height: height,
        expandedHeight: expandedHeight,
        showDivider: showDivider,
        topPadding: topPadding,
      ),
    );
  }
}

class _LumenSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Gradient? accentGradient;
  final double height;
  final double? expandedHeight;
  final bool showDivider;
  final double topPadding;

  const _LumenSliverAppBarDelegate({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.accentGradient,
    required this.height,
    required this.expandedHeight,
    required this.showDivider,
    required this.topPadding,
  });

  double get _dividerHeight => showDivider ? 2 : 0;

  @override
  double get minExtent => topPadding + height + _dividerHeight;

  @override
  double get maxExtent => topPadding + (expandedHeight ?? height) + _dividerHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final text = Theme.of(context).textTheme;
    final g = accentGradient ?? p.accentGradient;

    final range = maxExtent - minExtent;
    // 0 = fully expanded, 1 = collapsed into the toolbar.
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    // The two titles never show together: the large one is gone at 0.6 and
    // the toolbar one starts there. Opacity 0 also hides them from semantics.
    final largeOpacity = (1 - t / 0.6).clamp(0.0, 1.0);
    final toolbarOpacity = ((t - 0.6) / 0.4).clamp(0.0, 1.0);
    final raised = overlapsContent || shrinkOffset > 0;

    return style.frost(
      child: AnimatedContainer(
        duration: LumenMotion.duration(context, kLumenFastDuration),
        color: p.backgroundDeep.withValues(alpha: raised ? style.surfaceAlpha(0.92) : 0),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              SizedBox(height: topPadding),
              SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      if (leading != null) ...<Widget>[leading!, const SizedBox(width: 12)],
                      Expanded(
                        child: Opacity(
                          opacity: toolbarOpacity,
                          child: _Titles(
                            title: title,
                            subtitle: subtitle,
                            titleStyle: text.titleLarge,
                            subtitleStyle: text.bodySmall,
                          ),
                        ),
                      ),
                      if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
                    ],
                  ),
                ),
              ),
              if (expandedHeight != null)
                Expanded(
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.bottomLeft,
                      // The titles keep their natural height and stay anchored
                      // to the bottom; whatever does not fit is clipped at the
                      // top instead of overflowing, while collapsing or with a
                      // large text scale.
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: Opacity(
                        opacity: largeOpacity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _Titles(
                            title: title,
                            subtitle: subtitle,
                            titleStyle: text.headlineMedium,
                            subtitleStyle: text.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (showDivider)
                Container(height: 2, decoration: BoxDecoration(gradient: style.fill(g))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_LumenSliverAppBarDelegate oldDelegate) =>
      title != oldDelegate.title ||
      subtitle != oldDelegate.subtitle ||
      leading != oldDelegate.leading ||
      actions != oldDelegate.actions ||
      accentGradient != oldDelegate.accentGradient ||
      height != oldDelegate.height ||
      expandedHeight != oldDelegate.expandedHeight ||
      showDivider != oldDelegate.showDivider ||
      topPadding != oldDelegate.topPadding;
}

class _Titles extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const _Titles({
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Semantics(
        header: true,
        child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
      ),
      if (subtitle case final String subtitle) ...<Widget>[
        const SizedBox(height: 2),
        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: subtitleStyle),
      ],
    ],
  );
}
