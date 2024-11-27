import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'food_list.dart';

class UpdateFood extends StatefulWidget {
  final String name;
  final String categoryName;
  final String unitName;
  UpdateFood({required this.name, required this.categoryName, required this.unitName});

  @override
  _UpdateFoodState createState() => _UpdateFoodState();
}

class _UpdateFoodState extends State<UpdateFood> {
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  String URL = dotenv.env['ROOT_URL']!;
  List<dynamic> listcategory = [];
  List<dynamic> listunit = [];
  String selectedUnit = '';
  String chosenCategory = "";
  String oldname = "";
  String foodName = "";
  ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
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

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$URL/category/admin/category/$groupId'));
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 707) {
        setState(() {
          listcategory = responseData['data'];
          print(listcategory.length);
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchUnits() async {
    try {
      final response =
          await http.get(Uri.parse('$URL/unit/admin/unit/$groupId'));
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 700) {
        setState(() {
          listunit = responseData['data'];
          print(listunit.length);
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _addnewUnit(unitName, groupId) async {
    try {
      Map<String, String> body = {
        'unitName': unitName,
        'groupId': groupId,
      };
      final response = await http.post(
        Uri.parse(URL + "/unit/admin/unit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if (responseData["code"] == 700) {
        _fetchUnits();
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _updateFood() async {
    final String apiUrl = URL + "/food/updateFood";

    try {
      // Tạo body dữ liệu
      Map<String, dynamic> newData = {
        "name": foodName,
        "categoryName": chosenCategory,
        "unitName": selectedUnit,
        "image": ""

      };
      Map<String, dynamic> requestBody = {
        "foodName": this.oldname,
        "group": this.groupId,
        "newData": newData
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        if (responseData["code"] == 600) {
          print("Thực phẩm đã được thêm thành công: ${responseData["data"]}");
        } else if (responseData["code"] == 602) {
          print("Thực phẩm đã tồn tại.");
        }
      } else {
        print(
            "Lỗi từ server: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _postData() async {
    await _updateFood();
  }
  late TextEditingController _controller;
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _initializeData();
  }

  Future<void> _initializeData() async {

    await _loadSecureValues();
    await _fetchCategories();
    await _fetchUnits();
    setState(() {
      chosenCategory = widget.categoryName;
      foodName = widget.name;
      oldname = widget.name;
      selectedUnit = widget.unitName;
    });
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
                    image: AssetImage('images/fish.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Tên thực phẩm",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Tên thực phẩm",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    foodName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                "Loại thực phẩm",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (listcategory.isEmpty) CircularProgressIndicator(),
                  ...listcategory.map((category) {
                    return _buildChip(category["name"]!);
                  }).toList(),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Đơn vị",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedUnit,
                  items: [
                    DropdownMenuItem<String>(
                      value: "",
                      child: Text(""),
                    ),
                    ...listunit.map<DropdownMenuItem<String>>((dynamic unit) {
                      return DropdownMenuItem<String>(
                        value: unit["name"], // Sử dụng trường "name" làm giá trị
                        child: Text(unit["name"]),
                      );
                    }).toList(),
                    DropdownMenuItem<String>(
                      value: 'Tạo mới', // Giá trị cho tùy chọn "Tạo mới"
                      child: Text('Tạo mới'),
                    ),
                  ],
                  onChanged: (newValue) {
                    if (newValue == 'Tạo mới') {
                      _showCreateUnitDialog();
                    } else {
                      setState(() {
                        selectedUnit = newValue!;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 180),

              ValueListenableBuilder<bool>(
                valueListenable: isFoodName,
                builder: (context, isVisible, child) {
                  return Visibility(
                    visible:
                        isVisible, // Dựa vào giá trị của isErrorVisible để hiển thị
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
                    if (foodName == "" ||
                        chosenCategory == "" ||
                        selectedUnit == "") {
                      isFoodName.value = true;
                    } else {
                      String categoryName = chosenCategory;
                      _postData();
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
                    "Cập nhật",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
    final isSelected = label == chosenCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          chosenCategory = label;
        });
      },
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSelected ? Colors.grey[400] : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  void _showCreateUnitDialog() {
    TextEditingController unitNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tạo đại lượng mới"),
          content: TextField(
            controller: unitNameController,
            decoration: InputDecoration(
              hintText: "Tên đại lượng mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                _addnewUnit(unitNameController.text, groupId);
                Navigator.of(context).pop();
              },
              child: Text("Tạo mới"),
            ),
          ],
        );
      },
    );
  }

  void _showReturnDialog() {
    TextEditingController unitNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thêm thực phẩm thành công."),
          content: Text("Bạn có muốn tiếp tục?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tiếp tục"),
            ),
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
