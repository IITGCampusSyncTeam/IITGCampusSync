import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;
  List<dynamic> _upcomingEvents = [];
  List<dynamic> _followedClubEvents = [];
  List<dynamic> _myInterestEvents = [];
  List<dynamic> _clubs = [];
  bool _isLoading = true;

  final String YOUR_BACKEND_URL = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchEventsAndClubs();
  }

  Future<void> fetchEventsAndClubs() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse("$YOUR_BACKEND_URL/api/events/upcoming")),
        http.get(Uri.parse("$YOUR_BACKEND_URL/api/events/followed")),
        http.get(Uri.parse("$YOUR_BACKEND_URL/api/events/myinterest")),
        http.get(Uri.parse("$YOUR_BACKEND_URL/api/clubs")),
      ]);

      // ✅ Debugging logs
      print("Response status codes: ${responses.map((r) => r.statusCode)}");
      print("Response bodies: ${responses.map((r) => r.body)}");

      setState(() {
        _upcomingEvents =
            responses[0].statusCode == 200 ? jsonDecode(responses[0].body) : [];
        _followedClubEvents =
            responses[1].statusCode == 200 ? jsonDecode(responses[1].body) : [];
        _myInterestEvents =
            responses[2].statusCode == 200 ? jsonDecode(responses[2].body) : [];
        _clubs =
            responses[3].statusCode == 200 ? jsonDecode(responses[3].body) : [];
        _isLoading = false; // ✅ Ensure UI updates even if some requests fail
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false); // ✅ Prevent infinite loading
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // ✅ Show loading only at the top level
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Carousel Slider
                  CarouselSlider(
                    items: List.generate(
                        3, (index) => Container(color: Colors.grey[300])),
                    options: CarouselOptions(
                      height: 150.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // ✅ Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        "Video Editing",
                        "Workshop",
                        "Design",
                        "Music",
                        "Drama",
                        "Filmmaking",
                        "Cinematography"
                      ].map((label) => _buildCategoryChip(label)).toList(),
                    ),
                  ),
                  SizedBox(height: 10),

                  // ✅ TabBar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: "Upcoming"),
                      Tab(text: "Followed Clubs"),
                      Tab(text: "My Interests"),
                    ],
                  ),

                  // ✅ TabBarView with Scrollable Events List
                  Container(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEventList(_upcomingEvents),
                        _buildEventList(_followedClubEvents),
                        _buildEventList(_myInterestEvents),
                      ],
                    ),
                  ),

                  // ✅ Clubs List
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Clubs",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildClubList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Chip(label: Text(label), backgroundColor: Colors.grey[200]),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) return Center(child: Text("No events available"));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event["title"] ?? "No Title",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(event["club"] ?? ""),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16),
                    SizedBox(width: 5),
                    Text(event["date"] ?? "")
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 5),
                    Text(event["location"] ?? "")
                  ],
                ),
                Wrap(
                  children: (event["tags"] as List<dynamic>?)
                          ?.map((tag) => _buildCategoryChip(tag))
                          .toList() ??
                      [],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClubList() {
    if (_clubs.isEmpty) return Center(child: Text("No clubs available"));

    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return Container(
              width: 120,
              margin: EdgeInsets.only(right: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Prevent unnecessary stretching
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(club["image"] ?? ""),
                  ),
                  SizedBox(height: 5),
                  Text(
                    club["name"] ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Flexible(
                    // Ensures description doesn't overflow
                    child: Text(
                      club["description"] ?? "",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis, // Prevents text overflow
                      maxLines: 2, // Limit to 2 lines, adjust as needed
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
