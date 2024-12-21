import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../repositories/food_repository.dart';
import '../../repositories/list_task_repository.dart';
import '../../services/food_service.dart';
import '../../services/list_task_service.dart';

class BuyFoodScreen extends StatefulWidget {
  final String categoryName;
  
  const BuyFoodScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  _BuyFoodScreenState createState() => _BuyFoodScreenState();
}

class _BuyFoodScreenState extends State<BuyFoodScreen> {
  final FoodRepository _foodRepository = FoodRepository(
    foodService: FoodService(),
  );
  final ListTaskRepository _taskRepository = ListTaskRepository(
    taskService: ListTaskService(),
  );
  final ImagePicker _picker = ImagePicker();

  String chosenCategory = "";
  String selectedUnit = '';
  int selectedUser = -1;
  String foodName = "";
  int? amount;
  String note = "";
  File? _selectedImage;
  String _imageBase64 = "";
  List<dynamic> listCategories = [];
  List<dynamic> listUnits = [];
  List<dynamic> listUsers = [];
  
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));

  final ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRight = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    chosenCategory = widget.categoryName;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch initial data
      // Note: These would typically come from their respective repositories
      // For now we'll use the existing data structure
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageBase64 = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final currentGroup = groupProvider.groups.first;
    
    try {
      // Create food using repository
      await _foodRepository.createFood(
        name: foodName,
        categoryName: chosenCategory,
        unitName: selectedUnit,
        image: _imageBase64,
        groupId: currentGroup.id,
      );

      // Create task using repository
      await _taskRepository.createListTask(
        memberName: listUsers[selectedUser]['name'],
        memberEmail: listUsers[selectedUser]['email'],
        note: note,
        startDate: startDate,
        endDate: endDate,
        foodName: foodName,
        amount: amount!,
        unitName: selectedUnit,
        groupId: currentGroup.id,
      );

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _validateForm() {
    if (foodName.isEmpty ||
        chosenCategory.isEmpty ||
        selectedUser == -1 ||
        amount == null ||
        selectedUnit.isEmpty ||
        startDate.isBefore(DateTime.now()) ||
        endDate.isBefore(DateTime.now())) {
      isFoodName.value = true;
      return false;
    }
    return true;
  }

  Future<void> _createNewUnit(String unitName, String groupId) async {
    try {
      await _foodRepository.createUnit(
        unitName: unitName,
        groupId: groupId,
      );
      // Refresh units list
      // This would typically come from a repository
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating unit: $e')),
      );
    }
  }

  void _showCreateUnitDialog() {
    final TextEditingController unitNameController = TextEditingController();
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo đại lượng mới"),
        content: TextField(
          controller: unitNameController,
          decoration: const InputDecoration(
            hintText: "Tên đại lượng mới",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              _createNewUnit(unitNameController.text, groupProvider.groups.first.id);
              Navigator.pop(context);
            },
            child: const Text("Tạo mới"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm thực phẩm thành công"),
        content: const Text("Bạn có muốn tiếp tục?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tiếp tục"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Quay lại"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(Icons.add_a_photo, color: Colors.grey),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Food Name Input
            TextField(
              decoration: InputDecoration(
                labelText: "Tên thực phẩm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => foodName = value),
            ),
            const SizedBox(height: 16),

            // Categories
            Text(
              "Loại thực phẩm",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: listCategories.map((category) {
                return ChoiceChip(
                  label: Text(category['name']),
                  selected: category['name'] == chosenCategory,
                  onSelected: (selected) {
                    setState(() => chosenCategory = category['name']);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Amount and Unit Selection
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
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() => amount = int.tryParse(value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedUnit.isEmpty ? null : selectedUnit,
                  hint: const Text("Đơn vị"),
                  items: [
                    ...listUnits.map((unit) => DropdownMenuItem(
                          value: unit['name'],
                          child: Text(unit['name']),
                        )),
                    const DropdownMenuItem(
                      value: 'Tạo mới',
                      child: Text('Tạo mới'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == 'Tạo mới') {
                      _showCreateUnitDialog();
                    } else {
                      setState(() => selectedUnit = value!);
                    }
                  },
                ),
              ],
            ),

            // Date Selection
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => startDate = date);
                      }
                    },
                    child: Text(
                      "Bắt đầu: ${startDate.day}/${startDate.month}/${startDate.year}",
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => endDate = date);
                      }
                    },
                    child: Text(
                      "Kết thúc: ${endDate.day}/${endDate.month}/${endDate.year}",
                    ),
                  ),
                ),
              ],
            ),

            // Note Input
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Ghi chú",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => note = value),
            ),

            // Error Messages
            ValueListenableBuilder(
              valueListenable: isFoodName,
              builder: (context, bool value, _) {
                return Visibility(
                  visible: value,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Bạn chưa nhập đầy đủ thông tin về thực phẩm",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                );
              },
            ),

            // Submit Button
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Thêm",
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
    );
  }
}
