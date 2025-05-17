import 'package:flutter/material.dart';
import 'package:spotfix/models/issue_model.dart';
import 'package:spotfix/screens/login_screen.dart';
import 'package:spotfix/services/auth_service.dart';
import 'package:spotfix/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfix/screens/reported_issues_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  bool _loading = false;
  String _username = '';
  String _email = '';
  int _rewardPoints = 0;
  List<Issue> _userIssues = [];

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userId = user.id;
        print("PROFILE: Fetching profile for user $userId");

        final data =
            await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', userId)
                .single();

        // Get user's reported issues
        final userIssues = await _databaseService.getUserIssues(userId);

        setState(() {
          _username = data['name'] ?? '';
          _email = user.email ?? '';
          _rewardPoints = data['reward_coins'] ?? 0;
          _userIssues = userIssues;
        });
      }
    } catch (e) {
      print("PROFILE ERROR: Failed to load profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _claimReward(String rewardName, int pointsCost) async {
    if (_rewardPoints < pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points to claim this reward')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Update reward points in database
        await Supabase.instance.client
            .from('profiles')
            .update({'reward_coins': _rewardPoints - pointsCost})
            .eq('id', user.id);

        // Refresh profile data
        await _getProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully claimed $rewardName!')),
        );
      }
    } catch (e) {
      print("PROFILE ERROR: Failed to claim reward: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error claiming reward: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.pink,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reward points section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reward Points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                '$_rewardPoints points',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Earn points by reporting and fixing issues in your community!',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // Add these sections after the Reward points section in your build method

                    // Reported Issues Button Section
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportedIssuesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.report_problem),
                        label: const Text('View All Reported Issues'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Help & Contact Section
                    // const SizedBox(height: 32),

                    // Available rewards section
                    const Text(
                      'Available Rewards',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reward cards
                    _buildRewardCard(
                      'Free Weeekly Bus Pass',
                      'Redeem a free Bus Pass for a Week',
                      50,
                    ),
                    const SizedBox(height: 12),
                    _buildRewardCard(
                      'Tree Planting',
                      'We\'ll plant a tree in your name',
                      100,
                    ),
                    const SizedBox(height: 12),
                    _buildRewardCard(
                      'Get 5% of on Train Tickets',
                      'Free ticket to your next trip ',
                      150,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Help & Contact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(Icons.phone, 'Emergency: 112'),
                          _buildContactItem(
                            Icons.phone,
                            'Helpline: +91 9876543210',
                          ),
                          _buildContactItem(Icons.email, 'support@spotfix.com'),
                          _buildContactItem(
                            Icons.location_on,
                            'SpotFix HQ, Bangalore',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'We\'re here to help you with any issues or questions about community improvement.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Widget _buildRewardCard(String title, String description, int pointsCost) {
    final bool canClaim = _rewardPoints >= pointsCost;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pointsCost pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    canClaim ? () => _claimReward(title, pointsCost) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(canClaim ? 'Claim Reward' : 'Not Enough Points'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
