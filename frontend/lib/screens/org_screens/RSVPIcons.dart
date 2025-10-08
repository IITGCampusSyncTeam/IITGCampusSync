import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class RSVPIcons extends StatefulWidget {
  final List<String> RSVP;

  const RSVPIcons({super.key, required this.RSVP});

  @override
  State<RSVPIcons> createState() => _RSVPIconsState();
}

class _RSVPIconsState extends State<RSVPIcons> {
  late final int count;
  List<String>? userImages;

  @override
  void initState() {
    super.initState();
    count = widget.RSVP.length;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    //TODO : implement fetchUserData()
  }

  @override
  Widget build(BuildContext context) {
    // Handle the case where the RSVP list is empty.
    if (count == 0) {
      return const SizedBox.shrink(); // Or any other placeholder widget
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        // Using MainAxisAlignment.start to align items to the left.
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Overlapping avatars
          if (count <= 5)
            SizedBox(
              width: count * 18.0 + 10, // enough width for overlapping
              height: 28, // Increased height to prevent clipping
              child: Stack(
                children: List.generate(count, (index) {
                  return Positioned(
                    left: index * 18.0, // overlap amount
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // More direct than borderRadius
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: CircleAvatar(
                        radius: 12,
                        // Access the list via widget.RSVP
                        backgroundImage: NetworkImage(userImages == null
                            ? ""
                            : userImages![index]),
                      ),
                    ),
                  );
                }),
              ),
            )
          else
            SizedBox(
              // Adjusted width for 5 avatars + the "+N" badge
              width: (5 * 18.0) + 10 + 65,
              height: 28, // Increased height to prevent clipping
              child: Stack(
                children: [
                  // Generate the first 5 avatars
                  ...List.generate(5, (index) {
                    return Positioned(
                      left: index * 18.0, // overlap amount
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2)),
                        child: CircleAvatar(
                          radius: 12,
                          // Access the list via widget.RSVP
                          backgroundImage: NetworkImage(userImages == null
                              ? ""
                              : userImages![index]),
                        ),
                      ),
                    );
                  }),
                  // Position the "+N RSVPs" badge
                  Positioned(
                    left: 5 * 18.0, // Position after the 5th avatar
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE4E4E7),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white, width: 2)),
                      child: Center(
                        child: Text(
                          '+${count - 5}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: TextColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
