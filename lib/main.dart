import 'package:flutter/material.dart';
import 'package:netflix_mobile_application/models/movie.dart';
import 'package:netflix_mobile_application/providers/movie_provider.dart';
import 'package:netflix_mobile_application/screens/auth/login_screen.dart';
import 'package:netflix_mobile_application/screens/auth/register_screen.dart';
import 'package:netflix_mobile_application/screens/home/home_screen.dart';
import 'package:netflix_mobile_application/screens/movie/movie_detail_screen.dart';
import 'package:netflix_mobile_application/screens/movie/movie_video_player.dart';
import 'package:netflix_mobile_application/services/pocketbase_service.dart';
import 'package:netflix_mobile_application/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  // Pastikan Flutter binding diinisialisasi sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Cek status login dari PocketBase sebelum aplikasi berjalan
  final authService = PocketBaseService();
  // Tentukan halaman awal: jika sudah login, buka '/home', jika tidak, buka '/login'.
  final String initialRoute = authService.isLoggedIn ? '/home' : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Hapus AuthProvider yang lama
        // ChangeNotifierProvider(create: (_) => AuthProvider()), 
        
        // MovieProvider tetap ada
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'Netflix Clone',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        // Gunakan initialRoute yang sudah kita tentukan
        initialRoute: initialRoute,
        
        // Menggunakan 'routes' untuk navigasi yang lebih sederhana
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
        },

        // onGenerateRoute untuk rute yang butuh argumen (data)
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/movie-detail':
              // Pastikan argumen yang dikirim adalah tipe Movie
              if (settings.arguments is Movie) {
                final movie = settings.arguments as Movie;
                return MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movie: movie),
                );
              }
              return null; // Argumen tidak valid

            case '/video-player':
              if (settings.arguments is Movie) {
                final movie = settings.arguments as Movie;
                return MaterialPageRoute(
                  builder: (_) => MovieVideoPlayer(movie: movie),
                  fullscreenDialog: true,
                );
              }
              return null; // Argumen tidak valid
              
            default:
              // Jika rute tidak ditemukan, jangan lakukan apa-apa
              return null;
          }
        },
      ),
    );
  }
}