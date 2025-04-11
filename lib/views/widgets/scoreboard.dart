import 'package:flutter/material.dart';

class PlayerScore extends StatelessWidget {
  final List userData;
  
  PlayerScore(this.userData);

  @override
  Widget build(BuildContext context) {
    // Sort players by score in descending order
    final sortedUsers = List.from(userData);
    sortedUsers.sort((a, b) {
      final scoreA = int.tryParse(a.values.elementAt(1)) ?? 0;
      final scoreB = int.tryParse(b.values.elementAt(1)) ?? 0;
      return scoreB.compareTo(scoreA);
    });

    final Color primaryColor = const Color.fromARGB(255, 238, 192, 9);
    
    return Drawer(
      child: Column(
        children: [
          // Simple header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            color: primaryColor,
            width: double.infinity,
            child: const Text(
              'Scoreboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Player list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                final data = sortedUsers[index].values;
                final username = data.elementAt(0).toString();
                final score = data.elementAt(1).toString();
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index < 3 ? 
                      [Colors.amber, Colors.grey, Colors.brown][index] : 
                      Colors.blue.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index < 3 ? Colors.white : Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    score,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Simple footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text('Back to Game'),
            ),
          ),
        ],
      ),
    );
  }
}