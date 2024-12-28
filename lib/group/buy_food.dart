import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fridge.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_shopping/main.dart';

class BuyFood extends StatefulWidget {
  final String categoryName;
  BuyFood({required this.categoryName});

  @override
  _BuyFoodState createState() => _BuyFoodState();
}

class _BuyFoodState extends State<BuyFood> with RouteAware{
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  String URL = dotenv.env['ROOT_URL']!;
  List<dynamic> listcategory = [];
  List<dynamic> listuser = [];
  List<dynamic> listunit = [];
  String selectedUnit = '';
  int selectedUser = -1;
  String chosenCategory = "";
  int? amount;
  String foodName = "";
  DateTime? startDate;
  DateTime? endDate;
  String note = "";
  ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  ValueNotifier<bool> isRight = ValueNotifier<bool>(false);
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  File? _selectedImage;
  String _imageBase64 = "";
  final ImagePicker _picker = ImagePicker();
  bool isDidChange = false;
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
      await http.get(Uri.parse('$URL/category/admin/category/$groupId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 707) {
        setState(() {
          listcategory = responseData['data'];
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
      await http.get(Uri.parse('$URL/unit/admin/unit/$groupId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 700) {
        setState(() {
          listunit = responseData['data'];
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response =
      await http.get(Uri.parse('$URL/groups/get-users-by-group-id/$groupId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 700) {
        setState(() {
          listuser = responseData['data'];
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _addnewUnit(unitName, groupId) async{
    try{
      Map<String, String> body = {
        'unitName': unitName,
        'groupId': groupId,
      };
      final response = await http.post(
        Uri.parse(URL + "/unit/admin/unit"),
        headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if(responseData["code"] == 700){
        _fetchUnits();
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
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
          print(1);
          startDate = pickedDate;
        } else {
          print(2);
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _addNewFood(foodName, categoryName, unitName, group, image) async{
    print("Gọi đến hàm");
    final String apiUrl = URL + "/food/createFood";

    try {
      // Tạo body dữ liệu
      Map<String, dynamic> requestBody = {
        "name": foodName,
        "categoryName": categoryName,
        "unitName": unitName,
        "image": image,
        "group": group,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      print("Gọi đến api");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        print("end");
        if (responseData["code"] == 600) {
          print("Thực phẩm đã được thêm thành công: ${responseData["data"]}");
        } else if (responseData["code"] == 602) {
          print("Thực phẩm đã tồn tại.");
        }
      } else {
        print("Lỗi từ server: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _addNewTask(memberName, memberEmail, note, start, end, foodName, amount, unitName, state, group) async{
    final String url = URL + "/listtask/createListTask";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
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

  Future<String> _deleteUnit(String categoryName) async {
    try {
      Map<String, dynamic> body = {
        "name": categoryName,
        'groupId': groupId!,
      };
      final response = await http.delete(
        Uri.parse(URL + "/unit/admin/unit"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      return responseData["code"] == 700 ? "ok" : responseData["data"];
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageBase64 = base64Encode(File(image.path).readAsBytesSync()); // Chuyển ảnh thành base64
      });
    }
  }


  Future<void> _postData(foodName, categoryName, unitName, memberName, memberEmail, note, start, end, amount, state, group, expireDate) async {
    await _addNewFood(foodName, categoryName, unitName, group, _imageBase64);
    await _addNewTask(memberName, memberEmail, note, start, end, foodName, amount, unitName, state, group);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(
          this,
          ModalRoute.of(context)
          as PageRoute<dynamic>); // Subscribe to route observer
    }
    if(isDidChange == false){
      chosenCategory = widget.categoryName;
    }
    _initializeData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe from route observer
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initializeData(); // Re-fetch data when the screen comes back
  }

  Future<void> _initializeData() async {
    isDidChange = true;
    await _loadSecureValues();

    // Sau khi _loadSecureValues hoàn tất, gọi _fetchCategories
    _fetchCategories();
    _fetchUnits();
    _fetchUsers();

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
            Navigator.of(context).pop();
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
              GestureDetector(
                onTap: _pickImage, // Chọn ảnh khi nhấn vào container
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _selectedImage != null
                          ? FileImage(_selectedImage!) // Hiển thị ảnh đã chọn
                          : AssetImage('images/food.png') as ImageProvider, // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _selectedImage == null
                      ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Tên thực phẩm",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Tên thực phẩm",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    foodName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                "Loại thực phẩm",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
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
              Row(
                children: [
                  Expanded(
                    flex: 1,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
                        ]
                    ),
                  ),
                  Text(
                    selectedUnit,
                    style: TextStyle(fontSize: 16), // Cỡ chữ phù hợp
                  ),
                  PopupMenuButton<dynamic>(
                    onSelected: (newValue) {
                      if (newValue == 'Tạo mới') {
                        _showCreateUnitDialog();
                      } else {
                        setState(() {
                          selectedUnit = newValue;
                        });
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        ...listunit.map<PopupMenuEntry<dynamic>>((dynamic unit) {
                          return PopupMenuItem<dynamic>(
                            value: unit["name"],
                            child: GestureDetector(
                              onLongPress: () {
                                _showDeleteDialog(unit["name"]); // Show the delete dialog
                              },
                              child: Text(unit["name"]),
                            ),
                          );
                        }).toList(),
                        PopupMenuItem<dynamic>(
                          value: 'Tạo mới',
                          child: Text('Tạo mới'),
                        ),
                      ];
                    },
                  ),
                  SizedBox(width: 1),
                  Expanded(
                    flex: 3,
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
              SizedBox(height: 16),
              Text(
                "Ghi chú",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 30),

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
              ValueListenableBuilder<bool>(
                valueListenable: isRight,
                builder: (context, isVisible, child) {
                  return Visibility(
                    visible: isVisible, // Dựa vào giá trị của isErrorVisible để hiển thị
                    child: const Text(
                      "Chỉ admin mới có quyền phân công cho người khác, bạn chỉ có quyền phân công cho chính mình!",
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
                    if(foodName == "" ||
                        chosenCategory == "" ||
                        selectedUser == -1 ||
                        amount == null ||
                        selectedUnit == ""
                        || startDate!.isBefore(DateTime.now()) ||
                        endDate!.isBefore(DateTime.now()) || startDate == null || endDate == null
                    )
                    {
                      isFoodName.value = true;
                    }
                    else if(name != adminName && listuser[selectedUser]["name"] != name){
                      print(name);
                      print(adminName);
                      print( listuser[selectedUser]["name"]);
                      isRight.value = true;
                    }
                    else{
                      String categoryName = chosenCategory;
                      String memberName = listuser[selectedUser]["name"];
                      String memberEmail = listuser[selectedUser]["email"];
                      String formattedStartDate = "${startDate!.toLocal()}".split(' ')[0];
                      String formattedEndDate = "${endDate!.toLocal()}".split(' ')[0];
                      String formattedExpiredDate = "${DateTime.now().add(Duration(days: 30))}".split(' ')[0];
                      _postData(foodName, categoryName, selectedUnit, memberName, memberEmail, note, formattedStartDate, formattedEndDate, amount, false, groupId, formattedExpiredDate);
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


    );
  }

  void _showDeleteDialog(String unitName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xóa đơn vị"),
          content: Text("Bạn có muốn xóa đơn vị \"$unitName\" không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Không"),
            ),
            TextButton(
              onPressed: () async {
                // Call your delete function
                String status = await _deleteUnit(unitName);
                Navigator.of(context).pop(); // Close the dialog after action

                if (status == "") {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tồn tại thực phẩm sử dụng đơn vị này!")),
                  );
                } else {
                  // Thực hiện hành động sau khi xóa thành công (nếu cần)
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Xóa đơn vị thành công")),
                  );
                }
              },
              child: Text("Có"),
            ),
          ],
        );
      },
    );
  }


  Widget _buildChip(String label) {
    final isSelected = label == chosenCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          chosenCategory = label;
          print(chosenCategory);
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
