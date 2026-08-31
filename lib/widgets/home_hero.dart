import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  final VoidCallback onExploreTools;
  final VoidCallback onExploreMarket;
  final VoidCallback onAbout;

  const HomeHero({
    super.key, 
    required this.onExploreTools,
    required this.onExploreMarket,
    required this.onAbout,
    });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 700;

    return Container(
      width: double.infinity,
      height: screenHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 24 : 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6), Color(0xFF14B8A6)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildRibbon(isMobile),
            const Spacer(),
            _buildHeroContent(isMobile),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildRibbon(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 12,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            "ECONLAB LITE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),

          const Spacer(),

          if (!isMobile) ...[
            _NavItem(label: "TOOLS", onTap: onExploreTools),
            _NavItem(label: "MARKETS", onTap: onExploreMarket), 
            _NavItem(label: "ABOUT", onTap: onAbout),
          ],

          if (isMobile) const Icon(Icons.menu, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHeroContent(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "MASTER YOUR MONEY",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 42 : 72,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          "Learn Economics. Caculate Smarter. Invest with Confidence.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: isMobile ? 16 : 22,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 36),

        ElevatedButton(
          onPressed: onExploreTools,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Explore Tools",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 8,
          ),
          child: Text(label, style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),),
        ),
      ), 
    );
  }
}
