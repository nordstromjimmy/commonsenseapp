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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FactsProvider>().loadInitial();
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
    // Load more when nearing end
    if (_currentIndex >= total - 5) {
      provider.loadMore();
    }
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Common Knowledge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _userName.isNotEmpty
                                ? 'Hello, $_userName 👋'
                                : 'Learn something new today',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      // Progress indicator
                      // HIDE NUMBER OF QUESTIONS AVAILABLE
                      /*                       if (provider.facts.isNotEmpty)
                        Text(
                          '${_currentIndex + 1} / ${provider.facts.length}',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ), */
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Category filter
                if (provider.categories.isNotEmpty)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final isSelected = isAll
                            ? provider.selectedCategoryId == null
                            : provider.categories[index - 1].id ==
                                  provider.selectedCategoryId;
                        final label = isAll
                            ? '✨ All'
                            : '${provider.categories[index - 1].icon} ${provider.categories[index - 1].name}';
                        return GestureDetector(
                          onTap: () {
                            setState(() => _currentIndex = 0);
                            provider.selectCategory(
                              isAll ? null : provider.categories[index - 1].id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // Facts feed
                Expanded(
                  child: provider.isLoading && provider.facts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        )
                      : provider.facts.isEmpty
                      ? const Center(
                          child: Text(
                            'No facts found',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : PageView.builder(
                          key: ValueKey(provider.selectedCategoryId),
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (i) =>
                              setState(() => _currentIndex = i),
                          itemCount: provider.facts.length,
                          itemBuilder: (context, index) {
                            final Fact fact = provider.facts[index];
                            return SingleChildScrollView(
                              child: FactCard(
                                key: ValueKey(fact.id),
                                fact: fact,
                                onNext: () =>
                                    _goNext(provider.facts.length, provider),
                              ),
                            );
                          },
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
