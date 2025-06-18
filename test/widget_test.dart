// This is a basic Flutter widget test.
// We will test if the Login Screen renders correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflix_mobile_application/main.dart'; // Import main.dart Anda
import 'package:netflix_mobile_application/providers/movie_provider.dart'; // Import provider
import 'package:provider/provider.dart';

void main() {
  // Nama tes diubah agar lebih deskriptif
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Langkah 1: Siapkan semua provider yang dibutuhkan oleh aplikasi Anda,
    // sama seperti di main.dart.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // MovieProvider dibutuhkan oleh beberapa halaman
          ChangeNotifierProvider(create: (context) => MovieProvider()),
        ],
        // Langkah 2: Jalankan aplikasi kita dengan rute awal '/login' untuk tes ini.
        child: const MyApp(initialRoute: '/login'),
      ),
    );

    // Langkah 3: Verifikasi.
    // Kita berharap menemukan satu widget Teks yang berisi tulisan "Sign In"
    // di halaman login. Ini membuktikan halaman tersebut berhasil dimuat.
    expect(find.text('Sign In'), findsOneWidget);

    // Kita juga bisa memverifikasi bahwa widget lain ada, misalnya field email.
    expect(find.byType(TextFormField), findsNWidgets(2)); // Harapannya ada 2 TextFormField (email & password)
  });
}