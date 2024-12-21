import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../repositories/food_repository.dart';
import '../../repositories/category_repository.dart';
import '../../services/food_service.dart';
import '../../services/category_service.dart';
import '../food/food_list_screen.dart';
import '../food/buy_food_screen.dart';
import '../food/buy_old_food_screen.dart';
import 'package:go_shopping/main.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> with RouteAware {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final FoodRepository _foodRepository = FoodRepository(
    foodService: FoodService(),
  );
  final CategoryRepository _categoryRepository = CategoryRepository(
    categoryService: CategoryService(),
  );

  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  List<dynamic> listcategory = [];
  List<dynamic> listitem = [];
  List<dynamic> listUnavailablefood = [];
  String keyword = "";
  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoadingMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(
          this,
          ModalRoute.of(context)
              as PageRoute<dynamic>);
    }
    _initializeData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
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
      final categories = await _categoryRepository.getCategories(groupId!);
      setState(() {
        listcategory = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchUnavailable() async {
    try {
      final unavailableFoods = await _foodRepository.getUnavailableFoods(groupId!);
      setState(() {
        listUnavailablefood = unavailableFoods;
      });
    } catch (e) {
      print('Error fetching unavailable foods: $e');
    }
  }

  Future<void> _createCategory(String categoryName) async {
    try {
      await _categoryRepository.createCategory(
        categoryName: categoryName,
        groupId: groupId!,
      );
      _fetchCategories();
    } catch (e) {
      print('Error creating category: $e');
    }
  }

  Future<void> _getItem({bool append = false}) async {
    try {
      final items = await _foodRepository.getItemsWithPagination(
        groupId: groupId!,
        keyword: keyword,
        page: currentPage,
        limit: 3,
      );
      setState(() {
        if (append) {
          listitem.addAll(items);
        } else {
          listitem = items;
        }
      });
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    _fetchCategories();
    _getItem();
    _fetchUnavailable();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        setState(() => isLoadingMore = true);
        currentPage++;
        _getItem(append: true)
            .then((_) => setState(() => isLoadingMore = false));
      }
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
      body: RefreshIndicator(
        onRefresh: () async {
          currentPage = 1;
          await _initializeData();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onChanged: (value) {
                    setState(() {
                      keyword = value;
                      _getItem();
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryItem(icon: Icons.add, label: "Thẻ mới"),
                    if (listcategory.isEmpty) 
                      CircularProgressIndicator()
                    else
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

              Text(
                "Gợi ý nguyên liệu cần mua",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: listUnavailablefood.isEmpty ? 40 : 150,
                child: listUnavailablefood.isEmpty
                    ? Text("Không có gợi ý nào cần mua")
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: listUnavailablefood.map((food) {
                          return _buildSuggestionCard(
                            food["name"],
                            food["unitName"],
                            food["image"],
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Danh sách nguyên liệu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
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
                itemCount: listitem.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == listitem.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final item = listitem[index];
                  return _buildIngredientItem(
                    item['foodName'],
                    item['amount'].toString(),
                    item['unitName'],
                    item['expireDate'].split('T')[0],
                    item['note'] ?? "Không có ghi chú",
                    item["image"],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyFoodScreen(categoryName: ""),
            ),
          );
        },
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
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

  Widget _buildCategoryItem({IconData? icon, String? imagePath, required String label}) {
    return GestureDetector(
      onTap: () {
        if (label != "Thẻ mới") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodListScreen(categoryName: label),
            ),
          );
        } else {
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

  Widget _buildSuggestionCard(String name, String unitName, String image) {
    Uint8List imageBytes = base64Decode(image);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyOldFoodScreen(
              foodName: name,
              unitName: unitName,
              amount: null,
              startDate: null,
              endDate: null,
              memberName: null,
              memberEmail: null,
              note: "",
              id: null,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
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
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                    child: image != ""
                        ? Image.memory(
                            imageBytes,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "images/fish.png",
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
                    onPressed: () {},
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
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
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

  Widget _buildIngredientItem(String foodName, String amount, String unitName,
      String expireDate, String note, String image) {
    Uint8List imageBytes = base64Decode(image);
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
            child: image != ""
                ? Image.memory(
                    imageBytes,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  )
                : Image.asset(
                    "images/fish.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "$amount $unitName",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "Note: $note",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "Ngày hết hạn: $expireDate",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
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
                _createCategory(categoryNameController.text);
                Navigator.of(context).pop();
              },
              child: Text("Tạo mới"),
            ),
          ],
        );
      },
    );
  }
}
