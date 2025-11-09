import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/quest.dart';
import '../models/ai_rating.dart';
import '../models/leaderboard_entry.dart';
import '../models/user.dart';
import '../models/photo_submission.dart';
import '../config/app_config.dart';

// Talks to the server to send photos and get data
class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  Future<Quest?> getTodayQuest() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.questsEndpoint}/today'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quest.fromJson(data);
      } else {
        print('Failed to load quest: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching quest: $e');
      return null;
    }
  }

  Future<List<Quest>> getQuests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.questsEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        print('Failed to load quests: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching quests: $e');
      return [];
    }
  }

  Future<AIRating?> submitPhoto({
    required String userId,
    required String questId,
    File? photoFile,
    dynamic xFile, // XFile for web support
  }) async {
    try {
      List<int> photoBytes;
      String filename;
      
      if (xFile != null) {
        photoBytes = await xFile.readAsBytes();
        filename = xFile.name;
      } else if (photoFile != null) {
        photoBytes = await photoFile.readAsBytes();
        filename = photoFile.path.split('/').last;
      } else {
        throw Exception('No photo provided');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConfig.submitPhotoEndpoint}'),
      );

      request.fields['userId'] = userId;
      request.fields['questId'] = questId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['rating'] != null) {
          return AIRating.fromJson(data['rating']);
        } else {
          print('No rating found in response');
          return null;
        }
      } else {
        print('Failed to submit photo: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error submitting photo: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.leaderboardEndpoint}?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaderboardEntry.fromJson(json)).toList();
      } else {
        print('Failed to load leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.userEndpoint}/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to load user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<List<PhotoSubmission>> getRecentSubmissions({
    int limit = 20,
    String? excludeUserId,
  }) async {
    try {
      var url = '$baseUrl/submissions/recent?limit=$limit';
      if (excludeUserId != null) {
        url += '&excludeUserId=$excludeUserId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PhotoSubmission.fromJson(json)).toList();
      } else {
        print('Failed to load submissions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching submissions: $e');
      return [];
    }
  }

  Future<bool> voteOnPhoto({
    required String photoId,
    required String userId,
    required bool isLike,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/votes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'photoId': photoId,
          'userId': userId,
          'isLike': isLike,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to vote: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error voting on photo: $e');
      return false;
    }
  }

  Future<bool> removeVote({
    required String photoId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/votes?photoId=$photoId&userId=$userId'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove vote: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error removing vote: $e');
      return false;
    }
  }

  Future<User?> registerUser({
    required String username,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.userEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to register user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }
}
