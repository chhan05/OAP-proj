// main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'shorts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product { // 상품 인수
  final int id;
  final String name;
  final String description;
  final String image;
  final String priceStart;
  final String priceCur;
  final String remainTime;
  final String username;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.priceStart,
    required this.priceCur,
    required this.remainTime,
    this.username = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      priceStart: json['priceStart'],
      priceCur: json['priceCur'],
      remainTime: json['remainTime'],
      username: json['username'] ?? '',
    );
  }
}

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Color(4282474385)), // 밝은 테마 적용 적용
      themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 변경
      initialRoute: '/shortsScreen',
      routes: {
        '/': (context) => HomeScreen(),
        '/shortsScreen': (context) => RandomProductScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget { // 로그인 확인 등의 작업 시행
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "OAP Proj",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// 메인 화면 시작
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // 화면 목록 정의
  final List<Widget> _screens = [
    ListScreen(),
    ProgressScreen(),
    CompleteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OAP-Proj'),
        backgroundColor: Colors.blueAccent,
        actions: [SingleChoice()],
        centerTitle: false,
      ),
      body: _screens[_selectedIndex], // 현재 선택된 화면 표시
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index; // 선택된 인덱스 업데이트
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: '구매',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_outlined),
            selectedIcon: Icon(Icons.sync),
            label: '입찰중',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: '완료',
          ),
        ],
      ),
    );
  }
}

Widget _buildButton(BuildContext context, String text, Widget? screen) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.8,
    child: ElevatedButton(
      onPressed: screen != null
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen), // 임시
        );
      }
          : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blueAccent,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 22, color: Colors.white), // 텍스트 색상과 폰트 크기 변경
      ),
    ),
  );
}

// Appbar - 구매/판매 선택 SegmentedButtons
enum Trade { buy, sell }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Trade tradeView = Trade.buy;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Trade>(
      segments: const <ButtonSegment<Trade>>[
        ButtonSegment<Trade>(
            value: Trade.buy,
            label: Text('구매'),
            icon: Icon(Icons.shopping_cart)),
        ButtonSegment<Trade>(
            value: Trade.sell,
            label: Text('판매'),
            icon: Icon(Icons.sell)),
      ],
      selected: <Trade>{tradeView},
      onSelectionChanged: (newSelection) {
        setState(() {
          tradeView = newSelection.first;
          // 화면 이동
          if (tradeView == Trade.sell) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductListScreen()),
            );
          }
        });
      },
    );
  }
}

//Appbar 아래 - 목록/입찰중/완료 선택 Badge
class ListScreen extends StatelessWidget {
  var items = new List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchBar(
              leading: Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.keyboard_voice),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
              ],
            )
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                items = [['item1','264', '5000'], ['item2','94','4000'], ['item3','23','6000']]; // 아이템 목록
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      "표시할 항목이 없습니다.",
                      style: TextStyle(fontSize: 20),
                    )
                  );
                }
                else {
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic cardInfo = items[index];
                      String cardName = cardInfo[0];
                      String remainTime = cardInfo[1];
                      String goodsPrice = cardInfo[2];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.all(Radius.elliptical(20, 20))),
                        child: ListTile(
                          title: Text(cardName),
                          subtitle: Text("$remainTime초 남음"),
                          trailing: Text("$goodsPrice원~"),
                        ),
                      );
                    }
                  );
                }
              }
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => RandomProductScreen()),);},
        child: Icon(Icons.add)
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  var progressItems = new List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchBar(
              leading: Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.keyboard_voice),
                  onPressed: () {
                    print('Use voice command'); // 수정 필요
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    print('Use image search'); // 수정 필요
                  },
                ),
              ],
            )
          ),
          Expanded(
              child: Builder(
                builder: (context) {
                  progressItems = [['안동댁사과 경북 안동사과 부사 5kg','126', '39100']]; // 아이템 목록(임시)
                  if (progressItems.isEmpty) {
                    return Center(
                      child: Text(
                        "표시할 항목이 없습니다.",
                        style: TextStyle(fontSize: 20),
                      )
                    );
                  }
                  else {
                    return ListView.builder(
                        itemCount: progressItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          dynamic cardInfo = progressItems[index];
                          String cardName = cardInfo[0];
                          String remainTime = cardInfo[1];
                          String goodsPrice = cardInfo[2];

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.elliptical(20, 20))),
                            child: ListTile(
                              title: Text(cardName),
                              subtitle: Text("$remainTime초 남음"),
                              trailing: Text("$goodsPrice원 입찰"),
                            ),
                          );
                        }
                    );
                  }
                }
              )
          )
        ],
      ),
    );
  }
}

