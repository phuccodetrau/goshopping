import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MealPlanScreen(),
    );
  }
}

class MealPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kế hoạch nấu ăn', style: TextStyle(color: Colors.green[700])),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.green[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            DateSelector(),
            SizedBox(height: 16),
            Text(
              'Bữa ăn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  MealCard(
                    mealTime: 'Bữa sáng',
                    timeRange: '7:30 - 8:30 AM',
                    items: [
                      'Phở bò x5',
                      'Cháo thịt băm x3',
                      'Sữa đậu nành x5',
                    ],
                    peopleCount: 5,
                  ),
                  MealCard(
                    mealTime: 'Bữa trưa',
                    timeRange: '11:00 - 12:00 PM',
                    items: [
                      'Nem cuốn x5',
                      'Đậu phụ rán x3',
                      'Sữa đậu nành x5',
                    ],
                    peopleCount: 5,
                  ),
                  MealCard(
                    mealTime: 'Bữa xế',
                    timeRange: '4:30 - 5:30 PM',
                    items: [
                      'Phở bò x5',
                      'Cháo thịt băm x3',
                    ],
                    peopleCount: 4,
                  ),
                  MealCard(
                    mealTime: 'Bữa tối',
                    timeRange: '6:30 - 7:30 PM',
                    items: [
                      'Cơm gà x4',
                      'Canh chua x4',
                    ],
                    peopleCount: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.arrow_back_ios, color: Colors.green[700]),
        Column(
          children: [
            Text(
              'Tháng 12, 2024',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Text(
                        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: index == 0 ? Colors.green[700] : Colors.transparent,
                        child: Text(
                          '${index + 5}',
                          style: TextStyle(
                            color: index == 0 ? Colors.white : Colors.black87,
                            fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  final String mealTime;
  final String timeRange;
  final List<String> items;
  final int peopleCount;

  MealCard({
    required this.mealTime,
    required this.timeRange,
    required this.items,
    required this.peopleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mealTime == 'Bữa sáng' ? Colors.orange : Colors.blue,
                  ),
                ),
                Text(
                  timeRange,
                  style: TextStyle(
                    color: Colors.green[700],
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: items
                  .map((item) => Chip(
                label: Text(item),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Điều chỉnh góc bo tròn ở đây
                  side: BorderSide(color: Colors.green[700]!), // Đặt màu viền nếu muốn
                ),
                backgroundColor: Colors.green[200],
              ))
                  .toList(),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, color: Colors.grey),
                SizedBox(width: 4),
                Text('$peopleCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
