import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:go_shopping/group/list_task.dart';
import 'package:go_shopping/main.dart';

class UserTasksScreen extends StatefulWidget {
  final String email;

  const UserTasksScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<UserTasksScreen> createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends State<UserTasksScreen> with RouteAware {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  List<dynamic> tasks = [];
  bool isLoading = true;
  String selectedFilter = "Tất cả";
  int currentPage = 1;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _fetchTasks(); // Reload data when returning from another screen
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (hasMoreData && !isLoading) {
        currentPage++;
        _fetchTasks(loadMore: true);
      }
    }
  }

  Future<void> _fetchTasks({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        isLoading = true;
        currentPage = 1;
      });
    }

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.post(
        Uri.parse('$_url/listtask/getTasksByMemberEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'memberEmail': widget.email,
          'state': selectedFilter,
          'page': currentPage,
          'limit': 10,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          setState(() {
            if (loadMore) {
              tasks.addAll(data['data']['tasks']);
            } else {
              tasks = data['data']['tasks'];
            }
            hasMoreData = tasks.length < data['data']['pagination']['totalRecords'];
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print("Error fetching tasks: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getStatusColor(dynamic task) {
    final now = DateTime.now();
    final endDate = DateTime.parse(task['endDate']);
    final bool isCompleted = task['state'];

    if (isCompleted) {
      return 'Hoàn thành';
    } else if (endDate.isBefore(now)) {
      return 'Quá hạn';
    } else {
      return 'Đang thực hiện';
    }
  }

  Color _getStatusColorCode(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Colors.green;
      case 'Quá hạn':
        return Colors.red;
      case 'Đang thực hiện':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.green[700],
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = label;
          _fetchTasks();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách công việc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Tất cả"),
                  SizedBox(width: 8),
                  _buildFilterChip("Chưa hoàn thành"),
                  SizedBox(width: 8),
                  _buildFilterChip("Hoàn thành"),
                  SizedBox(width: 8),
                  _buildFilterChip("Quá hạn"),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading && tasks.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                    ),
                  )
                : tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có công việc nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.green[700],
                        onRefresh: () => _fetchTasks(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: tasks.length + (hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == tasks.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                                  ),
                                ),
                              );
                            }

                            final task = tasks[index];
                            final status = _getStatusColor(task);
                            final statusColor = _getStatusColorCode(status);

                            return GestureDetector(
                              onTap: () {
                                if (status == 'Đang thực hiện') {
                                  _secureStorage.write(key: 'groupId', value: task['groupId']);
                                  _secureStorage.write(key: 'groupName', value: task['groupName']);
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListTask(),
                                    ),
                                  ).then((_) {
                                    _fetchTasks();
                                  });
                                }
                              },
                              child: Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: status == 'Đang thực hiện' 
                                      ? Border.all(color: Colors.green[700]!, width: 2)
                                      : null,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task['taskName'],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(color: Colors.grey[300], thickness: 1, height: 20),
                                        // Thông tin nhóm
                                        Row(
                                          children: [
                                            Icon(Icons.group, size: 20, color: Colors.green[700]),
                                            SizedBox(width: 8),
                                            Text(
                                              'Nhóm:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              task['groupName'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        // Thông tin thực phẩm
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.shopping_basket, size: 20, color: Colors.green[700]),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Thực phẩm:',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding: EdgeInsets.only(left: 28),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      task['foodName'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green[800],
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Số lượng: ${task['amount']} ${task['unitName']}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        // Thời gian
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: DateTime.parse(task['endDate']).isBefore(DateTime.now())
                                                ? Colors.red[50]
                                                : Colors.orange[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.event,
                                                    size: 20,
                                                    color: DateTime.parse(task['endDate']).isBefore(DateTime.now())
                                                        ? Colors.red
                                                        : Colors.orange[700],
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Thời gian:',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding: EdgeInsets.only(left: 28),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(task['startDate']))}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Kết thúc: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(task['endDate']))}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: DateTime.parse(task['endDate']).isBefore(DateTime.now())
                                                            ? Colors.red
                                                            : Colors.grey[800],
                                                        fontWeight: DateTime.parse(task['endDate']).isBefore(DateTime.now())
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (task['note']?.isNotEmpty ?? false) ...[
                                          SizedBox(height: 12),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.note, size: 20, color: Colors.grey[600]),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Ghi chú:',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 28),
                                                  child: Text(
                                                    task['note'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (status == 'Đang thực hiện') ...[
                                          SizedBox(height: 12),
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.green[700]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.touch_app,
                                                    size: 16,
                                                    color: Colors.green[700],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Nhấn để xem chi tiết',
                                                    style: TextStyle(
                                                      color: Colors.green[700],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} 