class CompleteScreen extends StatelessWidget {
  var completeItems = new List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchBar(
              leading: Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.keyboard_voice),
                  onPressed: () {
                    print('Use voice command'); // 수정 필요
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    print('Use image search'); // 수정 필요
                  },
                ),
              ],
            )
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                completeItems = [['item7', '6000'], ['item8','5000'], ['item9','12000']]; // 아이템 목록
                if (completeItems.isEmpty) {
                  return Center(
                    child: Text(
                      "표시할 항목이 없습니다.",
                      style: TextStyle(fontSize: 20),
                    )
                  );
                }
                else {
                  return ListView.builder(
                    itemCount: completeItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic cardInfo = completeItems[index];
                      String cardName = cardInfo[0];
                      String goodsPrice = cardInfo[1];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.elliptical(20, 20))),
                        child: ListTile(
                          title: Text(cardName),
                          trailing: Text("$goodsPrice원에 거래됨"),
                        ),
                      );
                    }
                  );
                }
              }
            )
          )
        ],
      ),
    );
  }
}

// 기본 판매 화면
class SellScreen extends StatelessWidget {
  var sellingItems = new List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매'),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: SearchBar(
                leading: Icon(Icons.search),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_voice),
                    onPressed: () {
                      print('Use voice command'); // 수정 필요
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      print('Use image search'); // 수정 필요
                    },
                  ),
                ],
              )
          ),
          Expanded(
              child: Builder(
                  builder: (context) {
                    sellingItems = [['item10', '3000', '8'], ['item11','7000','7'], ['item12','8000','10']]; // 아이템 목록(임시)
                    if (sellingItems.isEmpty) {
                      return Center(
                          child: Text(
                            "표시할 항목이 없습니다.",
                            style: TextStyle(fontSize: 20),
                          )
                      );
                    }
                    else {
                      return ListView.builder(
                        itemCount: sellingItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          dynamic cardInfo = sellingItems[index];
                          String cardName = cardInfo[0];
                          String goodsPrice = cardInfo[1];
                          String remained = cardInfo[2];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.elliptical(20, 20))),
                            child: ListTile(
                              title: Text(cardName),
                              trailing: Text("최근 $goodsPrice원에 거래됨, $remained개 남음"),
                            ),
                          );
                        }
                      );
                    }
                  }
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => sellingItems.add('itemNew'), tooltip: "아이템 추가", child: Icon(Icons.add)),
    );
  }
}

// 상품 목록 화면
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    const String url = 'http://192.168.15.167:3000/products'; // Node.js 서버 주소

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> productList = jsonDecode(response.body);
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매'),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.name),
                  subtitle: Text('현재 가격: ${product.priceCur}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return ProductRegistScreen();
                },
            ));
          }, tooltip: "상품 등록하기", child: Icon(Icons.add)),
    );
  }
}

// 경매 입찰 화면
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 정보'),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.image, height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('시작가: ${product.priceStart}원', style: TextStyle(fontSize: 16)),
            Text('현재가: ${product.priceCur}원', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(product.description),
            SizedBox(height: 16),
            Text('남은 시간: ${product.remainTime} 초'),
          ],
        ),
      ),
    );
  }
}

class ProductRegistScreen extends StatefulWidget {
  @override
  _ProductRegistScreenState createState() => _ProductRegistScreenState();
}

class _ProductRegistScreenState extends State<ProductRegistScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _priceStartController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      final String url = 'http://192.168.15.167:3000/posts'; // Node.js 서버 주소
      final Map<String, dynamic> newProduct = {
        'name': _nameController.text,
        'image': _imageController.text,
        'priceStart': _priceStartController.text,
        'priceCur': _priceStartController.text, // 시작 가격과 현재 가격은 동일하게 설정
        'description': _descriptionController.text,
        'remainTime': '300', // 기본값 설정 (필요시 수정)
        'username': '', // 기본값 설정
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newProduct),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상품이 성공적으로 등록되었습니다!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상품 등록에 실패하였습니다: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러 발생: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '상품명'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '상품명 입력 필수';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: '이미지 URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이미지 URL 입력 필수';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceStartController,
                decoration: InputDecoration(labelText: '시작가'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '시작가 입력 필수';
                  }
                  if (double.tryParse(value) == null) {
                    return '시작가 입력 필수';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: '세부 설명'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '세부 설명 입력 필수';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitProduct,
                child: Text('상품 등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}