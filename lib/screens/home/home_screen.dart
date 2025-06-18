import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_provider.dart';
import '../../widgets/bottom_navigation.dart';

// Import untuk setiap tab yang sudah dipisah
import '../../screens/tabs/home_tab.dart';
import '../../screens/tabs/search_tab.dart';
import '../../screens/tabs/coming_soon_tab.dart';
import '../../screens/tabs/downloads_tab.dart';
import '../../screens/tabs/more_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Memuat data movie saat pertama kali layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadMovies();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView digunakan untuk navigasi geser antar tab
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // Setiap halaman sekarang memanggil Widget dari filenya masing-masing.
        children: [
          HomeTab(),
          SearchTab(),
          ComingSoonTab(),
          DownloadsTab(),
          MoreTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          // Animasikan perpindahan halaman saat ikon bottom nav diklik
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}