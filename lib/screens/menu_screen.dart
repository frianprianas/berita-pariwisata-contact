import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'bookmarks_screen.dart';
import 'reading_goals_screen.dart';
import 'collections_screen.dart';
import 'notes_screen.dart';
import 'help_screen.dart';
import 'feedback_screen.dart';
import 'about_screen.dart';
import '../providers/theme_provider.dart';
import '../widgets/dashboard_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  String? _latestArticleTitle;
  bool _isLoadingArticle = true;

  @override
  void initState() {
    super.initState();
    _loadLatestArticle();
    
    // Auto-rotate banner every 3 seconds (4 banners)
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLatestArticle() async {
    try {
      final response = await http.get(
        Uri.parse('https://koran-pariwisata.com/wp-json/wp/v2/posts?per_page=1&categories=3&_fields=title'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _latestArticleTitle = data[0]['title']['rendered'];
            _isLoadingArticle = false;
          });
        } else if (mounted) {
          setState(() {
            _latestArticleTitle = 'Berita Pariwisata Terkini';
            _isLoadingArticle = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _latestArticleTitle = 'Berita Pariwisata Terkini';
          _isLoadingArticle = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _latestArticleTitle = 'Berita Pariwisata Terkini';
          _isLoadingArticle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.brightness == Brightness.dark;
    
    // Platform-adaptive scaffold
    if (Platform.isAndroid) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _buildContent(context, themeProvider, isDarkMode),
        ),
      );
    }
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: _buildContent(context, themeProvider, isDarkMode),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return CustomScrollView(
          slivers: [
            // Header dengan theme toggle dan banner carousel
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Theme Toggle Button (Top Right)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => themeProvider.toggleTheme(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5.resolveFrom(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                              color: CupertinoColors.label.resolveFrom(context),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Banner Carousel with Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.3, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentBanner(context),
                  ),
                  
                  // Banner indicators (dots)
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        key: ValueKey('indicator_$index'),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentBannerIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentBannerIndex == index
                              ? const Color(0xFFFFB800)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Dashboard Card - Showcase Native Features
                  const DashboardCard(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Menu Cards Grid - Circular Design
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.80,
                ),
                delegate: SliverChildListDelegate([
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.news,
                    label: 'Berita',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    label: 'Statistik',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.bookmark_fill,
                    label: 'Bookmark',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const BookmarksScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.flame_fill,
                    label: 'Target',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ReadingGoalsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.doc_text_fill,
                    label: 'Catatan',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const NotesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCircularMenuCard(
                    context: context,
                    icon: CupertinoIcons.folder_fill,
                    label: 'Koleksi',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const CollectionsScreen(),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
            
            // Additional Menu Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: Text(
                        'Lainnya',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Platform.isIOS
                              ? CupertinoColors.label.resolveFrom(context)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    _buildListMenuItem(
                      context: context,
                      icon: CupertinoIcons.question_circle_fill,
                      label: 'Bantuan & Tutorial',
                      subtitle: 'Pelajari semua fitur aplikasi',
                      color: const Color(0xFF667EEA),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildListMenuItem(
                      context: context,
                      icon: CupertinoIcons.chat_bubble_text_fill,
                      label: 'Feedback & Dukungan',
                      subtitle: 'Berikan masukan untuk aplikasi',
                      color: const Color(0xFF11998E),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildListMenuItem(
                      context: context,
                      icon: CupertinoIcons.info_circle_fill,
                      label: 'Tentang Aplikasi',
                      subtitle: 'Informasi & versi aplikasi',
                      color: const Color(0xFF764BA2),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'Developed by Frian Prianas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Platform.isIOS
                            ? CupertinoColors.systemGrey.resolveFrom(context)
                            : Colors.grey,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 2.5.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Platform.isIOS
                            ? CupertinoColors.systemGrey2.resolveFrom(context)
                            : Colors.grey[600],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }

  // Circular Menu Card Builder
  Widget _buildCircularMenuCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    // Platform-adaptive button
    final button = Platform.isIOS 
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: _buildCardContent(context, icon, label, gradient),
          )
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: _buildCardContent(context, icon, label, gradient),
          );
    
    return button;
  }

  Widget _buildCardContent(BuildContext context, IconData icon, String label, Gradient gradient) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Icon Container with Gold Gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFD700), // Gold
                Color(0xFFFFB800), // Deep Gold
                Color(0xFFFFA500), // Orange Gold
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 8),
        // Label Text with constraints
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Platform.isIOS
                  ? CupertinoColors.label.resolveFrom(context)
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Get current banner based on index
  Widget _buildCurrentBanner(BuildContext context) {
    switch (_currentBannerIndex) {
      case 0:
        return _buildBannerWithLogo(context);
      case 1:
        return _buildLatestNewsBanner(context);
      case 2:
        return _buildBannerCard(
          key: const ValueKey('banner_2'),
          context: context,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF6F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: CupertinoIcons.flag_fill,
          title: 'Visit Indonesia',
          subtitle: 'Discover Amazing Tourism Destinations',
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        );
      case 3:
        return _buildBannerCard(
          key: const ValueKey('banner_3'),
          context: context,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: CupertinoIcons.info_circle_fill,
          title: 'Tentang Aplikasi',
          subtitle: '8 Fitur Native • 100% Offline Ready',
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const AboutScreen(),
              ),
            );
          },
        );
      default:
        return _buildBannerWithLogo(context);
    }
  }

  // Banner Latest News (Banner 2) - Fokus ke Kategori Berita
  Widget _buildLatestNewsBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Langsung ke HomeScreen dengan fokus kategori Berita (ID: 3)
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(
              categoryId: 3,
              categoryName: 'Berita',
            ),
          ),
        );
      },
      child: Container(
        key: const ValueKey('banner_1'),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8B35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.news,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Subtitle (Judul Berita Terakhir)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berita Terkini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _isLoadingArticle
                      ? const CupertinoActivityIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _latestArticleTitle ?? 'Berita Pariwisata Terbaru',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.95),
                            decoration: TextDecoration.none,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Banner with Logo (Banner 1)
  Widget _buildBannerWithLogo(BuildContext context) {
    return Container(
      key: const ValueKey('banner_0'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFB800), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo dengan ukuran diperlebar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo_kp.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Koran Pariwisata',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Platform Pengetahuan\nPariwisata Indonesia',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    decoration: TextDecoration.none,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Banner Card Builder (untuk banner 2 & 3)
  Widget _buildBannerCard({
    required Key key,
    required BuildContext context,
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // List Menu Item Builder (for "Lainnya" section)
  Widget _buildListMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Platform.isIOS
              ? CupertinoColors.systemBackground.resolveFrom(context)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Platform.isIOS
                ? CupertinoColors.separator.resolveFrom(context)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Platform.isIOS
                          ? CupertinoColors.label.resolveFrom(context)
                          : Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Platform.isIOS
                          ? CupertinoColors.secondaryLabel.resolveFrom(context)
                          : Colors.grey.shade600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: Platform.isIOS
                  ? CupertinoColors.systemGrey.resolveFrom(context)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Segera Hadir'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Fitur $feature akan tersedia dalam update mendatang.'),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Hubungi Kami',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // Contact items
              _buildContactItem(
                context: context,
                icon: CupertinoIcons.person_fill,
                title: 'Narahubung',
                subtitle: 'Joni Setia Budi',
              ),
              _buildContactItem(
                context: context,
                icon: CupertinoIcons.phone_fill,
                title: 'Telepon / WhatsApp',
                subtitle: '085182828181',
              ),
              _buildContactItem(
                context: context,
                icon: CupertinoIcons.globe,
                title: 'Website',
                subtitle: 'www.koran-pariwisata.com',
              ),
              const Spacer(),
              // Footer
                  Column(
                children: [
                  Text(
                    'Developed by Frian Prianas',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 2.5.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey2.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 500,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // App Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  CupertinoIcons.airplane,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Koran Pariwisata',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 2.5.0 (1)',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur Utama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('📰 Berita pariwisata Indonesia terkini'),
                      _buildFeatureItem('📊 Statistik & insights pembacaan'),
                      _buildFeatureItem('🎤 Text-to-Speech dengan highlighting'),
                      _buildFeatureItem('🔍 Kaca pembesar ala iOS'),
                      _buildFeatureItem('📥 Mode offline & sync otomatis'),
                      _buildFeatureItem('🌙 Dark mode support'),
                      const SizedBox(height: 20),
                      const Text(
                        'Tentang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aplikasi Koran Pariwisata Indonesia dikembangkan oleh Frian Prianas untuk menyediakan informasi pariwisata Indonesia terkini dengan fitur-fitur modern dan native iOS experience.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
