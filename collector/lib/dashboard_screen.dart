import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_request_screen.dart';
import 'change_language_screen.dart';
import 'completed_request_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'order_history_page.dart';
import 'pending_request_screen.dart';

const primaryGold = Color(0xFFb59d31);
const darkBrown = Color(0xFF4a3b1a);
const lightGold = Color(0xFFF6F0D3);
const lightGrey = Color(0xFFF8F9FA);
const mediumGrey = Color(0xFFE9ECEF);
const successGreen = Color(0xFF10B981);

class DashboardScreen extends StatefulWidget {
  final String? userEmail;
  final String? userName;

  const DashboardScreen({
    super.key,
    this.userEmail,
    this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // User data variables
  String _userName = "Loading...";
  String _userEmail = "Loading...";

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Dashboard statistics
  int _pendingRequests = 5;
  int _completedRequests = 12;
  int _totalRequests = 25;
  int _myOrders = 8;
  double _monthlyEarnings = 24560.75;

  // Slider items with images
  final List<Map<String, dynamic>> _sliderItems = [
    {
      'title': 'SCRAP COLLECTION SERVICE',
      'subtitle': 'Easy • Fair • Eco-Friendly',
      'color': primaryGold,
      'icon': Icons.recycling,
      'image': 'assets/images/img_1.png', // Add your image path
    },
    {
      'title': 'SCHEDULING & PRICING',
      'subtitle': 'Flexible Scheduling & Best Prices',
      'color': Color(0xFF1F4E79),
      'icon': Icons.calendar_today,
      'image': 'assets/images/img_2.png', // Add your image path
    },
    {
      'title': 'CONTACT SUPPORT',
      'subtitle': '24/7 Customer Support Available',
      'color': Color(0xFF3A7D44),
      'icon': Icons.phone,
      'image': 'assets/images/img_3.png', // Add your image path
    },
  ];

  int _currentSlide = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _startAutoSlide();
  }

  /// Initialize SharedPreferences and load user data
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserData();
  }

