import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_shopping/main.dart';
import '../../repositories/list_task_repository.dart';
import '../../services/list_task_service.dart';

class ListTaskScreen extends StatefulWidget {
  const ListTaskScreen({super.key});

  @override
  State<ListTaskScreen> createState() => _ListTaskScreenState();
}

class _ListTaskScreenState extends State<ListTaskScreen> with RouteAware {
  final ListTaskRepository _repository = ListTaskRepository(
    taskService: ListTaskService(),
    storage: const FlutterSecureStorage(),
  );

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = "Chưa hoàn thành";
  int _selectedIndex = 0;
  String? email;
  String? id;
  String? name;
  String? groupName;
  String? groupId;
  String? adminName;
  
  final ScrollController _scrollControllerAll = ScrollController();
  bool _isLoadingMoreAll = false;
  int _currentPageAll = 1;
  bool _hasMoreDataAll = true;
  
  final ScrollController _scrollControllerUser = ScrollController();
  bool _isLoadingMoreUser = false;
  int _currentPageUser = 1;
  bool _hasMoreDataUser = true;
  
  List<dynamic> listtaskall = [];
  List<dynamic> listtaskuser = [];

  Future<void> _loadSecureValues() async {
    try {
      final storage = const FlutterSecureStorage();
      email = await storage.read(key: 'email');
      id = await storage.read(key: 'id');
      name = await storage.read(key: 'name');
      groupName = await storage.read(key: 'groupName');
      groupId = await storage.read(key: 'groupId');
      adminName = await storage.read(key: 'adminName');
    } catch (e) {
      print('Error loading secure values: $e');
    }
  }

