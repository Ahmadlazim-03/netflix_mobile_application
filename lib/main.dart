import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/movie/movie_detail_screen.dart';
import 'screens/movie/movie_video_player.dart'; // Updated import
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'utils/app_theme.dart';
import 'models/movie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'Netflix Clone',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => RegisterScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case '/movie-detail':
              final movie = settings.arguments as Movie;
              return MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              );
            case '/video-player':
              final movie = settings.arguments as Movie;
              return MaterialPageRoute(
                builder: (_) => MovieVideoPlayer(movie: movie), // Updated to use MovieVideoPlayer
                fullscreenDialog: true,
              );
            default:
              return MaterialPageRoute(builder: (_) => SplashScreen());
          }
        },
      ),
    );
  }
}