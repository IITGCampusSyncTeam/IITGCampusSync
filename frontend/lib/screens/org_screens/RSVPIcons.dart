import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class RSVPIcons extends StatelessWidget {

  final RSVP;
  RSVPIcons({super.key, required this.RSVP});

  late final count = 7; // number of visible avatars//set to 7 for testing change to RSVP.length

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Overlapping avatars
          count <= 5
              ? SizedBox(
                  width: count * 24.0, // enough width for overlapping
                  height: 35,
                  child: Stack(
                    children: List.generate(count, (index) {
                      return Positioned(
                        left: index * 24.0, // overlap amount
                        child: Container(
                          width: 34,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              : SizedBox(
                  width: 5.0 * 24.0 + 100.0, // enough width for overlapping
                  height: 35,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                        child: Stack(
                          children: List.generate(5, (index) {
                            return Positioned(
                              left: index * 18.0, // overlap amount
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.white),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4.5),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE4E4E7),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: Text(
                                '+${count - 5} RSVPs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: TextColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
