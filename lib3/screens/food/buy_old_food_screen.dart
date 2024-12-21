import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../repositories/list_task_repository.dart';
import '../../services/list_task_service.dart';

class BuyOldFoodScreen extends StatefulWidget {
  final String foodName;
  final String unitName;
  final int? amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? memberName;
  final String? memberEmail;
  final String? note;
  final String? id;

  const BuyOldFoodScreen({
    Key? key,
    required this.foodName,
    required this.unitName,
    this.amount,
    this.startDate,
    this.endDate,
    this.memberName,
    this.memberEmail,
    this.note,
    this.id,
  }) : super(key: key);

  @override
  _BuyOldFoodScreenState createState() => _BuyOldFoodScreenState();
}

class _BuyOldFoodScreenState extends State<BuyOldFoodScreen> {
  final ListTaskRepository _taskRepository = ListTaskRepository(
    taskService: ListTaskService(),
  );
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<dynamic> listUsers = [];
  int selectedUser = -1;
  String note = "";
  int? amount;
  File? _selectedImage;
  String _imageBase64 = "";
  DateTime? startDate;
  DateTime? endDate;

  final ValueNotifier<bool> isFoodName = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRight = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      startDate = widget.startDate;
      endDate = widget.endDate;
      note = widget.note ?? "";
      amount = widget.amount;
      _amountController.text = widget.amount?.toString() ?? "";
      _noteController.text = widget.note ?? "";
    });
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      // This should come from a UserRepository
      // For now, we'll keep the existing structure
      setState(() {
        if (widget.memberName != null) {
          for (int i = 0; i < listUsers.length; i++) {
            if (widget.memberName == listUsers[i]["name"]) {
              selectedUser = i;
              break;
            }
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
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
      if (widget.id == null) {
        // Create new task
        await _taskRepository.createListTask(
          memberName: listUsers[selectedUser]['name'],
          memberEmail: listUsers[selectedUser]['email'],
          note: note,
          startDate: startDate!,
          endDate: endDate!,
          foodName: widget.foodName,
          amount: amount!,
          unitName: widget.unitName,
          groupId: currentGroup.id,
        );
      } else {
        // Update existing task
        await _taskRepository.updateListTaskById(
          listTaskId: widget.id!,
          memberName: listUsers[selectedUser]['name'],
          memberEmail: listUsers[selectedUser]['email'],
          note: note,
          startDate: startDate!,
          endDate: endDate!,
          foodName: widget.foodName,
          amount: amount!,
          unitName: widget.unitName,
          groupId: currentGroup.id,
        );
      }

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _validateForm() {
    if (selectedUser == -1 ||
        startDate == null ||
        endDate == null ||
        amount == null) {
      isFoodName.value = true;
      return false;
    }
    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            "${widget.id == null ? 'Thêm' : 'Cập nhật'} thực phẩm thành công"),
        content: const Text("Quay lại trang Tủ lạnh"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
            // Image Picker
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

            // Food Name (Disabled)
            TextField(
              controller: TextEditingController(text: widget.foodName),
              decoration: InputDecoration(
                labelText: "Tên thực phẩm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Amount and Unit
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
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
                  value: widget.unitName,
                  items: [
                    DropdownMenuItem(
                      value: widget.unitName,
                      child: Text(widget.unitName),
                    ),
                  ],
                  onChanged: null,
                ),
                const SizedBox(width: 16),
                // Thay đổi đoạn code này trong BuyOldFoodScreen
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Phân công",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedUser != -1
                        ? listUsers[selectedUser]["name"] as String
                        : null,
                    items:
                        listUsers.map<DropdownMenuItem<String>>((dynamic user) {
                      return DropdownMenuItem<String>(
                        value: user['name'] as String,
                        child: Text(user['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUser = listUsers
                              .indexWhere((user) => user['name'] == value);
                        });
                      }
                    },
                  ),
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
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => startDate = date);
                      }
                    },
                    child: Text(
                      startDate == null
                          ? "Chọn ngày bắt đầu"
                          : "Bắt đầu: ${startDate!.day}/${startDate!.month}/${startDate!.year}",
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => endDate = date);
                      }
                    },
                    child: Text(
                      endDate == null
                          ? "Chọn ngày kết thúc"
                          : "Kết thúc: ${endDate!.day}/${endDate!.month}/${endDate!.year}",
                    ),
                  ),
                ),
              ],
            ),

            // Note
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
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
                child: Text(
                  widget.id == null ? "Thêm" : "Lưu chỉnh sửa",
                  style: const TextStyle(
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
