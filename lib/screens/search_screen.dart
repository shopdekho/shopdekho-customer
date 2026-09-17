import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'shop_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  String? _message;
  bool _isError = true;

  // Shop IDs look like PRY3GF765 / LKODNLRG — uppercase letters + digits.
  String? _validate(String input) {
    final clean = input.trim().toUpperCase();
    final regex = RegExp(r'^[A-Z0-9]{4,12}$');
    if (!regex.hasMatch(clean)) return null;
    return clean;
  }

  Future<void> _submit() async {
    final shopId = _validate(_controller.text);
    setState(() => _message = null);

    if (shopId == null) {
      setState(() {
        _isError = true;
        _message = 'Please enter a valid Shop ID.';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final shop = await _api.searchShopById(shopId);
      if (shop == null) {
        setState(() {
          _isError = true;
          _message = 'Shop not found';
        });
        return;
      }
      setState(() {
        _isError = false;
        _message = 'Shop found! Opening…';
      });
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ShopScreen(shopId: shopId)));
    } catch (_) {
      setState(() {
        _isError = true;
        _message = 'Could not search right now. Please try again.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Shop')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.orange, AppColors.orangeDark]),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 26),
              ),
              Text('Enter Shop ID', style: AppTheme.brandFont(size: 20, weight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text("Find your favorite shop by Shop ID",
                  style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
              const SizedBox(height: 22),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .5),
                decoration: InputDecoration(
                  hintText: 'Enter Shop ID (e.g. LKODNLRG)',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Search Shop'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: _isError ? AppColors.redTint : AppColors.leafTint,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(_message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _isError ? AppColors.red : AppColors.leafDark)),
                ),
              ],
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orangeTint,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.help_outline, color: AppColors.orangeDark, size: 16),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How to find Shop ID?',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          SizedBox(height: 3),
                          Text("Shop ID is usually shown on the shop's QR code and shop profile.",
                              style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.5)),
                        ],
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
}
