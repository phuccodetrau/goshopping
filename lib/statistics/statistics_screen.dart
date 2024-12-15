import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:month_year_picker/month_year_picker.dart';

class StatisticsScreen extends StatefulWidget {
  final String groupId;

  StatisticsScreen({required this.groupId});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  late TabController _tabController;
  
  // Data for statistics
  List<Map<String, dynamic>> purchaseStats = [];
  List<Map<String, dynamic>> consumptionStats = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      setState(() => isLoading = true);
      
      print('Fetching stats for groupId: ${widget.groupId}');
      
      // Fetch purchase stats
      final purchaseResponse = await http.post(
        Uri.parse('$_url/listtask/getTaskStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId,
          'month': selectedDate.month,
          'year': selectedDate.year,
        }),
      );

      print('Purchase response status: ${purchaseResponse.statusCode}');
      print('Purchase response body: ${purchaseResponse.body}');

      // Fetch consumption stats
      final consumptionResponse = await http.post(
        Uri.parse('$_url/meal/getMealPlanStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId,
          'month': selectedDate.month,
          'year': selectedDate.year,
        }),
      );

      print('Consumption response status: ${consumptionResponse.statusCode}');
      print('Consumption response body: ${consumptionResponse.body}');

      if (purchaseResponse.statusCode == 200) {
        final purchaseData = jsonDecode(purchaseResponse.body);
        if (purchaseData['code'] == 700) {
          setState(() {
            purchaseStats = List<Map<String, dynamic>>.from(purchaseData['data']['stats']);
          });
        } else {
          print('Error in purchase data: ${purchaseData['message']}');
          setState(() => purchaseStats = []);
        }
      }

      if (consumptionResponse.statusCode == 200) {
        final consumptionData = jsonDecode(consumptionResponse.body);
        if (consumptionData['code'] == 700) {
          final data = consumptionData['data'];
          setState(() {
            consumptionStats = [
              {
                'recipeStats': List<Map<String, dynamic>>.from(data['recipeStats']),
                'foodConsumption': List<Map<String, dynamic>>.from(data['foodConsumption']),
              }
            ];
          });
          print('Loaded consumption stats: ${consumptionStats.first}');
        } else {
          print('Error in consumption data: ${consumptionData['message']}');
          setState(() => consumptionStats = []);
        }
      }

      setState(() => isLoading = false);
    } catch (error) {
      print("Error fetching statistics: $error");
      setState(() {
        isLoading = false;
        purchaseStats = [];
        consumptionStats = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Mua sắm'),
            Tab(text: 'Tiêu thụ'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDatePicker(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : purchaseStats.isEmpty && consumptionStats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có dữ liệu thống kê cho tháng ${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Vui lòng chọn tháng khác',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPurchaseStats(),
                          _buildConsumptionStats(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (purchaseStats.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biểu đồ mua sắm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPurchaseChart(),
                ],
              ),
            ),
            _buildPurchaseList(),
          ],
          if (purchaseStats.isEmpty) Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không có dữ liệu mua sắm trong tháng này',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (consumptionStats.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thống kê công thức sử dụng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildConsumptionChart(),
                ],
              ),
            ),
            _buildFoodConsumptionList(),
            _buildRecipeList(),
          ],
          if (consumptionStats.isEmpty) Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không có dữ liệu tiêu thụ trong tháng này',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thống kê tháng ${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chọn tháng',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 200,
                              width: double.maxFinite,
                              child: YearPicker(
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                selectedDate: selectedDate,
                                onChanged: (DateTime value) {
                                  Navigator.pop(context, value);
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 12,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedDate.month == (index + 1)
                                            ? Colors.green
                                            : Colors.grey[200],
                                      ),
                                      onPressed: () {
                                        final newDate = DateTime(
                                          selectedDate.year,
                                          index + 1,
                                        );
                                        Navigator.pop(context, newDate);
                                      },
                                      child: Text(
                                        'T${index + 1}',
                                        style: TextStyle(
                                          color: selectedDate.month == (index + 1)
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    isLoading = true;
                  });
                  await _fetchStatistics();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.green[700]),
                    SizedBox(width: 8),
                    Text(
                      'Chọn tháng',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseChart() {
    if (purchaseStats.isEmpty) return Container();
    
    final List<BarChartGroupData> barGroups = purchaseStats.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['totalAmount']?.toDouble() ?? 0,
            color: Colors.green[400],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: purchaseStats.map((e) => e['totalAmount']?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < purchaseStats.length) {
                    return Container(
                      margin: EdgeInsets.only(top: 8),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            purchaseStats[value.toInt()]['foodName'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 60,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsumptionChart() {
    if (consumptionStats.isEmpty) return Container();
    
    final recipeStats = consumptionStats.first['recipeStats'] as List;
    if (recipeStats.isEmpty) return Container();

    final List<PieChartSectionData> sections = recipeStats.map((stat) {
      final index = recipeStats.indexOf(stat);
      return PieChartSectionData(
        value: stat['totalUseCount']?.toDouble() ?? 0,
        title: '${stat['recipeName']}\n${stat['totalUseCount']}',
        color: Colors.primaries[index % Colors.primaries.length],
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildPurchaseList() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Chi tiết mua sắm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: purchaseStats.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final stat = purchaseStats[index];
              return ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.shopping_basket, color: Colors.green[400]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stat['foodName'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${stat['totalAmount']} ${stat['unitName']} - ${stat['purchaseCount']} lần mua',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                children: [
                  ...(stat['purchases'] as List).map((purchase) {
                    final date = DateTime.parse(purchase['date']);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 20, color: Colors.blue[400]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  purchase['memberEmail'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(left: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số lượng: ${purchase['amount']} ${stat['unitName']}',
                                  style: TextStyle(color: Colors.black87),
                                ),
                                if (purchase['note'] != null && purchase['note'].isNotEmpty)
                                  Text(
                                    'Ghi chú: ${purchase['note']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoodConsumptionList() {
    final foodConsumption = consumptionStats.first['foodConsumption'] as List;
    
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Thống kê thực phẩm tiêu thụ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: foodConsumption.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final food = foodConsumption[index];
              return ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.orange[400]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        food['foodName'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Tổng tiêu thụ: ${food['totalAmount'].toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                children: [
                  ...(food['usedInRecipes'] as List).map((usage) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[50],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              usage['recipeName'],
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${usage['amountPerUse']} × ${usage['useCount']} lần',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    if (consumptionStats.isEmpty) return Container();
    
    final recipeStats = consumptionStats.first['recipeStats'] as List;
    if (recipeStats.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Chi tiết sử dụng công thức',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recipeStats.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final stat = recipeStats[index];
              return ExpansionTile(
                title: Text(stat['recipeName']),
                subtitle: Text('Sử dụng ${stat['totalUseCount']} lần'),
                children: [
                  if (stat['description'] != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        stat['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chi tiết theo tuần:', 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        ...(stat['weeklyStats'] as List).map((week) => Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Tuần ${week['week']}: ${week['useCount']} lần'
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
} 