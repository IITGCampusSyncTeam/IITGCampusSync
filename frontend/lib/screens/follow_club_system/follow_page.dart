import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/multi_tag_screen/interest_page.dart';
import 'package:frontend/models/club_follow_model.dart';
import 'package:frontend/providers/club_follow_repo.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late Future<List<Club>> _clubsFuture;
  final ClubRepository _clubRepo = const ClubRepository();

  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _clubsFuture = _clubRepo.fetchClubs();
  }

  Future<void> _toggleFollow(Club club) async {
    try {
      if (club.isFollowing) {
        await _clubRepo.unfollowClub(club.id);
      } else {
        await _clubRepo.followClub(club.id);
      }

      setState(() {
        _clubs = _clubs.map((c) {
          if (c.id == club.id) {
            return c.copyWith(isFollowing: !club.isFollowing);
          }
          return c;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InterestPage()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _upperUI(size),
          Expanded(
            child: FutureBuilder<List<Club>>(
              future: _clubsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No clubs available"));
                }

                if (_clubs.isEmpty) _clubs = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _clubs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final club = _clubs[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                club.logo != null && club.logo!.isNotEmpty
                                    ? NetworkImage(club.logo!)
                                    : null,
                            child: (club.logo == null || club.logo!.isEmpty)
                                ? const Icon(Icons.groups, size: 22)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              club.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _toggleFollow(club),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: club.isFollowing
                                  ? Colors.black
                                  : Colors.grey.shade200,
                              foregroundColor: club.isFollowing
                                  ? Colors.white
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child:
                                Text(club.isFollowing ? "Unfollow" : "Follow"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen())); // Continue button action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _upperUI(Size size) {
    final height = size.height;
    final width = size.width;

    return Column(
      children: [
        SizedBox(height: height * 0.02),
        SvgPicture.asset(
          'assets/images/Avatar.svg',
          width: width * 0.065,
          height: height * 0.065,
        ),
        SizedBox(height: height * 0.02),
        Text(
          "Follow Organisers and Clubs",
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.06,
            fontWeight: FontWeight.w800,
            fontFamily: 'SaansTrial',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: height * 0.01),
        Text(
          "Stay in sync with your favourite clubs, boards\netc. You'll get updates when they host events.",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: width * 0.039,
            fontWeight: FontWeight.w400,
            fontFamily: 'SaansTrial',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: height * 0.03),
      ],
    );
  }
}
