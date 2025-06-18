class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'No Title', // Handle TV shows that use 'name'
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
    );
  }

  String get fullPosterPath => posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : 'https://via.placeholder.com/500x750.png?text=No+Image';
  String get fullBackdropPath => backdropPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : 'https://via.placeholder.com/1280x720.png?text=No+Image';
}