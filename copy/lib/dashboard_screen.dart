import 'package:flutter/material.dart';
import 'package:copy/activity/combined_product_selection.dart';
import 'package:copy/activity/login_screen.dart';
import 'package:copy/scrap_price_list_page.dart';
import 'package:copy/services/api_service.dart';
import 'package:copy/share_use_page.dart';

import 'about_us_page.dart';
import 'bulk_combine_selection_page.dart';
import 'contact_us_page.dart';
import 'language_change_page.dart';
import 'order_history_page.dart';
import 'terms_and_conditions_page.dart';
import 'privacy_policy_page.dart';
import 'user_profile_page.dart';
import 'chat_screen.dart';
import 'bulk_order_page.dart';
import 'complaints_page.dart';
import 'feedback_page.dart';
import 'l10n/app_localizations.dart';

/// 🎨 COLOR PALETTE
const Color primaryGreen = Color(0xFF6FAE3E);
const Color darkGreen = Color(0xFF3E6B2C);
const Color primaryBlue = Color(0xFF1F4E79);
const Color lightBackground = Color(0xFFF4F7F3);
const Color accentGold = Color(0xFFC48A3A);
const Color textDark = Color(0xFF1E1E1E);

/// =====================
/// DASHBOARD SCREEN
/// =====================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: lightBackground,

      /// 🔵 APP BAR (BLUE)
      appBar: AppBar(
        title: Text(t.homeDashboard),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardImageSlider(),
            const SizedBox(height: 22),

            Text(
              t.quickActions,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.5,
                      children: [
                        DashboardCard(
                          icon: Icons.add_business_outlined,
                          title: t.newEnquiry,
                          gradient: const LinearGradient(
                            colors: [primaryBlue, darkGreen],
                          ),
                          onTapRoute:
                          const CombinedProductSelectionScreen(),
                        ),
                        DashboardCard(
                          icon: Icons.monetization_on_outlined,
                          title: t.checkPriceList,
                          gradient: const LinearGradient(
                            colors: [primaryBlue, darkGreen],
                          ),
                          onTapRoute: const PriceCard(),
                        ),
                        DashboardCard(
                          icon: Icons.history_outlined,
                          title: t.orderHistory,
                          gradient: const LinearGradient(
                            colors: [primaryBlue, darkGreen],
                          ),
                          onTapRoute: const OrderHistoryScreen(),
                        ),
                        DashboardCard(
                          icon: Icons.person_outline,
                          title: t.myProfile,
                          gradient: const LinearGradient(
                            colors: [primaryBlue, darkGreen],
                          ),
                          onTapRoute: const UserProfilePage(),
                        ),
                      ],
                    ),
                  ),

                  /// 🟢 BULK ORDER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: DashboardCard(
                      icon: Icons.shopping_cart,
                      title: t.bulkOrder,
                      gradient: const LinearGradient(
                        colors: [primaryBlue, darkGreen],
                      ),
                      onTapRoute: const BulkCombineSelectionPage(),
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

/// =====================
/// DASHBOARD CARD
/// =====================
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final LinearGradient gradient;
  final Widget onTapRoute;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTapRoute,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => onTapRoute),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// IMAGE SLIDER
/// =====================
class DashboardImageSlider extends StatefulWidget {
  const DashboardImageSlider({super.key});

  @override
  State<DashboardImageSlider> createState() =>
      _DashboardImageSliderState();
}

class _DashboardImageSliderState extends State<DashboardImageSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<String> images = [
    'assets/images/img_1.png',
    'assets/images/img_2.png',
    'assets/images/img_3.png',
    'assets/images/img_4.png',
    'assets/images/img_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _autoSlide();
  }

  void _autoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_currentIndex + 1) % images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          _autoSlide();
        },
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =====================
/// DRAWER
/// =====================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final menuItems = [
      {'icon': Icons.person_outline, 'title': t.myProfile, 'route': const UserProfilePage()},
      {'icon': Icons.history, 'title': t.orderHistory, 'route': const OrderHistoryScreen()},
      {'icon': Icons.add_business, 'title': t.newEnquiry, 'route': const CombinedProductSelectionScreen()},
      {'icon': Icons.shopping_cart, 'title': t.bulkOrder, 'route': const BulkOrderPage()},
      {'icon': Icons.monetization_on, 'title': t.priceList, 'route': const PriceCard()},
      {'icon': Icons.language, 'title': t.languageChange, 'route': const LanguageChangePage()},
      {'icon': Icons.report_problem, 'title': t.complaints, 'route': const ComplaintsPage()},
      {'icon': Icons.feedback, 'title': t.feedback, 'route': const FeedbackPage()},
      {'icon': Icons.share, 'title': t.shareUs, 'route': ShareUsScreen()},
      {'icon': Icons.info, 'title': t.aboutUs, 'route': const AboutUsPage()},
      {'icon': Icons.contact_mail, 'title': t.contactUs, 'route': const ContactUsPage()},
      {'icon': Icons.chat, 'title': t.chatSupport, 'route': const ChatScreen()},
      {'icon': Icons.policy, 'title': t.termsConditions, 'route': const TermsAndConditionsPage()},
      {'icon': Icons.security, 'title': t.privacyPolicy, 'route': const PrivacyPolicyPage()},
    ];

    return Drawer(
      backgroundColor: lightBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            color: primaryBlue,
            width: double.infinity,
            child: FutureBuilder<String?>(
              future: ApiService.getUserEmail(),
              builder: (context, snapshot) {
                final email = snapshot.data ?? 'user@example.com';
                final name = email.split('@').first;
                return Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: darkGreen),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading:
                  Icon(item['icon'] as IconData, color: primaryGreen),
                  title: Text(item['title'] as String),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => item['route'] as Widget,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// 🟢 LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(t.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                await ApiService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (_) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
