import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfix/models/issue_model.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  Future<Issue?> getLatestIssue() async {
    try {
      print("DB: Fetching latest issue");
      final response =
          await supabase
              .from('issues')
              .select()
              .order('created_at', ascending: false)
              .limit(1)
              .single();

      if (response == null) {
        return null;
      }

      print("DB: Retrieved latest issue");
      return Issue.fromMap({
        'id': response['id'],
        'title': response['title'],
        'description': response['description'],
        'imageUrl': response['image_url'],
        'latitude': response['latitude'],
        'longitude': response['longitude'],
        'userId': response['user_id'],
        'createdAt':
            response['created_at'] is DateTime
                ? response['created_at']
                : DateTime.parse(response['created_at']),
        'status': response['status'],
      });
    } catch (e) {
      print("DB ERROR: Failed to fetch latest issue: $e");
      return null;
    }
  }

  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  // Points awarded for reporting an issue
  final int _reportRewardPoints = 10;

  // Report a new issue
  Future<String> reportIssue({
    required String title,
    required String description,
    required String imageUrl,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      print("DB: Creating new issue report: $title");
      final String issueId = uuid.v4();

      // Insert the issue
      await supabase.from('issues').insert({
        'id': issueId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'reported',
      });

      // Award points to the user
      await _awardPointsForReport(userId);

      print("DB: Issue reported successfully with ID: $issueId");
      return issueId;
    } catch (e) {
      print("DB ERROR: Failed to report issue: $e");
      rethrow;
    }
  }

  // Award points to user for reporting an issue
  Future<void> _awardPointsForReport(String userId) async {
    try {
      // Get current reward points
      final data =
          await supabase
              .from('profiles')
              .select('reward_coins')
              .eq('id', userId)
              .single();

      final currentPoints = data['reward_coins'] as int? ?? 0;
      final newPoints = currentPoints + _reportRewardPoints;

      // Update user's reward points
      await supabase
          .from('profiles')
          .update({'reward_coins': newPoints})
          .eq('id', userId);

      print(
        "DB: Awarded $_reportRewardPoints points to user $userId. New total: $newPoints",
      );
    } catch (e) {
      print("DB ERROR: Failed to award points: $e");
      // Don't rethrow - we don't want to fail the report if points can't be awarded
    }
  }

  // Get all issues
  Future<List<Issue>> getIssues() async {
    try {
      print("DB: Fetching all issues");
      final response = await supabase
          .from('issues')
          .select()
          .order('created_at', ascending: false);

      print("DB: Retrieved ${response.length} issues");
      return response
          .map<Issue>(
            (issue) => Issue.fromMap({
              'id': issue['id'],
              'title': issue['title'],
              'description': issue['description'],
              'imageUrl': issue['image_url'],
              'latitude': issue['latitude'],
              'longitude': issue['longitude'],
              'userId': issue['user_id'],
              'createdAt':
                  issue['created_at'] is DateTime
                      ? issue['created_at']
                      : DateTime.parse(issue['created_at']),
              'status': issue['status'],
            }),
          )
          .toList();
    } catch (e) {
      print("DB ERROR: Failed to fetch issues: $e");
      rethrow;
    }
  }

  // Get user's issues
  Future<List<Issue>> getUserIssues(String userId) async {
    try {
      print("DB: Fetching issues for user: $userId");
      final response = await supabase
          .from('issues')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print("DB: Retrieved ${response.length} issues for user");
      return response
          .map<Issue>(
            (issue) => Issue.fromMap({
              'id': issue['id'],
              'title': issue['title'],
              'description': issue['description'],
              'imageUrl': issue['image_url'],
              'latitude': issue['latitude'],
              'longitude': issue['longitude'],
              'userId': issue['user_id'],
              'createdAt':
                  issue['created_at'] is DateTime
                      ? issue['created_at']
                      : DateTime.parse(issue['created_at']),
              'status': issue['status'],
            }),
          )
          .toList();
    } catch (e) {
      print("DB ERROR: Failed to fetch user issues: $e");
      rethrow;
    }
  }
}
