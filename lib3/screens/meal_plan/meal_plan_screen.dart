import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/meal_plan_repository.dart';
import '../../services/meal_plan_service.dart';

class MealPlanScreen extends StatefulWidget {
  final String groupId;
  final String email;

  const MealPlanScreen({
    super.key,
    required this.groupId,
    required this.email,
  });

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  Map<String, List<dynamic>> mealsByTime = {
    'Bữa sáng': [],
    'Bữa trưa': [],
    'Bữa xế': [],
    'Bữa tối': [],
  };
  bool _isLoading = false;
  String? _error;
  DateTime selectedDate = DateTime.now();
  late final MealPlanRepository _mealPlanRepository;

  @override
  void initState() {
    super.initState();
    _mealPlanRepository = MealPlanRepository(apiService: MealPlanService());
    _fetchMealPlans();
  }

  Future<void> _onDateChanged(DateTime newDate) async {
    setState(() {
      selectedDate = newDate;
      _isLoading = true;
      _error = null;
    });
    await _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      final meals = await _mealPlanRepository.getMealPlanByDate(token, widget.groupId, formattedDate);
      
      setState(() {
        mealsByTime = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        mealsByTime = {
          'Bữa sáng': [],
          'Bữa trưa': [],
          'Bữa xế': [],
          'Bữa tối': [],
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi tải dữ liệu'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có lỗi xảy ra',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchMealPlans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
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
                              final result = await Navigator.pushNamed(
                                context,
                                '/meal-detail',
                                arguments: {
                                  'groupId': widget.groupId,
                                  'email': widget.email,
                                  'selectedDate': selectedDate,
                                  'selectedMealTime': entry.key,
                                },
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
}

class MealCard extends StatelessWidget {
  final String mealTime;
  final String timeRange;
  final List<String> items;
  final int peopleCount;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.mealTime,
    required this.timeRange,
    required this.items,
    required this.peopleCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

  const DateSelector({
    super.key,
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
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.green[700], size: 20),
            onPressed: () => onDateChanged(
              selectedDate.subtract(Duration(days: 1)),
            ),
          ),
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
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
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
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700],
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