  Future<void> _fetchListTask() async {
    try {
      final tasks = await _repository.getAllListTasksByGroupPaginated(
        groupId: groupId!,
        state: _selectedStatus,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        page: 1,
        limit: 3,
      );
      setState(() {
        listtaskall = tasks;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchUserTask() async {
    try {
      final tasks = await _repository.getListTasksByNameAndGroupPaginated(
        name: name!,
        groupId: groupId!,
        state: _selectedStatus,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        page: 1,
        limit: 3,
      );
      setState(() {
        listtaskuser = tasks;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadMoreDataAll() async {
    if (!_hasMoreDataAll) return;
    setState(() {
      _isLoadingMoreAll = true;
    });

    try {
      final tasks = await _repository.getAllListTasksByGroupPaginated(
        groupId: groupId!,
        state: _selectedStatus,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        page: _currentPageAll + 1,
        limit: 3,
      );

      if (tasks.isNotEmpty) {
        setState(() {
          listtaskall.addAll(tasks);
          _currentPageAll++;
        });
      } else {
        setState(() {
          _hasMoreDataAll = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoadingMoreAll = false;
      });
    }
  }

  Future<void> _loadMoreDataUser() async {
    if (!_hasMoreDataUser) return;
    setState(() {
      _isLoadingMoreUser = true;
    });

    try {
      final tasks = await _repository.getListTasksByNameAndGroupPaginated(
        name: name!,
        groupId: groupId!,
        state: _selectedStatus,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        page: _currentPageUser + 1,
        limit: 3,
      );

      if (tasks.isNotEmpty) {
        setState(() {
          listtaskuser.addAll(tasks);
          _currentPageUser++;
        });
      } else {
        setState(() {
          _hasMoreDataUser = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoadingMoreUser = false;
      });
    }
  }

  Future<void> _refreshDataAll() async {
    setState(() {
      _currentPageAll = 1;
      _hasMoreDataAll = true;
    });
    await _fetchListTask();
  }

  Future<void> _refreshDataUser() async {
    setState(() {
      _currentPageUser = 1;
      _hasMoreDataUser = true;
    });
    await _fetchUserTask();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    _initializeData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchListTask();
    await _fetchUserTask();
    _scrollControllerAll.addListener(() {
      if (_scrollControllerAll.position.pixels >= _scrollControllerAll.position.maxScrollExtent && !_isLoadingMoreAll) {
        _loadMoreDataAll();
      }
    });
    _scrollControllerUser.addListener(() {
      if (_scrollControllerUser.position.pixels >= _scrollControllerUser.position.maxScrollExtent && !_isLoadingMoreUser) {
        _loadMoreDataUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildStatusFilter(),
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
        'Nhiệm vụ',
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
            onDateSelected: (date) async {
              setState(() {
                _startDate = date;
              });
              await _fetchUserTask();
              await _fetchListTask();
            },
          ),
          const SizedBox(width: 16),
          _buildDatePicker(
            label: "Ngày kết thúc",
            selectedDate: _endDate,
            onDateSelected: (date) async {
              setState(() {
                _endDate = date;
              });
              await _fetchUserTask();
              await _fetchListTask();
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
              items: ["Tất cả", "Hoàn thành", "Chưa hoàn thành", "Quá hạn"]
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
          final DateTime? pickedDate = await showDatePicker(
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
        length: name == adminName ? 2 : 1,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.green[900],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green[900],
              tabs: name == adminName
                  ? const [
                      Tab(text: "Quản lý"),
                      Tab(text: "Được phân công"),
                    ]
                  : const [
                      Tab(text: "Được phân công"),
                    ],
            ),
            Expanded(
              child: TabBarView(
                children: name == adminName
                    ? [
                        _buildListView("Quản lý"),
                        _buildListView("Được phân công"),
                      ]
                    : [
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
    final tasks = type == "Được phân công" ? listtaskuser : listtaskall;
    final isLoading = type == "Được phân công" ? _isLoadingMoreUser : _isLoadingMoreAll;
    final scrollController = type == "Được phân công" ? _scrollControllerUser : _scrollControllerAll;
    final onRefresh = type == "Được phân công" ? _refreshDataUser : _refreshDataAll;

    if (tasks.isEmpty) {
      return const Center(
        child: Text("Không có nhiệm vụ nào."),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: tasks.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tasks.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final task = tasks[index];
          String stateText;

          if (task['state'] == true) {
            stateText = 'Hoàn thành';
          } else {
            final endDate = DateTime.parse(task['endDate']);
            final today = DateTime.now();
            stateText = endDate.isBefore(today) ? 'Quá hạn' : 'Chưa hoàn thành';
          }

          return _buildCard(
            type,
            task['foodName'],
            "${task['amount']} ${task['unitName']}",
            "${task['startDate']} - ${task['endDate']}",
            stateText,
            index,
            task,
          );
        },
      ),
    );
  }

  Widget _buildCard(
    String type,
    String foodname,
    String amount,
    String duration,
    String status,
    int index,
    Map<String, dynamic> task,
  ) {
    final bool isCompleted = type == "Được phân công" && status == "Hoàn thành";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodname,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    amount,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    duration,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    status,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (type == "Quản lý")
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case "Chỉnh sửa":
                      // TODO: Navigate to edit screen
                      break;
                    case "Xóa":
                      await _showDeleteConfirmDialog(context, task['_id']);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "Chỉnh sửa", child: Text("Chỉnh sửa")),
                  const PopupMenuItem(value: "Xóa", child: Text("Xóa")),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            if (type == "Được phân công")
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  if (status == "Chưa hoàn thành") {
                    _showCompleteConfirmDialog(context, task['_id']);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCompleteConfirmDialog(BuildContext context, String taskId) async {
    final TextEditingController extraDaysController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bạn có chắc chắn muốn hoàn thành nhiệm vụ này?"),
            const Text("Hạn sử dụng là bao nhiêu ngày?"),
            const SizedBox(height: 10),
            TextField(
              controller: extraDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nhập số",
              ),
            ),
            const SizedBox(height: 20),
            const Text("Ghi chú:"),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Ghi chú",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy bỏ"),
          ),
          ElevatedButton(
            onPressed: () async {
              final extraDays = int.tryParse(extraDaysController.text);
              final note = noteController.text;

              if (extraDays != null && note.isNotEmpty) {
                try {
                  final success = await _repository.completeListTaskWithItem(
                    listTaskId: taskId,
                    extraDays: extraDays,
                    note: note,
                    groupId: groupId!,
                  );

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nhiệm vụ đã hoàn thành")),
                    );
                    await _refreshDataUser();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: $e")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                );
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, String taskId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa nhiệm vụ này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy bỏ"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repository.deleteTask(taskId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xóa nhiệm vụ thành công")),
                );
                await _refreshDataAll();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: $e")),
                );
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to add task screen
      },
      backgroundColor: Colors.green[700],
      child: const Icon(Icons.add, color: Colors.white),
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