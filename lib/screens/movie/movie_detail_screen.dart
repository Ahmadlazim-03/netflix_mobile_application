import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../utils/app_theme.dart';
import '../../widgets/content_row.dart';
import '../../providers/movie_provider.dart';
import 'package:provider/provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAppBarTitle = false;
  bool _isInMyList = false;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
      _animationController.forward();
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildMovieInfo(),
              _buildActionButtons(),
              _buildDescription(),
              _buildCastAndCrew(),
              _buildMoreLikeThis(),
              SizedBox(height: 50),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: _showAppBarTitle
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                widget.movie.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.movie.fullBackdropPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: Icon(Icons.error, color: Colors.white),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SERIES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${(widget.movie.voteAverage * 10).toInt()}% Match',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '16+',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Text(
                widget.movie.releaseDate.split('-')[0],
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'HD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              _buildGenreChip('Drama'),
              SizedBox(width: 8),
              _buildGenreChip('Thriller'),
              SizedBox(width: 8),
              _buildGenreChip('Mystery'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        genre,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Play Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/video-player', arguments: widget.movie);
              },
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 28),
              label: Text(
                'Play',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Download Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _showDownloadDialog();
              },
              icon: Icon(Icons.download, color: Colors.white, size: 24),
              label: Text(
                'Download',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Action Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionIcon(
                icon: _isInMyList ? Icons.check : Icons.add,
                label: 'My List',
                onTap: () {
                  setState(() {
                    _isInMyList = !_isInMyList;
                  });
                  _showSnackBar(_isInMyList ? 'Added to My List' : 'Removed from My List');
                },
              ),
              _buildActionIcon(
                icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Rate',
                onTap: () {
                  setState(() {
                    if (_isLiked) {
                      _isLiked = false;
                    } else {
                      _isLiked = true;
                      _isDisliked = false;
                    }
                  });
                },
              ),
              _buildActionIcon(
                icon: _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                label: 'Not for me',
                onTap: () {
                  setState(() {
                    if (_isDisliked) {
                      _isDisliked = false;
                    } else {
                      _isDisliked = true;
                      _isLiked = false;
                    }
                  });
                },
              ),
              _buildActionIcon(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  _showShareDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.overview,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          _buildInfoRow('Starring:', 'Millie Bobby Brown, Finn Wolfhard, Gaten Matarazzo'),
          SizedBox(height: 8),
          _buildInfoRow('Creators:', 'The Duffer Brothers'),
          SizedBox(height: 8),
          _buildInfoRow('Genres:', 'Drama, Fantasy, Horror, Mystery, Sci-Fi, Thriller'),
          SizedBox(height: 8),
          _buildInfoRow('This show is:', 'Exciting, Suspenseful, Teen TV Shows'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: ' $value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastAndCrew() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Cast & Crew',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildCastCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCastCard(int index) {
    final List<Map<String, String>> cast = [
      {'name': 'Millie Bobby Brown', 'character': 'Eleven'},
      {'name': 'Finn Wolfhard', 'character': 'Mike Wheeler'},
      {'name': 'Gaten Matarazzo', 'character': 'Dustin Henderson'},
      {'name': 'Caleb McLaughlin', 'character': 'Lucas Sinclair'},
      {'name': 'Noah Schnapp', 'character': 'Will Byers'},
      {'name': 'Sadie Sink', 'character': 'Max Mayfield'},
      {'name': 'Joe Keery', 'character': 'Steve Harrington'},
      {'name': 'Maya Hawke', 'character': 'Robin Buckley'},
      {'name': 'Priah Ferguson', 'character': 'Erica Sinclair'},
      {'name': 'Brett Gelman', 'character': 'Murray Bauman'},
    ];

    final actor = cast[index % cast.length];

    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[800],
            child: Text(
              actor['name']![0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            actor['name']!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            actor['character']!,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLikeThis() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        return ContentRow(
          title: 'More Like This',
          movies: movieProvider.popularMovies,
        );
      },
    );
  }

  void _showDownloadDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Download Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildDownloadOption('Standard', '~1GB per episode', true),
              _buildDownloadOption('High', '~3GB per episode', false),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Download started');
                  },
                  child: Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.netflixRed,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(String quality, String size, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<String>(
        title: Text(
          quality,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          size,
          style: TextStyle(color: Colors.white70),
        ),
        value: quality,
        groupValue: isSelected ? quality : '',
        onChanged: (value) {},
        activeColor: AppTheme.netflixRed,
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Share ${widget.movie.title}',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy, color: Colors.white),
                title: Text('Copy Link', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Link copied to clipboard');
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.white),
                title: Text('Send Message', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('More Options', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}