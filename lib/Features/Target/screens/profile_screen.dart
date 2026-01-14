import 'package:flutter/material.dart';
import '../widgets/user_post.dart';
import '../widgets/stats_box.dart';
import '../widgets/goal_card.dart';
import '../widgets/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock DB data
  final String pageTitle = "Target Page";
  final String userName = "Ashif Khan";
  final String userPost = "Account";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(pageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Name + Post
            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  UserPost(post: userPost),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: const [
                StatsBox(
                  title: "Tasks Completed",
                  value: "24",
                  color: Color(0xFF4CAF50),
                ),
                StatsBox(
                  title: "Attendance",
                  value: "92%",
                  color: Color(0xFF2196F3),
                ),
                StatsBox(
                  title: "Leaves",
                  value: "3",
                  color: Color(0xFFFF9800),
                ),
                StatsBox(
                  title: "More",
                  value: "--",
                  color: Color(0xFF9C27B0),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// Top Goals Section
            const SectionTitle(title: "Top Goals"),
            const SizedBox(height: 12),

            const GoalCard(
              title: "Payment of ABC company",
              subtitle: "Complete remaining payment",
              progress: 0.7,
            ),
            const GoalCard(
              title: "GST calculation",
              subtitle: "Calculate the Tax invoice",
              progress: 0.5,
            ),


            const SizedBox(height: 32),

            /// Other Goals Section
            const SectionTitle(title: "Other Goals"),
            const SizedBox(height: 12),

            const GoalCard(
              title: "Work given by Aqueel Sir",
              subtitle: "Extra Goal",
              progress: 0.6,
            ),
          ],
        ),
      ),
    );
  }
}
