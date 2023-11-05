import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Upcoming Activities',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Icon(Icons.search),
                ],
              ),
            ),
            ActivityTile(
              importance: 'Urgent',
              imageUrl:
                  'https://content.presspage.com/uploads/1950/1920_floods1.jpg?10000', // Replace with your image URL
              title: 'Flood Recovery at Pahang',
              description:
                  'Volunteers are needed to clean victims houses. Donations are needed in terms of money and daily necessities.',
              date: '23 May 2023',
            ),
            ActivityTile(
              importance: 'Trivial',
              imageUrl:
                  'https://lamankhaira.com.my/wp-content/uploads/2021/03/Aktiviti-Semasa-Lawatan-ke-Rumah-Orang-Tua.jpg', // Replace with your image URL
              title: 'Cleaning Old Folks home at Selangor',
              description:
                  'Volunteers are needed to help clean the old folks home.',
              date: '5 July 2023',
            ),
            ActivityTile(
              importance: 'Trivial',
              imageUrl:
                  'https://www.mmu.edu.my/wp-content/uploads/2022/10/Slide2-8.jpg', // Replace with your image URL
              title: 'Planting trees at MMU',
              description:
                  'Volunteers are needed to plant, water and fertilize trees. Donations can be made in terms of money.',
              date: '15 August 2023',
            ),
            SizedBox(
                height:
                    16), // Add some spacing between the last item and "See more..."
            Align(
              alignment: Alignment.center,
              child: Text('See more...', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String importance;
  final String imageUrl;
  final String title;
  final String description;
  final String date;

  ActivityTile({
    required this.importance,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(importance,
                    style: TextStyle(
                        color: importance == 'Urgent'
                            ? Colors.red
                            : Colors.green)),
                Spacer(),
                Text(date),
              ],
            ),
            SizedBox(height: 10),
            Image.network(
              imageUrl, // Use the provided image URL
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(description),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      title: title,
                      description: description,
                      date: date,
                    ),
                  ),
                );
              },
              child: Text('Register here'),
            )
          ],
        ),
      ),
    );
  }
}

class EventDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  EventDetailPage({
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), // Add some spacing
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Date: $date'),
            SizedBox(height: 10),
            Text(description),
            ElevatedButton(
              onPressed: () {
                // Add your registration logic here
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
