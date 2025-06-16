import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1
  final _emailController = TextEditingController();
  
  // Step 2
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailOffers = false;
  
  // Step 3
  String _selectedPlan = 'Standard';
  
  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Mobile',
      'price': '\$6.99',
      'quality': 'Good',
      'resolution': '480p',
      'devices': 'Phone, tablet',
      'screens': '1',
    },
    {
      'name': 'Basic',
      'price': '\$9.99',
      'quality': 'Good',
      'resolution': '720p',
      'devices': 'Phone, tablet, computer, TV',
      'screens': '1',
    },
    {
      'name': 'Standard',
      'price': '\$15.49',
      'quality': 'Better',
      'resolution': '1080p',
      'devices': 'Phone, tablet, computer, TV',
      'screens': '2',
    },
    {
      'name': 'Premium',
      'price': '\$19.99',
      'quality': 'Best',
      'resolution': '4K+HDR',
      'devices': 'Phone, tablet, computer, TV',
      'screens': '4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_currentStep > 0) _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildEmailStep(),
                  _buildPasswordStep(),
                  _buildPlanStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NETFLIX',
            style: TextStyle(
              color: AppTheme.netflixRed,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP ${_currentStep + 1} OF 3',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            _getStepTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Create a password to start your membership';
      case 2:
        return 'Choose the plan that\'s right for you';
      default:
        return '';
    }
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Text(
            'Unlimited movies, TV shows, and more.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Watch anywhere. Cancel anytime.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            'Ready to watch? Enter your email to create or restart your membership.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email address',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.netflixRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Get Started >',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Text(
            'Just a few more steps and you\'re done!',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'We hate paperwork, too.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Add a password',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _emailOffers,
                onChanged: (value) {
                  setState(() {
                    _emailOffers = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text('Please do not email me Netflix special offers.'),
              ),
            ],
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.netflixRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Column(
            children: [
              _buildBenefitRow('Watch all you want. Ad-free.'),
              _buildBenefitRow('Recommendations just for you.'),
              _buildBenefitRow('Change or cancel your plan anytime.'),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _plans.map((plan) => _buildPlanCard(plan)).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _completeRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.netflixRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check, color: AppTheme.netflixRed, size: 24),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    bool isSelected = _selectedPlan == plan['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan['name'];
        });
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.netflixRed : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.red[50] : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              plan['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.netflixRed : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              plan['price'],
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.netflixRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}