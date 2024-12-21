import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_shopping/main.dart';
import 'buy_old_food.dart';
class ListTask extends StatefulWidget {
  const ListTask({super.key});

  @override
  State<ListTask> createState() => _ListTaskState();
}

class _ListTaskState extends State<ListTask> with RouteAware{
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = "Chưa hoàn thành";
  int _selectedIndex = 0;
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  ScrollController _scrollControllerAll = ScrollController();
  bool _isLoadingMoreAll = false;
  int _currentPageAll = 1;
  bool _hasMoreDataAll = true;
  ScrollController _scrollControllerUser = ScrollController();
  bool _isLoadingMoreUser = false;
  int _currentPageUser = 1;
  bool _hasMoreDataUser = true;
  String URL = dotenv.env['ROOT_URL']!;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<dynamic> listtaskall = [];
  List<dynamic> listtaskuser = [];
  Future<void> _loadSecureValues() async {
    try{
      token = await _secureStorage.read(key: 'auth_token');
      email = await _secureStorage.read(key: 'email');
      id = await _secureStorage.read(key: 'id');
      name = await _secureStorage.read(key: 'name');
      groupName = await _secureStorage.read(key: 'groupName');
      groupId = await _secureStorage.read(key: 'groupId');
      adminName = await _secureStorage.read(key: 'adminName');

    }catch(e){
      print('Error loading secure values: $e');
    }
  }
  Future<void> _fetchListTask() async{
    try{
      Map<String, dynamic> body = {
        'group': groupId!,
        "state": _selectedStatus,
        "startDate": _startDate == null ? "" : "${_startDate!.toLocal()}".split(' ')[0],
        "endDate": _endDate == null ? "" : "${_endDate!.toLocal()}".split(' ')[0],
        "page": 1,
        "limit": 3,
      };
      final response = await http.post(
        Uri.parse(URL + "/listtask/getAllListTasksByGroup"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if(responseData["code"] == 200){
        setState(() {
          listtaskall = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _fetchUserTask() async{
    try{
      Map<String, dynamic> body = {
        "name": name!,
        'group': groupId!,
        "state": _selectedStatus,
        "startDate": _startDate == null ? "" : "${_startDate!.toLocal()}".split(' ')[0],
        "endDate": _endDate == null ? "" : "${_endDate!.toLocal()}".split(' ')[0],
        "page": 1,
        "limit": 3,
      };
      final response = await http.post(
        Uri.parse(URL + "/listtask/getListTasksByNameAndGroup"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if(responseData["code"] == 200){
        setState(() {
          listtaskuser = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _loadMoreDataAll() async {
    if (!_hasMoreDataAll) return; // Không tải thêm nếu hết dữ liệu
    setState(() {
      _isLoadingMoreAll = true;
    });

    try {
      Map<String, dynamic> body = {
        'group': groupId!,
        "state": _selectedStatus,
        "startDate": _startDate == null ? "" : "${_startDate!.toLocal()}".split(' ')[0],
        "endDate": _endDate == null ? "" : "${_endDate!.toLocal()}".split(' ')[0],
        "page": _currentPageAll + 1, // Tăng số trang
        "limit": 3,
      };

      final response = await http.post(
        Uri.parse(URL + "/listtask/getAllListTasksByGroup"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (responseData["code"] == 200 && responseData['data'].isNotEmpty) {
        setState(() {
          listtaskall.addAll(responseData['data']); // Thêm dữ liệu mới vào danh sách
          _currentPageAll++;
        });
      } else {
        setState(() {
          _hasMoreDataAll = false; // Đánh dấu là hết dữ liệu
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

  Future<void> _refreshDataAll() async {
    setState(() {
      _currentPageAll = 1;
      _hasMoreDataAll = true;
    });

    await _fetchListTask(); // Gọi lại API fetch ban đầu
  }

  Future<void> _loadMoreDataUser() async {
    if (!_hasMoreDataUser) return; // Không tải thêm nếu hết dữ liệu
    setState(() {
      _isLoadingMoreUser = true;
    });

    try {
      Map<String, dynamic> body = {
        "name": name!,
        'group': groupId!,
        "state": _selectedStatus,
        "startDate": _startDate == null ? "" : "${_startDate!.toLocal()}".split(' ')[0],
        "endDate": _endDate == null ? "" : "${_endDate!.toLocal()}".split(' ')[0],
        "page": _currentPageUser + 1, // Tăng số trang
        "limit": 3,
      };

      final response = await http.post(
        Uri.parse(URL + "/listtask/getListTasksByNameAndGroup"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (responseData["code"] == 200 && responseData['data'].isNotEmpty) {
        setState(() {
          listtaskuser.addAll(responseData['data']); // Thêm dữ liệu mới vào danh sách
          _currentPageUser++;
        });
      } else {
        setState(() {
          _hasMoreDataUser = false; // Đánh dấu là hết dữ liệu
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

  Future<void> _refreshDataUser() async {
    setState(() {
      _currentPageUser = 1;
      _hasMoreDataUser = true;
    });

    await _fetchUserTask(); // Gọi lại API fetch ban đầu
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _scrollControllerAll.addListener(() {
  //     if (_scrollControllerAll.position.pixels >= _scrollControllerAll.position.maxScrollExtent && !_isLoadingMoreAll) {
  //       _loadMoreDataAll(); // Gọi hàm tải thêm dữ liệu
  //     }
  //   });
  //
  //   _scrollControllerUser.addListener(() {
  //     if (_scrollControllerUser.position.pixels >= _scrollControllerUser.position.maxScrollExtent && !_isLoadingMoreUser) {
  //       _loadMoreDataUser(); // Gọi hàm tải thêm dữ liệu
  //     }
  //   });
  //   _initializeData(); // Gọi fetch data ban đầu
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>); // Subscribe to route observer
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
    _fetchListTask();
    _fetchUserTask();
    _scrollControllerAll.addListener(() {
      if (_scrollControllerAll.position.pixels >= _scrollControllerAll.position.maxScrollExtent && !_isLoadingMoreAll) {
        _loadMoreDataAll(); // Gọi hàm tải thêm dữ liệu
      }
    });

    _scrollControllerUser.addListener(() {
      if (_scrollControllerUser.position.pixels >= _scrollControllerUser.position.maxScrollExtent && !_isLoadingMoreUser) {
        _loadMoreDataUser(); // Gọi hàm tải thêm dữ liệu
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
            onDateSelected: (date) async{
              setState(() {
                _startDate = date;
              });
              _fetchUserTask();
              _fetchListTask();
            },
          ),
          SizedBox(width: 16),
          _buildDatePicker(
            label: "Ngày kết thúc",
            selectedDate: _endDate,
            onDateSelected: (date) async{
              setState(() {
                _endDate = date;
              });
              _fetchUserTask();
              _fetchListTask();
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
              tabs: name == adminName ? const [
                Tab(text: "Quản lý"),
                Tab(text: "Được phân công"),
              ] : const [
                Tab(text: "Được phân công"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: name == adminName ? [
                  _buildListView("Quản lý"),
                  _buildListView("Được phân công"),
                ] : [
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
    if (type == "Được phân công") {
      if (listtaskuser == null || listtaskuser.isEmpty) {
        return Center(
          child: Text("Không có nhiệm vụ nào."),
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshDataUser, // Gọi hàm làm mới khi kéo xuống
        child: ListView.builder(
          controller: _scrollControllerUser, // Gắn ScrollController
          padding: EdgeInsets.all(16.0),
          itemCount: listtaskuser.length + (_isLoadingMoreUser ? 1 : 0), // Tăng số lượng item khi đang tải thêm
          itemBuilder: (context, index) {
            if (index == listtaskuser.length) {
              // Hiển thị loading spinner khi đang tải thêm
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final task = listtaskuser[index];
            String stateText;

            if (task['state'] == true) {
              stateText = 'Hoàn thành';
            } else {
              DateTime endDate = DateTime.parse(task['endDate']);
              DateTime today = DateTime.now();
              if (endDate.isBefore(today)) {
                stateText = 'Quá hạn';
              } else {
                stateText = 'Chưa hoàn thành';
              }
            }

            return _buildCard(
              type,
              task['foodName'],
              task['amount'].toString() + " " + task["unitName"],
              "${task['startDate']} - ${task['endDate']}",
              stateText,
              index,
            );
          },
        ),
      );
    } else {
      if (listtaskall == null || listtaskall.isEmpty) {
        return Center(
          child: Text("Không có nhiệm vụ nào."),
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshDataAll, // Gọi hàm làm mới khi kéo xuống
        child: ListView.builder(
          controller: _scrollControllerAll, // Gắn ScrollController
          padding: EdgeInsets.all(16.0),
          itemCount: listtaskall.length + (_isLoadingMoreAll ? 1 : 0), // Tăng số lượng item khi đang tải thêm
          itemBuilder: (context, index) {
            if (index == listtaskall.length) {
              // Hiển thị loading spinner khi đang tải thêm
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final task = listtaskall[index];
            String stateText;

            if (task['state'] == true) {
              stateText = 'Hoàn thành';
            } else {
              DateTime endDate = DateTime.parse(task['endDate']);
              DateTime today = DateTime.now();
              if (endDate.isBefore(today)) {
                stateText = 'Quá hạn';
              } else {
                stateText = 'Chưa hoàn thành';
              }
            }

            return _buildCard(
              type,
              task['foodName'],
              task['amount'].toString() + " " + task["unitName"],
              "${task['startDate']} - ${task['endDate']}",
              stateText,
              index,
            );
          },
        ),
      );
    }
  }

  Widget _buildCard(String type, String foodname, String amount, String duration, String status, int index, ) {
    bool isCompleted =
        type == "Được phân công" ? status == "Hoàn thành" : false;
    Future<http.Response> _createItemFromListTask(int index, int extraDays, String note) async {
      final url = Uri.parse('$URL/listtask/createItemFromListTask');
      final String addItemToRefrigeratorUrl = URL + "/groups/addItemToRefrigerator";

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'listTaskId': listtaskuser[index]["_id"], // Thay thế bằng ID của ListTask
          'extraDays': extraDays,
          'note': note,
        }),
      );
      if (response.statusCode == 200) {
        final createItemData = jsonDecode(response.body);

        if (createItemData['code'] == 201) {
          final item = createItemData['data'];
          final addItemBody = jsonEncode({
            "groupId": groupId,
            "item": item,
          });

          final addItemResponse = await http.post(
            Uri.parse(addItemToRefrigeratorUrl),
            headers: {"Content-Type": "application/json"},
            body: addItemBody,
          );

          if (addItemResponse.statusCode == 200) {
            final addItemData = jsonDecode(addItemResponse.body);
            if (addItemData['code'] == 700) {
              print(addItemData['message']);
            } else {
              print("Error: ${addItemData['message']}");
            }
          } else {
            print("HTTP Error (addItemToRefrigerator): ${addItemResponse.statusCode}");
          }
        } else {
          print("Error: ${createItemData['message']}");
        }
      } else {
        print("HTTP Error (createItem): ${response.statusCode}");
      }

      return response;
    }

    Future<http.Response> _deleteListTask(int index) async {
      final url = Uri.parse('$URL/listtask/deleteListTaskById');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'listTaskId': listtaskall[index]["_id"]
        }),
      );

      return response;
    }

    void _showConfirmDialog(BuildContext context, int index) {
      TextEditingController numberController = TextEditingController();
      TextEditingController textController = TextEditingController();
      int? enteredNumber; // Biến để lưu giá trị số
      String? enteredText;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Xác nhận"),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Đảm bảo dialog không chiếm toàn bộ chiều cao
              children: [
                Text("Bạn có chắc chắn muốn hoàn thành nhiệm vụ này?"),
                Text("Hạn sử dụng là bao nhiêu ngày?"),
                SizedBox(height: 10), // Khoảng cách giữa các widget
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number, // Bàn phím số
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nhập số",
                  ),
                  onChanged: (value) {
                    setState(() {
                      enteredNumber = int.tryParse(value); // Chuyển đổi giá trị nhập
                    });
                  },
                ),
                SizedBox(height: 20),
                Text("Ghi chú:"),
                SizedBox(height: 10), // Khoảng cách giữa các widget
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.text, // Bàn phím số
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Ghi chú",
                  ),
                  onChanged: (value) {
                    setState(() {
                      enteredText = value; // Chuyển đổi giá trị nhập
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng popup
                },
                child: Text("Hủy bỏ"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Kiểm tra nếu số ngày và ghi chú hợp lệ
                  if (enteredNumber != null && enteredText != null) {
                    try {
                      final response = await _createItemFromListTask(index, enteredNumber!, enteredText!);

                      if (response.statusCode == 200) {
                        Navigator.of(context).pop();
                        // Thông báo thành công (ví dụ: Toast, SnackBar, v.v)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nhiệm vụ đã hoàn thành")));
                      } else {
                        // Thông báo lỗi
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Có lỗi khi hoàn thành nhiệm vụ")));
                      }
                    } catch (error) {
                      print('Lỗi khi gọi API: $error');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể kết nối với máy chủ")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
                  }
                },
                child: Text("Xác nhận"),
              ),
            ],
          );
        },
      );
    }

    void _showDeleteConfirmDialog(BuildContext context, int index) {

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Xác nhận"),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Đảm bảo dialog không chiếm toàn bộ chiều cao
              children: [
                Text("Bạn có chắc chắn muốn xóa nhiệm vụ này?"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng popup
                },
                child: Text("Hủy bỏ"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final response = await _deleteListTask(index);

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xóa nhiệm vụ thành co")));
                    } else {
                      // Thông báo lỗi
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Có lỗi khi xóa nhiệm vụ")));
                    }
                  } catch (error) {
                    print('Lỗi khi gọi API: $error');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể kết nối với máy chủ")));
                  }
                },
                child: Text("Xác nhận"),
              ),
            ],
          );
        },
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Đảm bảo căn lề trái
                children: [
                  Text(
                    foodname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                onSelected: (value) {
                  switch (value) {
                    case "Chỉnh sửa":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyOldFood(foodName: listtaskall[index]["foodName"], unitName: listtaskall[index]["unitName"], amount: listtaskall[index]["amount"], startDate: DateTime.parse(listtaskall[index]["startDate"]), endDate: DateTime.parse(listtaskall[index]["endDate"]), memberName: listtaskall[index]["name"], memberEmail: listtaskall[index]["memberEmail"], note: listtaskall[index]["note"], id: listtaskall[index]["_id"]),
                        ),
                      );
                      break;
                    case "Xóa":
                      _showDeleteConfirmDialog(context, index);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: "Chỉnh sửa", child: Text("Chỉnh sửa")),
                  PopupMenuItem(value: "Xóa", child: Text("Xóa")),
                ],
                icon: Icon(Icons.more_vert),
              ),
            if (type == "Được phân công")
              IconButton(
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (status == "Chưa hoàn thành") {
                      _showConfirmDialog(context, index);
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
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


