import 'package:flutter/material.dart';
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

  void _goNearby() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyScreen()),
    );
    setState(() => _locationEnabled = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ActionCard(
                      tint: AppColors.leafTint,
                      iconColor: AppColors.leafDark,
                      icon: Icons.location_on,
                      title: 'Nearby Shops',
                      subtitle: 'Find vegetable shops near your location',
                      onTap: _goNearby,
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      tint: AppColors.blueTint,
                      iconColor: AppColors.blue,
                      icon: Icons.qr_code_scanner,
                      title: 'Scan Shop QR',
                      subtitle: 'Scan a ShopDekho QR code to open shop',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const QrScannerScreen())),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      tint: AppColors.orangeTint,
                      iconColor: AppColors.orangeDark,
                      icon: Icons.search,
                      title: 'Search Shop',
                      subtitle: 'Enter Shop ID to find your shop',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SearchScreen())),
                    ),
                    const SizedBox(height: 22),
                    Text('Why ShopDekho?', style: AppTheme.brandFont(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildWhyGrid(),
                    const SizedBox(height: 20),
                    _buildBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    colors: [AppColors.leafLight, AppColors.leafDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ShopDekho', style: AppTheme.brandFont()),
                    const Text('Local Shops, Fresh Vegetables',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.inkSoft)),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.notifications_none, size: 18, color: AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _goNearby,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.leaf, size: 14),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _locationEnabled ? 'Location enabled' : 'Set your location',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                ),
                Text(
                  _locationEnabled ? 'View nearby shops' : 'Use my location',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.leafDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyGrid() {
    final items = [
      (Icons.storefront, AppColors.leafDark, 'Local Shops', 'Support local business'),
      (Icons.eco, AppColors.leafDark, 'Fresh Vegetables', 'Daily fresh & quality produce'),
      (Icons.moped, AppColors.orangeDark, 'Home Delivery', 'Get it delivered to your home'),
      (Icons.verified_user, AppColors.purple, 'Trusted Shops', 'Verified & trusted shops'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: items.map((it) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(it.$1, size: 18, color: it.$2),
              const SizedBox(height: 4),
              Text(it.$3, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(it.$4, style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(colors: [AppColors.leafTint, Color(0xFFF3FBF3)]),
        border: Border.all(color: const Color(0xFFD8F0DD)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Eat Fresh, Stay Healthy', style: AppTheme.brandFont(size: 15.5, color: AppColors.leafDark)),
              const SizedBox(height: 4),
              const SizedBox(
                width: 210,
                child: Text('Find and support your local vegetable shops',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.5)),
              ),
            ],
          ),
          const Positioned(right: 0, bottom: 0, child: Text('🥕🥦🍅', style: TextStyle(fontSize: 30))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color tint;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.tint,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.65),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkFaint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
