import 'package:flutter/material.dart';

/// Reusable animated shimmer wrapper using a neutral gray gradient sweep.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF222225) : const Color(0xFFE4E4E7);
    final highlightColor =
        isDark ? const Color(0xFF323237) : const Color(0xFFF4F4F5);
    final borderColor =
        isDark ? const Color(0xFF333338) : const Color(0xFFD4D4D8);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + slide, -0.2),
              end: Alignment(0.5 + slide, 0.2),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loading placeholder matching the Home / Weather Screen layout.
class WeatherSkeleton extends StatelessWidget {
  final double maxWidth;

  const WeatherSkeleton({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final gridColumns = maxWidth >= 600 ? 4 : 2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const ShimmerBox(width: double.infinity, height: 176),
        const SizedBox(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: ShimmerBox(width: 150, height: 18, borderRadius: 4),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, _) => const ShimmerBox(width: 78, height: 126),
          ),
        ),
        const SizedBox(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: ShimmerBox(width: 170, height: 18, borderRadius: 4),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: gridColumns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: maxWidth >= 600 ? 1.25 : 1.45,
          children: List.generate(
            4,
            (_) => const ShimmerBox(width: double.infinity, height: 100),
          ),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: ShimmerBox(width: 210, height: 18, borderRadius: 4),
        ),
        const SizedBox(height: 10),
        const ShimmerBox(width: double.infinity, height: 280),
      ],
    );
  }
}

/// Skeleton loading placeholder matching the Search / Location Screen list.
class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const ShimmerBox(width: double.infinity, height: 72),
    );
  }
}
