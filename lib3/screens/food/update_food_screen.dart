import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/food_repository.dart';
import '../../services/food_service.dart';

class UpdateFoodScreen extends StatefulWidget {
  final String name;
  final String categoryName;
  final String unitName;

  UpdateFoodScreen({
    required this.name,
    required this.categoryName,
    required this.unitName,
  });

  @override
  _UpdateFoodScreenState createState() => _UpdateFoodScreenState();
}

class _UpdateFoodScreenState extends State<UpdateFoodScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final FoodRepository _foodRepository;
  final ImagePicker _picker = ImagePicker();
  
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  List<dynamic> listcategory = [];
  List<dynamic> listunit = [];
  String selectedUnit = '';
  String chosenCategory = "";
  String oldname = "";
  String foodName = "";
  File? _selectedImage;
  String _imageBase64 = "";
  ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  late TextEditingController _controller;

  _UpdateFoodScreenState() : _foodRepository = FoodRepository(
    foodService: FoodService(),
    storage: FlutterSecureStorage(),
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _initializeData();
  }

  Future<void> _loadSecureValues() async {
    try {
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
      final categories = await _foodRepository.getCategories(groupId!);
      setState(() {
        listcategory = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchUnits() async {
    try {
      final units = await _foodRepository.getUnits(groupId!);
      setState(() {
        listunit = units;
      });
    } catch (e) {
      print('Error fetching units: $e');
    }
  }

  Future<void> _fetchFoodImage() async {
    try {
      final imageBase64 = await _foodRepository.getFoodImage(
        groupId: groupId!,
        foodName: widget.name,
      );
      setState(() {
        _imageBase64 = imageBase64;
      });
    } catch (e) {
      print('Error fetching food image: $e');
    }
  }

  Future<void> _createUnit(String unitName) async {
    try {
      await _foodRepository.createUnit(
        unitName: unitName,
        groupId: groupId!,
      );
      _fetchUnits();
    } catch (e) {
      print('Error creating unit: $e');
    }
  }

  Future<void> _updateFood() async {
    try {
      Map<String, dynamic> newData = {
        'name': foodName,
        'categoryName': chosenCategory,
        'unitName': selectedUnit,
        'image': _imageBase64,
      };

      await _foodRepository.updateFoodByName(
        oldName: oldname,
        groupId: groupId!,
        newData: newData,
      );
    } catch (e) {
      print('Error updating food: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageBase64 = base64Encode(File(image.path).readAsBytesSync());
      });
    }
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchUnits();
    await _fetchCategories();
    await _fetchFoodImage();
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : _imageBase64.isEmpty 
                              ? AssetImage('images/fish.png') as ImageProvider
                              : MemoryImage(base64Decode(_imageBase64)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _selectedImage == null && _imageBase64.isEmpty
                      ? Center(child: Icon(Icons.add_a_photo, color: Colors.grey))
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Tên thực phẩm",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
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
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (listcategory.isEmpty) 
                    CircularProgressIndicator()
                  else
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
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                        value: unit["name"],
                        child: Text(unit["name"]),
                      );
                    }).toList(),
                    DropdownMenuItem<String>(
                      value: 'Tạo mới',
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
                    visible: isVisible,
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
                    if (foodName.isEmpty || chosenCategory.isEmpty || selectedUnit.isEmpty) {
                      isFoodName.value = true;
                    } else {
                      _updateFood();
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
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
                _createUnit(unitNameController.text);
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
