import 'package:commonsense_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/facts_provider.dart';
import '../models/fact.dart';
import '../widgets/fact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String _userName = '';

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<FactsProvider>();
      await provider.loadLanguage();
      await provider.loadInitial();
    });
    _loadUserName();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext(int total, FactsProvider provider) {
    if (_currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    if (_currentIndex >= total - 5) {
      provider.loadMore();
    }
  }

  void _openCategorySheet(BuildContext context, FactsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                provider.strings.browseCategories,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildCategoryRow(
                      label: provider.strings.all,
                      isSelected: provider.selectedCategoryId == null,
                      onTap: () {
                        setState(() => _currentIndex = 0);
                        provider.selectCategory(null);
                        Navigator.pop(context);
                      },
                    ),
                    ...provider.categories.map(
                      (cat) => _buildCategoryRow(
                        label: cat.name,
                        isSelected: cat.id == provider.selectedCategoryId,
                        onTap: () {
                          setState(() => _currentIndex = 0);
                          provider.selectCategory(cat.id);
                          Navigator.pop(context);
                        },
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

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Consumer<FactsProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KNOWLY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _userName.isNotEmpty
                                  ? '${provider.strings.hello}, $_userName 👋'
                                  : provider.strings.learnSomethingNew,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings button
                      IconButton(
                        icon: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                          _loadUserName();
                          if (mounted) {
                            final provider = context.read<FactsProvider>();
                            await provider.loadLanguage();
                            await provider.loadInitial();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Category filter
                if (provider.categories.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // All chip
                        _buildChip(
                          label: provider.strings.all,
                          isSelected: provider.selectedCategoryId == null,
                          onTap: () {
                            setState(() => _currentIndex = 0);
                            provider.selectCategory(null);
                          },
                        ),
                        const SizedBox(width: 8),

                        // Selected category chip
                        if (provider.selectedCategoryId != null) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Builder(
                              builder: (context) {
                                final selected = provider.categories.firstWhere(
                                  (c) => c.id == provider.selectedCategoryId,
                                  orElse: () => provider.categories.first,
                                );
                                return _buildChip(
                                  label: selected.name,
                                  isSelected: true,
                                  onTap: () {},
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        const Spacer(),

                        // Browse button
                        GestureDetector(
                          onTap: () => _openCategorySheet(context, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  provider.strings.browse,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.tune_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Facts feed
                Expanded(
                  child: provider.isLoading && provider.facts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        )
                      : provider.facts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off_rounded,
                                color: Color(0xFF334155),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.strings.couldNotLoad,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.strings.checkConnection,
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => provider.retry(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  provider.strings.tryAgain,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              key: ValueKey(provider.selectedCategoryId),
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              onPageChanged: (i) =>
                                  setState(() => _currentIndex = i),
                              itemCount: provider.facts.length,
                              itemBuilder: (context, index) {
                                final Fact fact = provider.facts[index];
                                final category = provider.categories
                                    .where((c) => c.id == fact.categoryId)
                                    .firstOrNull;
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 44),
                                      FactCard(
                                        key: ValueKey(fact.id),
                                        fact: fact,
                                        category: category,
                                        strings: provider.strings,
                                        onNext: () => _goNext(
                                          provider.facts.length,
                                          provider,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // Scroll hint
                            if (_currentIndex == 0)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      size: 32,
                                    ),
                                    Text(
                                      provider.strings.scrollForAnother,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
