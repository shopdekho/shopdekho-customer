import 'dart:async';

import 'package:flutter/material.dart';
import '../models/home_theme.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import 'nearby_screen.dart';
import 'qr_scanner_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _locationEnabled = false;
  int _notificationCount = 3;

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  // Starts with the safe built-in fallback so the home screen never looks
  // broken/blank — swapped for the remote config once it loads (colors and
  // banners can then be changed for a festival etc. just by editing the
  // JSON file, no app update needed).
  HomeTheme _theme = HomeTheme.fallback;

  // A lighter shade of the remote primary color, for gradient starts —
  // derived rather than configured separately, so festival configs only
  // need to set one primary color.
  Color get _primaryLight => Color.lerp(_theme.primary, Colors.white, .32)!;

  @override
  void initState() {
    super.initState();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!_bannerController.hasClients) return;

        final nextPage = (_currentBanner + 1) % _theme.banners.length;

        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      },
    );

    _loadRemoteTheme();
  }

  Future<void> _loadRemoteTheme() async {
    final theme = await RemoteConfigService.fetchHomeTheme();
    if (!mounted) return;
    setState(() {
      _theme = theme;
      _currentBanner = 0;
    });
    // Restart the controller on page 0 since the banner list/length may
    // have changed after the remote config loaded.
    if (_bannerController.hasClients) {
      _bannerController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _goNearby() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NearbyScreen(),
      ),
    );

    if (mounted) {
      setState(() {
        _locationEnabled = true;
      });
    }
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCarousel(),

                    const SizedBox(height: 18),

                    _buildPrimaryActions(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(),

                    const SizedBox(height: 13),

                    _buildBenefits(),

                    const SizedBox(height: 24),

                    _buildCommunityBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER (gradient + decorative veggie basket + badge)
  // ----------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEAF7E5),
            const Color(0xFFF7F9F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE9EEE9),
          ),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative vegetable basket, bleeding off the top-right edge
          // and fading into the background — no visible box/border, so it
          // blends with the gradient instead of sitting as a hard crop.
          Positioned(
            top: -18,
            right: -30,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.42, 0.92],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  _theme.headerImage,
                  width: 260,
                  height: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Small scattered leaf accents, echoing the ones in the
          // reference design.
          Positioned(
            top: 42,
            left: 168,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(
                Icons.eco_rounded,
                size: 15,
                color: _theme.primary.withOpacity(.45),
              ),
            ),
          ),
          Positioned(
            top: 96,
            right: 18,
            child: Transform.rotate(
              angle: 0.6,
              child: Icon(
                Icons.eco_rounded,
                size: 12,
                color: _theme.primary.withOpacity(.35),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            _primaryLight,
                            _theme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _theme.primary.withOpacity(.18),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ShopDekho',
                            style: AppTheme.brandFont(
                              size: 20,
                              weight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Your local shops, closer to you',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.line,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 21,
                            color: AppColors.ink,
                          ),
                        ),

                        if (_notificationCount > 0)
                          Positioned(
                            top: -3,
                            right: -3,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE23E3E),
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$_notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildLocationBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    return Material(
      color: const Color(0xFFF1F8F2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _goNearby,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: _theme.primary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationEnabled
                          ? 'Location enabled'
                          : 'Your location',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _theme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationEnabled
                          ? 'Showing shops near you'
                          : 'Set your location to find nearby shops',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _theme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _theme.primary.withOpacity(.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _locationEnabled
                          ? Icons.near_me_rounded
                          : Icons.navigation_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _locationEnabled ? 'Nearby' : 'Set',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HERO AUTO SLIDER
  // ----------------------------------------------------------

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _theme.banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBanner = index;
                });
              },
              itemBuilder: (_, index) {
                return _buildHeroBanner(
                  _theme.banners[index],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _theme.banners.length,
            (index) {
              final selected = index == _currentBanner;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                width: selected ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected
                      ? _theme.primary
                      : const Color(0xFFD5DDD6),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(HomeBanner banner) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          banner.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFF0D5131),
            );
          },
        ),

        // Dark green gradient over image, heavier on the left for text
        // readability (matches the darker, more solid banner look).
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xF0003D27),
                Color(0xB8003D27),
                Color(0x2E003D27),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            110,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(.25),
                  ),
                ),
                child: Text(
                  banner.tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Two-tone title: base text in white, highlighted portion
              // in a light mint-green, matching the reference design.
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: banner.titleStart,
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: banner.titleHighlight,
                      style: const TextStyle(color: Color(0xFFC9F2A0)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              Text(
                banner.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.86),
                  fontSize: 11.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // THREE MAIN ACTIONS
  // ----------------------------------------------------------

  Widget _buildPrimaryActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            background: _theme.nearbyTile.background,
            iconBackground: _theme.nearbyTile.iconBackground,
            iconColor: _theme.nearbyTile.iconColor,
            icon: Icons.location_on_rounded,
            decorativeIcon: Icons.location_city_rounded,
            title: _theme.nearbyTile.title,
            titleColor: _theme.nearbyTile.titleColor,
            titleFontSize: _theme.nearbyTile.titleFontSize,
            subtitle: _theme.nearbyTile.subtitle,
            subtitleColor: _theme.nearbyTile.subtitleColor,
            subtitleFontSize: _theme.nearbyTile.subtitleFontSize,
            fontFamily: _theme.fontFamily,
            onTap: _goNearby,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionTile(
            background: _theme.scanTile.background,
            iconBackground: _theme.scanTile.iconBackground,
            iconColor: _theme.scanTile.iconColor,
            icon: Icons.qr_code_scanner_rounded,
            decorativeIcon: Icons.qr_code_2_rounded,
            title: _theme.scanTile.title,
            titleColor: _theme.scanTile.titleColor,
            titleFontSize: _theme.scanTile.titleFontSize,
            subtitle: _theme.scanTile.subtitle,
            subtitleColor: _theme.scanTile.subtitleColor,
            subtitleFontSize: _theme.scanTile.subtitleFontSize,
            fontFamily: _theme.fontFamily,
            onTap: _openScanner,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionTile(
            background: _theme.searchTile.background,
            iconBackground: _theme.searchTile.iconBackground,
            iconColor: _theme.searchTile.iconColor,
            icon: Icons.search_rounded,
            decorativeIcon: Icons.storefront_rounded,
            title: _theme.searchTile.title,
            titleColor: _theme.searchTile.titleColor,
            titleFontSize: _theme.searchTile.titleFontSize,
            subtitle: _theme.searchTile.subtitle,
            subtitleColor: _theme.searchTile.subtitleColor,
            subtitleFontSize: _theme.searchTile.subtitleFontSize,
            fontFamily: _theme.fontFamily,
            onTap: _openSearch,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // WHY SHOPDEKHO
  // ----------------------------------------------------------

  Widget _buildSectionTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why ShopDekho?',
                style: AppTheme.brandFont(
                  size: 17,
                  weight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Everything you need from local shops',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.inkSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Icon(
          Icons.arrow_forward_rounded,
          size: 18,
          color: _theme.accentPurple,
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    final items = _theme.benefits;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(child: _BenefitCard(data: items[i])),
        ],
      ],
    );
  }

  // ----------------------------------------------------------
  // COMMUNITY BANNER
  // ----------------------------------------------------------

  Widget _buildCommunityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        16,
        18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B20B8),
            Color(0xFF6D3BE5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B20B8).withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Faint decorative sparkle accents in the background.
          Positioned(
            top: 6,
            right: 70,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: Colors.white.withOpacity(.35),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 96,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 8,
              color: Colors.white.withOpacity(.25),
            ),
          ),

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Support Local, Build Better',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Every purchase helps local businesses grow.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF4B20B8),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION TILE
// ============================================================

