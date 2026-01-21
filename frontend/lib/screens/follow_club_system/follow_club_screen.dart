import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/models/club_model.dart';
import 'package:frontend/providers/club_follow_repo.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/multi_tag_screen/tag_screen.dart';
import 'package:shimmer/shimmer.dart';

class FollowClubScreen extends StatefulWidget {
  final String? userId;

  const FollowClubScreen({super.key, this.userId});

  @override
  State<FollowClubScreen> createState() => _FollowClubScreenState();
}

class _FollowClubScreenState extends State<FollowClubScreen> {
  late Future<List<Club>> _clubsFuture;
  List<String> followedClubIds = [];

  bool get isSignedIn => widget.userId != null && widget.userId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _clubsFuture = loadClubs();
  }

  Future<List<Club>> loadClubs() async {
    try {
      final clubs = await ClubFollowService.getAllClubs();
      if (isSignedIn) {
        followedClubIds =
            await ClubFollowService.getSubscribedClubIds(widget.userId!);
      }
      return clubs;
    } catch (e) {
      _showSnackBar("Failed to fetch clubs: $e");
      return [];
    }
  }

  Future<void> followClub(String clubId) async {
    if (!isSignedIn) {
      _showSnackBar(
        "Please sign in to follow clubs.",
        backgroundColor: Colors.orange,
        icon: Icons.login,
      );
      return;
    }

    try {
      await ClubFollowService.followClub(widget.userId!, clubId);
      setState(() => followedClubIds.add(clubId));
      _showSnackBar("Followed successfully!",
          backgroundColor: Colors.green, icon: Icons.check_circle_outline);
    } catch (e) {
      _showSnackBar("Error following: $e");
    }
  }

  Future<void> unfollowClub(String clubId) async {
    if (!isSignedIn) {
      _showSnackBar(
        "Please sign in to unfollow clubs.",
        backgroundColor: Colors.orange,
        icon: Icons.login,
      );
      return;
    }

    try {
      await ClubFollowService.unfollowClub(widget.userId!, clubId);
      setState(() => followedClubIds.remove(clubId));
      _showSnackBar("Unfollowed successfully!",
          backgroundColor: Colors.grey, icon: Icons.remove_circle_outline);
    } catch (e) {
      _showSnackBar("Error unfollowing: $e");
    }
  }

  void _showSnackBar(String message,
      {Color backgroundColor = Colors.redAccent, IconData icon = Icons.error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildShimmerList() {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return ListView.builder(
      padding: EdgeInsets.all(width * 0.02),
      itemCount: 10,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              radius: width * 0.06,
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: height * 0.025,
              width: width * 0.3,
              color: Colors.white,
            ),
            trailing: Container(
              height: height * 0.035,
              width: width * 0.18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubList(List<Club> clubs) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.02, vertical: height * 0.01),
      itemCount: clubs.length,
      separatorBuilder: (_, __) => SizedBox(height: height * 0.015),
      itemBuilder: (context, index) {
        final club = clubs[index];
        final isFollowed = followedClubIds.contains(club.id);
        final imageUrl = (club.images.isNotEmpty)
            ? club.images
            : "https://via.placeholder.com/100?text=No+Image";

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width * 0.05),
            border: Border.all(color: Colors.grey, width: width * 0.0018),
            boxShadow: const [], // ensures no shadow
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.03, vertical: height * 0.008),
            child: Row(
              children: [
                CircleAvatar(
                  radius: width * 0.06,
                  backgroundImage: NetworkImage(imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Text(
                    club.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SaansTrial',
                      fontSize: width * 0.042,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                ElevatedButton(
                  onPressed: () =>
                      isFollowed ? unfollowClub(club.id) : followClub(club.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowed ? Colors.grey[300] : Colors.black,
                    foregroundColor: isFollowed ? Colors.black : Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: height * 0.008),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.05),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isFollowed ? "Unfollow" : "Follow",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, width),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.02),
            SvgPicture.asset(
              'assets/images/Avatar.svg',
              width: width * 0.14,
              height: width * 0.14,
            ),
            SizedBox(height: height * 0.02),
            Text(
              "Follow Organisers & Clubs",
              style: TextStyle(
                color: Colors.black,
                fontSize: width * 0.055,
                fontWeight: FontWeight.w800,
                fontFamily: 'SaansTrial',
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              "Stay in sync with your favourite clubs, boards \netc. You'll get updates when they host events.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: width * 0.038,
                fontWeight: FontWeight.w400,
                fontFamily: 'SaansTrial',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              //spinner refresh indicator
              child: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                strokeWidth: 2,
                displacement: 50,
                onRefresh: () async {
                  setState(() {
                    _clubsFuture = loadClubs();
                  });
                },
                child: FutureBuilder<List<Club>>(
                  future: _clubsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerList();
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No clubs available."));
                    }
                    return _buildClubList(snapshot.data!);
                  },
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            ElevatedButton(
              onPressed: () async {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.35,
                  vertical: height * 0.01,
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SaansTrial',
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, double width) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TagScreen()),
          );
        },
        icon: Icon(Icons.arrow_back, size: width * 0.07, color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
          child: Text(
            "Skip",
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontFamily: 'SaansTrial',
            ),
          ),
        ),
      ],
    );
  }
}
