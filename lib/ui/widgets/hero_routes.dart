import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared Hero helpers — slow flight, stable on pop-back.
class HeroRoutes {
  HeroRoutes._();

  static const Duration duration = Duration(milliseconds: 650);
  static const Curve curve = Curves.easeInOutCubic;

  static PageRouteBuilder<T> build<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: true,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: curve);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  /// Shuttle paints the SAME image widget on the overlay — no blank box.
  static Widget flightBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    final Hero toHero = toHeroContext.widget as Hero;
    final Hero fromHero = fromHeroContext.widget as Hero;
    // On pop, fly the detail image (from) — it is already decoded.
    final Widget target = flightDirection == HeroFlightDirection.push
        ? toHero.child
        : fromHero.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.88, end: 1).animate(curved),
      child: Material(
        type: MaterialType.transparency,
        child: target,
      ),
    );
  }
}

class SlowHero extends StatelessWidget {
  const SlowHero({
    super.key,
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: HeroRoutes.flightBuilder,
      child: child,
    );
  }
}

/// Same widget type on grid + detail so Hero pop does not flash blank.
class HeroNetworkImage extends StatelessWidget {
  const HeroNetworkImage({
    super.key,
    required this.url,
    required this.height,
    this.fit = BoxFit.cover,
    this.fallbackEmoji = '🍎',
  });

  final String? url;
  final double height;
  final BoxFit fit;
  final String fallbackEmoji;

  @override
  Widget build(BuildContext context) {
    final u = url;
    final fallback = ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(fallbackEmoji, style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
    if (u == null || u.isEmpty || !u.startsWith('http')) {
      return fallback;
    }
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CachedNetworkImage(
          imageUrl: u,
          fit: fit,
          // No fade on grid — avoids empty frame when Hero returns.
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholderFadeInDuration: Duration.zero,
          memCacheWidth: 720,
          filterQuality: FilterQuality.medium,
          // Reuse cache immediately when flying back.
          maxWidthDiskCache: 720,
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}
