import 'package:flutter/material.dart';
import 'food_list.dart';
import 'buy_food.dart';
import 'buy_old_food.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_shopping/main.dart';

class Fridge extends StatefulWidget {
  const Fridge({super.key});

  @override
  State<Fridge> createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> with RouteAware{
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  String URL = dotenv.env['ROOT_URL']!;
  List<dynamic> listcategory = [];
  List<dynamic> listitem = [];
  List<dynamic> listUnavailablefood = [];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
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

  Future<void> _fetchCategories() async{
    try{
      print(groupId);
      final response = await http.get(
        Uri.parse('$URL/category/admin/category/$groupId')
      );
      final responseData = jsonDecode(response.body);
      if(responseData['code'] == 707){
        setState(() {
          listcategory = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _fetchUnavailable() async{
    try{
      print(groupId);
      final response = await http.get(
          Uri.parse('$URL/food/getUnavailableFoods/$groupId')
      );
      final responseData = jsonDecode(response.body);
      if(responseData['code'] == 600){
        setState(() {
          listUnavailablefood = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _addNewCategory(categoryName, groupId) async{
    try{
      Map<String, String> body = {
        'categoryName': categoryName,
        'groupId': groupId,
      };
      final response = await http.post(
        Uri.parse(URL + "/category/admin/category"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if(responseData["code"] == 700){
        _fetchCategories();
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _searchItem(keyword) async{
    try{
      Map<String, String> body = {
        'groupId': groupId!,
        'keyword': keyword
      };
      final response = await http.post(
        Uri.parse(URL + "/groups/searchItemsInRefrigerator"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if(responseData["code"] == 700){
        setState(() {
          listitem = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  Future<void> _fetchItem() async{
    try{
      final response = await http.get(
          Uri.parse('$URL/groups/getAvailableItems/$groupId')
      );
      final responseData = jsonDecode(response.body);
      if(responseData['code'] == 700){
        setState(() {
          listitem = responseData['data'];
        });
      }else{
        print("${responseData["message"]}");
      }
    }catch(e){
      print("Error: $e");
    }
  }

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
    routeObserver.unsubscribe(this); // Unsubscribe from route observer
    super.dispose();
  }
  @override
  void didPopNext() {
    super.didPopNext();
    _initializeData(); // Re-fetch data when the screen comes back
  }

  Future<void> _initializeData() async {
    // Đợi _loadSecureValues hoàn tất
    await _loadSecureValues();

    // Sau khi _loadSecureValues hoàn tất, gọi _fetchCategories
    await _fetchCategories();
    await _fetchItem();
    await _fetchUnavailable();
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
            },
          ),
          title: Text(
            "Tủ lạnh",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Nguyên liệu, thành phần",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value){
                    _searchItem(value);
                  },
                ),
              ),
              SizedBox(height: 16),

              // Danh sách danh mục nguyên liệu (cuộn ngang)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryItem(icon: Icons.add, label: "Thẻ mới"),
                    if (listcategory.isEmpty)
                      CircularProgressIndicator(),
                    ...listcategory.map((category) {
                      return _buildCategoryItem(
                        imagePath: "images/fish.png",
                        label: category["name"],
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Gợi ý nguyên liệu cần mua (cuộn ngang)
              Text(
                "Gợi ý nguyên liệu cần mua",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: listUnavailablefood.length == 0 ? 40 : 150,
                child: listUnavailablefood.length == 0 ? Text("Không có gợi ý nào cần mua") : ListView(
                  scrollDirection: Axis.horizontal,
                  children: listUnavailablefood.map((food) {
                    return _buildSuggestionCard(food["name"], food["unitName"], "images/fish.png");
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),

              // Danh sách nguyên liệu (cuộn dọc)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Danh sách nguyên liệu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Xử lý khi bấm "Chỉnh sửa"
                    },
                    child: Text(
                      "Chỉnh sửa",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listitem.length, // Số lượng phần tử trong listitem
                itemBuilder: (context, index) {
                  final item = listitem[index]; // Lấy từng phần tử của listitem
                  return _buildIngredientItem(
                      item['foodName'], // Tên thực phẩm
                      item['amount'].toString(), // Số lượng, chuyển sang String nếu cần
                      item['unitName'], // Đơn vị
                      item['expireDate'].split('T')[0], // Ngày hết hạn (loại bỏ phần giờ)
                      item['note'] ?? "Không có ghi chú", // Ghi chú, nếu null thì thay thế
                      "images/fish.png" // Đường dẫn ảnh (tạm thời dùng ảnh mặc định)
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyFood(categoryName: ""),
              ),
            );
          },
          backgroundColor: Colors.green[700],
          child: Icon(Icons.add, color: Colors.white),
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
  void _showCreateCategoryDialog() {
    TextEditingController categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tạo loại thực phẩm mới"),
          content: TextField(
            controller: categoryNameController,
            decoration: InputDecoration(
              hintText: "Tên loại thực phẩm mới",
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
                _addNewCategory(categoryNameController.text, groupId);
                Navigator.of(context).pop();
              },
              child: Text("Tạo mới"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(
      {IconData? icon, String? imagePath, required String label}) {
    return GestureDetector(
      onTap: () {
        if(label != "Thẻ mới"){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodListScreen(categoryName: label),
            ),
          );
        }
        else{
          _showCreateCategoryDialog();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon != null
                  ? Icon(icon, color: Colors.grey, size: 30)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(imagePath!, fit: BoxFit.cover),
                    ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String name, String unitName, String imagePath) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyOldFood(name: name, unitName: unitName),
          ),
        );
      },
      child: Container(
        width: 140, // Chiều rộng cố định cho mỗi thẻ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[300]!), // Viền nhẹ
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh với nút "Mua thêm" nổi lên trên
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2), // Màu mờ phủ lên hình ảnh
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12.5,
                  left: 28,
                  child: ElevatedButton(
                    onPressed: () {
                      // Hành động khi bấm "Mua thêm"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: Text(
                      "Mua thêm",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món hàng
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Số lượng
                  Row(
                    children: [
                      Icon(Icons.shopping_basket, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "0 $unitName",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      Spacer(),
                      Icon(Icons.group, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String foodName, String amount, String unitName, String expireDate, String note, String imagePath) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(foodName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(amount + " " + unitName,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text("Note: " + note,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text("Ngày hết hạn: " + expireDate,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: Colors.black),
    );
  }

  void _showAddIngredientPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Thêm thực phẩm mới",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700]),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Tên thực phẩm
            TextField(
              decoration: InputDecoration(
                labelText: "Tên thực phẩm",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Loại thực phẩm
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
                _buildChip("Ngũ cốc"),
                _buildChip("Gia vị"),
                _buildChip("Thịt"),
                _buildChip("Trứng, Sữa"),
                _buildChip("Rau"),
                _buildChip("Củ quả"),
                _buildChip("Hoa quả"),
              ],
            ),
            SizedBox(height: 16),

            // Số lượng
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Số lượng",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Kg',
                  items: <String>['Kg', 'L', 'Gram'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    // Xử lý khi thay đổi đơn vị
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