class _ActionTile extends StatelessWidget {
  final Color background;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final IconData decorativeIcon;
  final String title;
  final Color titleColor;
  final double titleFontSize;
  final String subtitle;
  final Color subtitleColor;
  final double subtitleFontSize;
  final String? fontFamily;
  final VoidCallback onTap;

  const _ActionTile({
    required this.background,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.decorativeIcon,
    required this.title,
    required this.titleColor,
    required this.titleFontSize,
    required this.subtitle,
    required this.subtitleColor,
    required this.subtitleFontSize,
    this.fontFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          children: [
            // Large, very faint decorative icon in the bottom-left,
            // matching the subtle background illustration in the design.
            Positioned(
              bottom: -14,
              left: -14,
              child: Icon(
                decorativeIcon,
                size: 70,
                color: iconColor.withOpacity(.08),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                13,
                10,
                13,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 11),

                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: titleFontSize,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: subtitleFontSize,
                      height: 1.3,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.78),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// BENEFIT CARD (Why ShopDekho row) — fully driven by BenefitTheme
// (colors, icon, decorative icon, title/subtitle text+size all come
// from the remote JSON's "benefits" array).
// ============================================================

class _BenefitCard extends StatelessWidget {
  final BenefitTheme data;

  const _BenefitCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 172,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [data.backgroundStart, data.backgroundEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Large, faint decorative icon bottom-right — same generic
          // pattern as the action tiles, so it stays fully JSON-driven
          // instead of needing bespoke shapes per card.
          Positioned(
            bottom: -14,
            right: -10,
            child: Icon(
              data.decorativeIcon,
              size: 64,
              color: data.iconColor.withOpacity(.14),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 15, 11, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: data.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: 18,
                    color: data.iconColor,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: data.titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: data.titleColor,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: data.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: data.subtitleColor,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}