  /// Load user data from SharedPreferences
  void _loadUserData() {
    setState(() {
      // Priority 1: Use passed parameters
      if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
        _userEmail = widget.userEmail!;
      } else {
        // Priority 2: Load from SharedPreferences
        _userEmail = _prefs.getString('userEmail') ?? 'john.collector@example.com';
      }

      if (widget.userName != null && widget.userName!.isNotEmpty) {
        _userName = widget.userName!;
      } else {
        _userName = _prefs.getString('userName') ?? 'John Collector';
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_sliderItems.isNotEmpty && mounted) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % _sliderItems.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkBrown,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showNotifications,
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, size: 26),
                Positioned(
                  right: 2,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          _buildProfileButton(),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: primaryGold,
        backgroundColor: Colors.white,
        displacement: 40,
        edgeOffset: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 20),
              _buildImageSlider(),
              const SizedBox(height: 24),
              _buildQuickActionsGrid(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToMyOrders,
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  // ========================= PROFILE BUTTON =========================
  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: _showProfileInfo,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: primaryGold.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: primaryGold,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _showProfileInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Profile Information",
            style: TextStyle(
              color: darkBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryGold.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: primaryGold,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileInfoItem("Name", _userName),
                const SizedBox(height: 10),
                _buildProfileInfoItem("Email", _userEmail),
                const SizedBox(height: 10),
                _buildProfileInfoItem("Role", "Premium Collector"),
                const SizedBox(height: 10),
                _buildProfileInfoItem(
                  "Member Since",
                  _getMemberSinceDate(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: primaryGold),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getMemberSinceDate() {
    final loginTime = _prefs.getString('loginTime');
    if (loginTime != null) {
      try {
        final dateTime = DateTime.parse(loginTime);
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      } catch (e) {
        return "Today";
      }
    }
    return "Today";
  }

  Widget _buildProfileInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: darkBrown,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ========================= IMAGE SLIDER =========================
  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: _sliderItems.length,
            controller: PageController(initialPage: _currentSlide),
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _sliderItems[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: item['color'] as Color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image with gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(item['image'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Subtitle
                            Text(
                              item['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sliderItems.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentSlide == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentSlide == index ? primaryGold : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ========================= QUICK ACTIONS GRID =========================
  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkBrown,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            _buildActionCard(
              icon: Icons.pending_actions,
              title: 'Pending Requests',
              subtitle: '$_pendingRequests pending',
              color: Colors.orange,
              onTap: _navigateToPendingRequests,
            ),
            _buildActionCard(
              icon: Icons.check_circle,
              title: 'Completed',
              subtitle: '$_completedRequests done',
              color: successGreen,
              onTap: _navigateToCompletedRequests,
            ),
            _buildActionCard(
              icon: Icons.list_alt,
              title: 'All Requests',
              subtitle: '$_totalRequests total',
              color: Colors.blue,
              onTap: _navigateToAllRequests,
            ),
            _buildActionCard(
              icon: Icons.shopping_cart,
              title: 'My Orders',
              subtitle: 'Manage orders',
              color: Colors.purple,
              onTap: _navigateToMyOrders,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= WELCOME HEADER =========================
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGold.withOpacity(0.9), primaryGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName.split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showProfileInfo,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Earnings',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${_monthlyEarnings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================= NAV DRAWER =========================
  Drawer _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGold.withOpacity(0.9), primaryGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _showProfileInfo,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: primaryGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Premium Collector',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              title: 'My Orders',
              count: _myOrders,
              onTap: () {
                Navigator.pop(context);
                _navigateToMyOrders();
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'Order History',
              onTap: () {
                Navigator.pop(context);
                _navigateToOrderHistory();
              },
            ),
            _buildDrawerItem(
              icon: Icons.list_alt,
              title: 'All Requests',
              count: _totalRequests,
              onTap: () {
                Navigator.pop(context);
                _navigateToAllRequests();
              },
            ),
            _buildDrawerItem(
              icon: Icons.pending_actions,
              title: 'Pending Requests',
              count: _pendingRequests,
              onTap: () {
                Navigator.pop(context);
                _navigateToPendingRequests();
              },
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: 'Completed Requests',
              count: _completedRequests,
              onTap: () {
                Navigator.pop(context);
                _navigateToCompletedRequests();
              },
            ),
            const Divider(indent: 20, endIndent: 20, height: 40),
            _buildDrawerItem(
              icon: Icons.language,
              title: 'Change Language',
              onTap: () {
                Navigator.pop(context);
                _navigateToChangeLanguage();
              },
            ),
            _buildDrawerItem(
              icon: Icons.share,
              title: 'Share App',
              onTap: _navigateToShareUs,
            ),
            _buildDrawerItem(
              icon: Icons.chat,
              title: 'Chat Support',
              onTap: _navigateToChatSupport,
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings page coming soon'),
                    backgroundColor: primaryGold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? count,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: isSelected,
      selectedColor: primaryGold,
      selectedTileColor: primaryGold.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: count != null
          ? CircleAvatar(
        radius: 10,
        backgroundColor: primaryGold.withOpacity(0.2),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: primaryGold,
          ),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  // ========================= NAVIGATION METHODS =========================
  void _navigateToPendingRequests() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingRequestsScreen()));
  }

  void _navigateToCompletedRequests() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const  CompletedRequestsScreen()));
  }

  void _navigateToAllRequests() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllRequestsScreen()));
  }

  void _navigateToMyOrders() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
  }

  void _navigateToOrderHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
  }

  void _navigateToChangeLanguage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeLanguageScreen()));
  }

  void _navigateToShareUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be added soon'),
        backgroundColor: primaryGold,
      ),
    );
  }

  void _navigateToChatSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat support will be available soon'),
        backgroundColor: primaryGold,
      ),
    );
  }

  void _logout() async {
    // Clear SharedPreferences
    await _prefs.clear();

    // Navigate to Login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _pendingRequests = _pendingRequests + (DateTime.now().second % 3);
        _completedRequests = _completedRequests + (DateTime.now().second % 2);
        _monthlyEarnings = _monthlyEarnings * (1 + (DateTime.now().second % 10) / 100);
      });
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.local_shipping, color: primaryGold),
                      title: Text('New Pickup Request'),
                      subtitle: Text('New pickup request from Rajesh Kumar'),
                      trailing: Text('Just now'),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications_active, color: primaryGold),
                      title: Text('Pickup Reminder'),
                      subtitle: Text('You have 3 pending pickups today'),
                      trailing: Text('2 hours ago'),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: primaryGold),
                      title: Text('Payment Successful'),
                      subtitle: Text('Payment of ₹2,150 has been processed'),
                      trailing: Text('1 day ago'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}