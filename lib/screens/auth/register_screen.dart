import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart'; // EDIT: Menggunakan PocketBaseService
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // EDIT: Menambahkan instance PocketBaseService
  final _authService = PocketBaseService();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // EDIT: Mengganti Scaffold putih dengan Container berlatar gambar
    return Scaffold(
      body: Container(
        // Latar belakang dengan gambar dan overlay gelap
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://assets.nflxext.com/ffe/siteui/vlv3/9d3533b2-0e2b-40b2-95e0-ecd7979cc88b/a3873901-5b7c-46eb-b9fa-12fea5197bd3/ID-en-20240311-popsignuptwoweeks-perspective_alpha_website_large.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildLandingPage(),
              _buildPasswordPage(),
              _buildWelcomePage(),
            ],
          ),
        ),
      ),
    );
  }

  // --- KODE UI ASLI ANDA DENGAN PENYESUAIAN WARNA ---

  Widget _buildLandingPage() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          // EDIT: Background transparan agar gambar terlihat
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NETFLIX',
                style: TextStyle(
                  color: AppTheme.netflixRed,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    // EDIT: Warna teks diubah menjadi putih
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Dibuat bold agar lebih kontras
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main Content
        Expanded(
          child: Container(
            width: double.infinity,
            // EDIT: Background transparan
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Unlimited movies, TV\nshows, and more.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          // EDIT: Warna teks diubah menjadi putih
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Watch anywhere. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          // EDIT: Warna teks diubah menjadi putih
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Ready to watch? Enter your email to create or restart your membership.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w400,
                          // EDIT: Warna teks diubah menjadi putih
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28),
                
                // Email Input Section - Mengembalikan layout asli Anda
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Center(
                          child: Container(
                            width: 500,
                            height: 56,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Email address',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.5),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _validateAndContinue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.netflixRed,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      child: Text(
                                        'Get Started >',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Mobile layout - stacked
                        return Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Email address',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.5),
                                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _validateAndContinue,
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.netflixRed, foregroundColor: Colors.white),
                                child: Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordPage() {
    // UI tidak perlu diubah karena sudah menggunakan warna gelap
    return Container(
      color: Colors.black, // Background hitam solid untuk fokus
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NETFLIX', style: TextStyle(color: AppTheme.netflixRed, fontSize: 28, fontWeight: FontWeight.w900)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[850], height: 1),
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 450), // Batasi lebar di layar besar
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STEP 1 OF 3', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  SizedBox(height: 8),
                  Text('Create a password to start your membership.', style: TextStyle(fontSize: 20, color: Colors.white)),
                  SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    style: TextStyle(color: Colors.grey[400]),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofocus: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a password',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey[400]),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createAccount,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.netflixRed, foregroundColor: Colors.white),
                      child: _isLoading
                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      color: Colors.black, // Background hitam solid
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Text('Go to Home', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.netflixRed, width: 3)),
                  child: Icon(Icons.check, color: AppTheme.netflixRed, size: 50),
                ),
                SizedBox(height: 30),
                Text('You\'re all set!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Enjoy unlimited movies, TV shows, and more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 300, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.netflixRed, foregroundColor: Colors.white),
                    child: Text('Start Watching', style: TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- FUNGSI LOGIKA (TERHUBUNG KE POCKETBASE) ---

  void _validateAndContinue() {
    if (_emailController.text.isEmpty || !_isValidEmail(_emailController.text)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _createAccount() async {
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password');
      return;
    }
    if (_passwordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (result == null) {
        _pageController.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _showSnackBar(result);
      }
    }
  }

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}