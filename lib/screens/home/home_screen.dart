import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/featured_content.dart';
import '../../widgets/content_row.dart';
import '../../widgets/bottom_navigation.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildComingSoonTab(),
          _buildDownloadsTab(),
          _buildMoreTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 500,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: FeaturedContent(
                  movie: movieProvider.featuredMovie,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    'NETFLIX',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      _pageController.animateToPage(1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 20),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ContentRow(
                  title: 'Trending Now',
                  movies: movieProvider.trendingMovies,
                ),
                ContentRow(
                  title: 'Netflix Originals',
                  movies: movieProvider.netflixOriginals,
                ),
                ContentRow(
                  title: 'Popular Movies',
                  movies: movieProvider.popularMovies,
                ),
                ContentRow(
                  title: 'Top Rated',
                  movies: movieProvider.topRatedMovies,
                ),
                SizedBox(height: 100),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search for a show, movie, genre, etc.',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[800],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Popular Searches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Consumer<MovieProvider>(
              builder: (context, movieProvider, child) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: movieProvider.popularMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.popularMovies[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(movie.fullPosterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Coming Soon'),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      'DEC',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${15 + index}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coming Soon Movie ${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description of the upcoming movie or show...',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.notifications, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Remind Me', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 20),
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('My List', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadsTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Downloads')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Downloads Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Movies and TV shows that you download appear here.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: Text('Find Something to Download'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              SizedBox(height: 60),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userEmail,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Switch Profiles',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    'Account',
                    'Downloaded Videos',
                    'Notifications',
                    'My List',
                    'App Settings',
                    'Help',
                    'Sign Out'
                  ].map((item) => ListTile(
                    title: Text(item, style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      if (item == 'Sign Out') {
                        _showSignOutDialog();
                      }
                    },
                  )).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Sign Out', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}