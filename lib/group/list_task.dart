import 'package:flutter/material.dart';

class ListTask extends StatefulWidget {
  const ListTask({super.key});

  @override
  State<ListTask> createState() => _ListTaskState();
}

class _ListTaskState extends State<ListTask> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = "Tất cả"; // Lựa chọn mặc định
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildStatusFilter(), // Thêm dropdown lọc trạng thái
          _buildTabBarView(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Cộng đồng',
        style: TextStyle(
          fontSize: 24,
          color: Colors.green[900],
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.grey[700]),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildDatePicker(
            label: "Ngày bắt đầu",
            selectedDate: _startDate,
            onDateSelected: (date) {
              setState(() {
                _startDate = date;
              });
            },
          ),
          SizedBox(width: 16),
          _buildDatePicker(
            label: "Ngày kết thúc",
            selectedDate: _endDate,
            onDateSelected: (date) {
              setState(() {
                _endDate = date;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              items: ["Tất cả", "Hoàn thành", "Chưa hoàn thành"]
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedDate != null
                      ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                      : label,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              Icon(Icons.calendar_today, color: Colors.grey[700]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.green[900],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green[900],
              tabs: const [
                Tab(text: "Quản lý"),
                Tab(text: "Được phân công"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildListView("Quản lý"),
                  _buildListView("Được phân công"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(String type) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildCard("$type - Mục $index");
      },
    );
  }

  Widget _buildCard(String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Action khi nhấn nút
      },
      backgroundColor: Colors.green[700],
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green[700],
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
