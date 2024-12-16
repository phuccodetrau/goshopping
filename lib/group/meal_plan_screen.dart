import 'package:flutter/material.dart';
import 'meal_detail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MealPlanScreen extends StatefulWidget {
  final String groupId;
  final String email;

  MealPlanScreen({
    required this.groupId,
    required this.email,
  });

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  Map<String, List<dynamic>> mealsByTime = {
    'Bữa sáng': [],
    'Bữa trưa': [],
    'Bữa xế': [],
    'Bữa tối': [],
  };
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  Future<void> _onDateChanged(DateTime newDate) async {
    setState(() {
      selectedDate = newDate;
      isLoading = true; // Hiển thị loading khi đang fetch dữ liệu m��i
    });
    await _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    try {
      setState(() => isLoading = true);
      
      final String? token = await _secureStorage.read(key: "auth_token");
      final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      
      print("Fetching meal plans for date: $formattedDate");
      
      final response = await http.post(
        Uri.parse('$_url/meal/getMealPlanByDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "group": widget.groupId,
          "date": formattedDate,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Reset mealsByTime với danh sách rỗng cho mỗi bữa
      setState(() {
        mealsByTime = {
          'Bữa sáng': [],
          'Bữa trưa': [],
          'Bữa xế': [],
          'Bữa tối': [],
        };
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700 && data['data'] != null) {
          for (var mealPlan in data['data']) {
            final String course = mealPlan['course'];
            if (mealPlan['listRecipe'] != null) {
              if (mealsByTime.containsKey(course)) {
                final List<Map<String, dynamic>> recipes = [];
                for (var recipe in mealPlan['listRecipe']) {
                  recipes.add({
                    'name': recipe['name'] ?? 'Không có tên',
                    'description': recipe['description'] ?? '',
                  });
                }
                setState(() {
                  mealsByTime[course] = recipes;
                });
              }
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching meal plans: $error");
      setState(() {
        isLoading = false;
        mealsByTime = {
          'Bữa sáng': [],
          'Bữa trưa': [],
          'Bữa xế': [],
          'Bữa tối': [],
        };
      });
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi tải dữ liệu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
        : RefreshIndicator(
            onRefresh: _fetchMealPlans,
            color: Colors.green[700],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateSelector(
                    selectedDate: selectedDate,
                    onDateChanged: _onDateChanged,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Bữa ăn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: mealsByTime.entries.map((entry) {
                        return MealCard(
                          mealTime: entry.key,
                          timeRange: _getTimeRange(entry.key),
                          items: entry.value.map((recipe) => recipe['name'].toString()).toList(),
                          peopleCount: entry.value.length,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailScreen(
                                  groupId: widget.groupId,
                                  email: widget.email,
                                  selectedDate: selectedDate,
                                  selectedMealTime: entry.key,
                                ),
                              ),
                            );
                            
                            if (result == true) {
                              _fetchMealPlans();
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _getTimeRange(String mealTime) {
    switch (mealTime) {
      case 'Bữa sáng':
        return '7:30 - 8:30 AM';
      case 'Bữa trưa':
        return '11:00 - 12:00 PM';
      case 'Bữa xế':
        return '4:30 - 5:30 PM';
      case 'Bữa tối':
        return '6:30 - 7:30 PM';
      default:
        return '';
    }
  }
}

class MealCard extends StatefulWidget {
  final String mealTime;
  final String timeRange;
  final List<String> items;
  final int peopleCount;
  final VoidCallback onTap;

  MealCard({
    required this.mealTime,
    required this.timeRange,
    required this.items,
    required this.peopleCount,
    required this.onTap,
  });

  @override
  _MealCardState createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
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
                    widget.mealTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.mealTime == 'Bữa sáng' ? Colors.orange : Colors.blue,
                    ),
                  ),
                  Text(
                    widget.timeRange,
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
                children: widget.items
                    .map((item) => Chip(
                          label: Text(item),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.green[700]!),
                          ),
                          backgroundColor: Colors.green[200],
                        ))
                    .toList(),
              ),
              SizedBox(height: 8),

            ],
          ),
        ),
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút previous
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.green[700], size: 20),
            onPressed: () => onDateChanged(
              selectedDate.subtract(Duration(days: 1)),
            ),
          ),
          // Hiển thị ngày và nút chọn lịch
          InkWell(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nút next
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.green[700], size: 20),
            onPressed: () => onDateChanged(
              selectedDate.add(Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Lấy ngày hiện tại
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    // So sánh với ngày được chọn (chỉ so sánh ngày, tháng, năm)
    final selectedDay = DateTime(date.year, date.month, date.day);
    final nowDay = DateTime(now.year, now.month, now.day);
    
    if (selectedDay == nowDay) {
      return 'Hôm nay, ${date.day}/${date.month}';
    } else if (selectedDay == tomorrow) {
      return 'Ngày mai, ${date.day}/${date.month}';
    } else if (selectedDay == yesterday) {
      return 'Hôm qua, ${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700], // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
