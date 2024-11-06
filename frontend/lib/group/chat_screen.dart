import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('images/group.png'),
            ),
            SizedBox(width: 10),
            Text(
              'Gia đình bên nội',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: Colors.green),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Center(
                  child: Text(
                    'Today',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('images/group.png'),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jhon Abraham',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Hello! Nazrul How are you?'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '09:25 AM',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'You did your job well!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '09:25 AM',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
