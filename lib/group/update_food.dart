import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'food_list.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import "package:go_shopping/main.dart";

class UpdateFood extends StatefulWidget {
  final String name;
  final String categoryName;
  final String unitName;
  UpdateFood({required this.name, required this.categoryName, required this.unitName});

  @override
  _UpdateFoodState createState() => _UpdateFoodState();
}

class _UpdateFoodState extends State<UpdateFood> with RouteAware{
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
  File? _selectedImage;
  String _imageBase64 = "";
  final ImagePicker _picker = ImagePicker();
  int isDidChange = 0;
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
      await http.get(Uri.parse('$URL/unit/admin/unit/$groupId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
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

  Future<void> _fetchFoodImage() async {
    try {
      Map<String, String> body = {
        'groupId': groupId!,
        'foodName': widget.name,
      };
      final response = await http.post(
        Uri.parse(URL + "/food/getFoodImageByName"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if (responseData["code"] == 700) {
        setState(() {
          _imageBase64 = responseData["data"];
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
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    print("Nận hàm");
    final String apiUrl = URL + "/food/updateFood";

    try {
      // Tạo body dữ liệu
      Map<String, dynamic> newData = {
        "name": foodName,
        "categoryName": chosenCategory,
        "unitName": selectedUnit,
        "image": _imageBase64

      };
      Map<String, dynamic> requestBody = {
        "foodName": this.oldname,
        "group": this.groupId,
        "newData": newData
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      print("Gọi api");
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

  Future<void> _postData() async {
    await _updateFood();
  }
  late TextEditingController _controller;

  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(
          this,
          ModalRoute.of(context)
          as PageRoute<dynamic>); // Subscribe to route observer
    }
    if(isDidChange == 0){
      setState(() {
        chosenCategory = widget.categoryName;
        foodName = widget.name;
        oldname = widget.name;
      });
      _controller = TextEditingController(text: widget.name);
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
  // void initState() {
  //   super.initState();
  //   _controller = TextEditingController(text: widget.name);
  //   _initializeData();
  // }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchUnits();
    isDidChange += 1;
    if(isDidChange == 1){
      selectedUnit = widget.unitName;
    }
    _fetchCategories();
    _fetchFoodImage();
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
                          : _imageBase64 == "" ? AssetImage('images/fish.png') as ImageProvider : MemoryImage(base64Decode(_imageBase64!)), // Placeholder
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
                        child: GestureDetector(onLongPress: (){
                          _showDeleteDialog(unit["name"]);
                        }, child: Text(unit["name"])),
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
