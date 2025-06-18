import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';
import 'api_service.dart';
import 'pocketbase_client.dart';

class PocketBaseService {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();

  Future<String?> register(String email, String password) async {
    try {
      final body = <String, dynamic>{
        "email": email,
        "emailVisibility": true,
        "password": password,
        "passwordConfirm": password,
        "name": email.split('@').first,
      };
      await pb.collection('users').create(body: body);
      await login(email, password);
      return null;
    } on ClientException catch (e) {
      return 'Error: ${e.response['message']}';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return null;
    } on ClientException catch (e) {
      return 'Error: ${e.response['message']}';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  void logout() {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;
  RecordModel? get currentUser => pb.authStore.model;

  Uri? getUserAvatarUrl() {
    final user = currentUser;
    if (user == null) return null;
    final avatarFilename = user.getStringValue('avatar');
    if (avatarFilename.isEmpty) return null;
    return pb.getFileUrl(user, avatarFilename, thumb: '100x100');
  }

  Future<bool> isMovieDownloaded(String movieId) async {
    if (!isLoggedIn) return false;
    final userId = currentUser!.id;
    try {
      await pb.collection('movie_download').getFirstListItem('id_user = "$userId" && link = "$movieId"');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> addMovieToDownloads({
    required String movieId,
    required String trailerKey,
    required Function(int, int) onReceiveProgress,
  }) async {
    if (!isLoggedIn) throw Exception('User not logged in.');
    final userId = currentUser!.id;

    if (await isMovieDownloaded(movieId)) {
      throw Exception('Movie already downloaded.');
    }

    final List<String> sampleVideos = [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    ];
    final videoUrl = sampleVideos[movieId.hashCode % sampleVideos.length];

    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/$movieId.mp4';

    await _dio.download(videoUrl, localPath, onReceiveProgress: onReceiveProgress);

    final body = <String, dynamic>{
      "id_user": userId, "link": movieId, "trailer_key": trailerKey, "local_path": localPath,
    };
    await pb.collection('movie_download').create(body: body);
  }

  Future<void> deleteDownloadedMovie(String movieId) async {
    if (!isLoggedIn) throw Exception('User not logged in.');
    final userId = currentUser!.id;
    try {
      final record = await pb.collection('movie_download').getFirstListItem('id_user = "$userId" && link = "$movieId"');
      final localPath = record.getStringValue('local_path');
      if (localPath.isNotEmpty) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await pb.collection('movie_download').delete(record.id);
    } catch (e) {
      throw Exception('Failed to delete download: ${e.toString()}');
    }
  }

  Future<List<Movie>> getMyDownloads() async {
    if (!isLoggedIn) return [];
    final userId = currentUser!.id;
    final records = await pb.collection('movie_download').getFullList(filter: 'id_user = "$userId"', sort: '-created');
    if (records.isEmpty) return [];
    final movieIds = records.map((record) => record.getStringValue('link')).toList();
    final movieFutures = movieIds.map((id) => _apiService.getMovieDetails(id)).toList();
    return await Future.wait(movieFutures);
  }

  Future<String?> updateUser({
    String? name,
    String? phone,
    String? oldPassword,
    String? newPassword,
    String? avatarPath,
  }) async {
    if (!isLoggedIn) return 'User not logged in.';
    final userId = currentUser!.id;

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (oldPassword != null && oldPassword.isNotEmpty && newPassword != null && newPassword.isNotEmpty) {
      body['oldPassword'] = oldPassword;
      body['password'] = newPassword;
      body['passwordConfirm'] = newPassword;
    }

    // --- PERBAIKAN 1: Null Safety ---
    // Inisialisasi 'files' sebagai list kosong yang non-nullable.
    final files = <http.MultipartFile>[];
    if (avatarPath != null && avatarPath.isNotEmpty) {
      files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
    }
    // ---------------------------------

    if (body.isEmpty && files.isEmpty) {
      return 'No changes to update.';
    }

    try {
      await pb.collection('users').update(
        userId,
        body: body,
        files: files, // 'files' dijamin tidak akan pernah null.
      );

      // --- PERBAIKAN 2: Masalah Notifikasi Error ---
      // Baris ini dihapus untuk mencegah error otorisasi setelah update password.
      // await pb.collection('users').authRefresh(); 
      // ---------------------------------------------

      return null; // Sukses
    } on ClientException catch (e) {
      return 'Error: ${e.response['message']}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}