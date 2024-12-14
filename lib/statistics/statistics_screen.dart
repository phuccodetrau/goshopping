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
      final now = DateTime.now();
      
      // Fetch purchase statistics
      final purchaseResponse = await http.post(
        Uri.parse('$_url/listtask/getTaskStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId,
          'month': now.month,
          'year': now.year,
        }),
      );

      // Fetch consumption statistics
      final consumptionResponse = await http.post(
        Uri.parse('$_url/meal/getMealPlanStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId,
          'month': now.month,
          'year': now.year,
        }),
      );

      if (purchaseResponse.statusCode == 200 && consumptionResponse.statusCode == 200) {
        final purchaseData = jsonDecode(purchaseResponse.body);
        final consumptionData = jsonDecode(consumptionResponse.body);

        setState(() {
          purchaseStats = List<Map<String, dynamic>>.from(purchaseData['data']['stats']);
          consumptionStats = List<Map<String, dynamic>>.from(consumptionData['data']['stats']);
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching statistics: $error");
      setState(() {
        isLoading = false;
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPurchaseStats(),
                _buildConsumptionStats(),
              ],
            ),
    );
  }

  Widget _buildPurchaseStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDatePicker(),
          _buildPurchaseChart(),
          _buildPurchaseList(),
        ],
      ),
    );
  }

  Widget _buildConsumptionStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDatePicker(),
          _buildConsumptionChart(),
          _buildConsumptionList(),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: EdgeInsets.all(16),
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
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showMonthYearPicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  isLoading = true;
                });
                _fetchStatistics();
              }
            },
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
            color: Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
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
                    return Text(
                      purchaseStats[value.toInt()]['foodName'].toString().substring(0, 3),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10),
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

    final List<PieChartSectionData> sections = consumptionStats.map((stat) {
      final index = consumptionStats.indexOf(stat);
      return PieChartSectionData(
        value: stat['useCount']?.toDouble() ?? 0,
        title: '${stat['recipeName']}\n${stat['useCount']}',
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
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: purchaseStats.length,
      itemBuilder: (context, index) {
        final stat = purchaseStats[index];
        return ListTile(
          title: Text(stat['foodName']),
          subtitle: Text('${stat['totalAmount']} ${stat['unitName']}'),
          trailing: Text('${stat['totalCost']} đ'),
        );
      },
    );
  }

  Widget _buildConsumptionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: consumptionStats.length,
      itemBuilder: (context, index) {
        final stat = consumptionStats[index];
        final weeklyStats = stat['weeklyStats'] as List;
        
        return ExpansionTile(
          title: Text(stat['recipeName']),
          subtitle: Text('Sử dụng ${stat['totalUseCount']} lần'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chi tiết theo tuần:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...weeklyStats.map((week) => Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Tuần ${week['week']}: ${week['useCount']} lần'),
                  )).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 