import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  final List<Map<String, String>> activities;
  final Color Function(String) getStatusColor;

  const ActivityList({
    Key? key,
    required this.activities,
    required this.getStatusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'No entries available',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              activity['name']![0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            activity['name']!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${activity['company']} · ${activity['role']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(activity['status']!).withOpacity(0.1),
                  border: Border.all(color: getStatusColor(activity['status']!).withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activity['status']!,
                  style: TextStyle(
                    color: getStatusColor(activity['status']!),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 6),
              IconButton(
                icon: Image.asset('assets/telephone.png', width: 30, height: 30),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${activity['name']}')),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/whatsapp.png', width: 30, height: 40),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Messaging ${activity['name']} via WhatsApp')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}