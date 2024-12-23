import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'buy_old_food.dart';
import 'package:go_shopping/main.dart'; // Import main.dart để sử dụng routeObserver
import 'buy_food.dart';
import 'update_food.dart';

class FoodListScreen extends StatefulWidget {
  final String categoryName;

  FoodListScreen({required this.categoryName});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> with RouteAware {
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  String keyword = "";
  String URL = dotenv.env['ROOT_URL']!;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> listfood = [];
  List<dynamic> listfoodbackup = [];
  bool isFirstTime = false;

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

  Future<void> _fetchFood() async {
    try {
      Map<String, String> body = {
        'groupId': groupId!,
        'categoryName': widget.categoryName,
      };
      final response = await http.post(
        Uri.parse(URL + "/food/getFoodsByCategory"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseData = jsonDecode(response.body);
      if (responseData["code"] == 600) {
        setState(() {
          listfood = responseData["data"];
          listfoodbackup = responseData["data"];
        });
      } else {
        print("${responseData["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchFood();
    isFirstTime = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>); // Subscribe to route observer
    }
    if(isFirstTime == false){
      _initializeData();
    }

  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initializeData(); // Re-fetch data when the screen comes back
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe from route observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nguyên liệu, thành phần',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                    listfood = listfoodbackup
                        .where((item) =>
                        item['name'].toLowerCase().contains(keyword.toLowerCase()))
                        .toList();
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Danh sách nguyên liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: listfood.map((food) {
                    return FoodCard(
                      userName: name!,
                      adminName: adminName!,
                      imagePath: food["image"],
                      name: food['name'],
                      amount: food['totalAmount'].toString(),
                      unitName: food['unitName'],
                      categoryName: widget.categoryName,
                      image: food["image"],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[700],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuyFood(categoryName: widget.categoryName),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      );
  }
}
class FoodCard extends StatefulWidget {
  final String userName;
  final String adminName;
  final String imagePath;
  final String name;
  final String amount;
  final String unitName;
  final String categoryName;
  final String image;

  const FoodCard({
    required this.userName,
    required this.adminName,
    required this.imagePath,
    required this.name,
    required this.amount,
    required this.unitName,
    required this.categoryName,
    required this.image,
    super.key,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool isDropdownOpen = false;


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
          widget.imagePath != "" ? Image.memory(base64Decode(widget.imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,) :
          Image.asset(
            "images/fish.png",
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        subtitle: Text(widget.amount + " " + widget.unitName),
        trailing: DropdownButton<String>(
          underline: SizedBox(),
          icon: Icon(Icons.more_vert, color: Colors.green[700]),
          items: widget.userName == widget.adminName ? [
            DropdownMenuItem(value: 'Chỉnh sửa', child: Text('Chỉnh sửa')),
            DropdownMenuItem(value: 'Phân công', child: Text('Phân công')),
          ] : [
            DropdownMenuItem(value: 'Phân công', child: Text('Phân công')),
          ],
          onChanged: (value) {
            setState(() {
              isDropdownOpen = true;
            });
            if (value == 'Chỉnh sửa') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdateFood(name: widget.name, categoryName: widget.categoryName, unitName: widget.unitName,),
                ),
              );
            } else if (value == 'Phân công') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BuyOldFood(foodName: widget.name, unitName: widget.unitName, amount: null, startDate: null, endDate: null, memberName: null, memberEmail: null, note: "", id: null, image: widget.image),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
