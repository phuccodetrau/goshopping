import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fridge.dart';
import 'package:http/http.dart' as http;

class BuyOldFood extends StatefulWidget {
  final String name;
  final String unitName;

  BuyOldFood({required this.name, required this.unitName});

  @override
  _BuyOldFoodState createState() => _BuyOldFoodState();
}

class _BuyOldFoodState extends State<BuyOldFood> {
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  DateTime? startDate;
  DateTime? endDate;
  String URL = dotenv.env['ROOT_URL']!;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<dynamic> listuser = [];
  int selectedUser = -1;
  ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  String note = "";
  int? amount;

  Future<void> _loadSecureValues() async {
    try {
      token = await _secureStorage.read(key: 'auth_token');
      email = await _secureStorage.read(key: 'email');
      id = await _secureStorage.read(key: 'id');
      name = await _secureStorage.read(key: 'name');
      groupName = await _secureStorage.read(key: 'groupName');
      groupId = await _secureStorage.read(key: 'groupId');
      adminName = await _secureStorage.read(key: 'adminName');
    } catch (e) {
      print('Error loading secure values: $e');
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response =
      await http.get(Uri.parse('$URL/groups/get-users-by-group-id/$groupId'));
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 700) {
        setState(() {
          listuser = responseData['data'];
          print(listuser.length);
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _addNewTask(memberName, memberEmail, note, start, end, foodName, amount, unitName, state, group) async{
    final String url = URL + "/listtask/createListTask";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': memberName,
          'memberEmail': memberEmail,
          'note': note,
          'startDate': start,
          'endDate': end,
          'foodName': foodName,
          'amount': amount,
          'unitName': unitName,
          'state': state,
          'group': group,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 700) {
          print("Phân công mới được tạo thành công!");
        } else {
          print("Lỗi: ${responseData['message']}");
        }
      } else {
        print("Lỗi từ server: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _addNewItem(foodName, expireDate, amount, unitName, note, group) async{
    final String createItemUrl = URL + "/item/createItem";
    final String addItemToRefrigeratorUrl = URL + "/groups/addItemToRefrigerator";

    try {
      final createItemBody = jsonEncode({
        "foodName": foodName,
        "expireDate": expireDate,
        "amount": amount,
        'unitName': unitName,
        "note": note,
        "group": group,
      });

      final createItemResponse = await http.post(
        Uri.parse(createItemUrl),
        headers: {"Content-Type": "application/json"},
        body: createItemBody,
      );

      if (createItemResponse.statusCode == 200) {
        final createItemData = jsonDecode(createItemResponse.body);

        if (createItemData['code'] == 700) {
          print(createItemData['message']);
          final item = createItemData['data'];
          final addItemBody = jsonEncode({
            "groupId": group,
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
        print("HTTP Error (createItem): ${createItemResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _postData(memberName, memberEmail, note, start, end, amount, state, group, expireDate) async {
    await _addNewTask(memberName, memberEmail, note, start, end, widget.name, amount, widget.unitName, state, group);
    await _addNewItem(widget.name, expireDate, amount, widget.unitName, note, group);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Action quay lại
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biểu ngữ trên cùng
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('images/fish.png'), // Đường dẫn đến ảnh biểu ngữ
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Tên thực phẩm",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              // Tên thực phẩm
              TextField(
                controller: TextEditingController(text: widget.name),
                decoration: InputDecoration(
                  labelText: "Tên thực phẩm",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 16),

              // Loại thực phẩm
              Text(
                "Loại thực phẩm",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),


              // Số lượng và phân công
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Số lượng",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number, // Chỉ nhập số
                      onChanged: (value) {
                        setState(() {
                          amount = int.tryParse(value); // Cập nhật giá trị của amount
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: widget.unitName,
                    items: <String>[widget.unitName].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {

                    },
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Phân công",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: listuser.map<DropdownMenuItem<String>>((user) {
                        return DropdownMenuItem<String>(
                          value: user['name'], // Giá trị sẽ là trường 'name'
                          child: Text(user['name']),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          // Cập nhật index khi người dùng chọn một giá trị mới
                          selectedUser = listuser.indexWhere((user) => user['name'] == newValue);
                        });
                        // In ra index của giá trị đã chọn
                        print("Selected index: $selectedUser");
                      },
                    )
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Thời gian thực hiện dự kiến
              Text(
                "Thời gian thực hiện dự kiến",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true), // Chọn startDate
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          startDate == null
                              ? "Chọn ngày bắt đầu"
                              : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false), // Chọn endDate
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          endDate == null
                              ? "Chọn ngày kết thúc"
                              : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Ghi chú",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    note = value;
                  });
                },
              ),
              SizedBox(height: 180),

              // Nút "Thêm"
              ValueListenableBuilder<bool>(
                valueListenable: isFoodName,
                builder: (context, isVisible, child) {
                  return Visibility(
                    visible: isVisible, // Dựa vào giá trị của isErrorVisible để hiển thị
                    child: const Text(
                      "Bạn chưa nhập đầy đủ thông tin về thực phẩm",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                },
              ),
              Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if(selectedUser == -1 ||
                        startDate == null ||
                        endDate == null ||
                        amount == null
                    )
                    {
                      isFoodName.value = true;
                    }else{
                      String memberName = listuser[selectedUser]["name"];
                      String memberEmail = listuser[selectedUser]["email"];
                      String formattedStartDate = "${startDate!.toLocal()}".split(' ')[0];
                      String formattedEndDate = "${endDate!.toLocal()}".split(' ')[0];
                      String formattedExpiredDate = "${DateTime.now().add(Duration(days: 30))}".split(' ')[0];
                      _postData(memberName, memberEmail, note, formattedStartDate, formattedEndDate, amount, false, groupId, formattedExpiredDate);
                      _showReturnDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Thêm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Xử lý khi chuyển đổi tab
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  void _showReturnDialog() {
    TextEditingController unitNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thêm thực phẩm thành công"),
          content: Text("Quay lại trang Tủ lạnh"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Quay lại"),
            ),
          ],
        );
      },
    );
  }
}
