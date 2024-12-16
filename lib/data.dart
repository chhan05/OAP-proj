import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final String description;
  final String image;
  final String priceStart;
  final String priceCur;
  final String remainTime;
  final String username;

  Product({required this.id, required this.name, required this.description, required this.image, required this.priceStart, required this.priceCur, required this.remainTime, required this.username,});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      priceStart: json['priceStart'],
      priceCur: json['priceCur'],
      remainTime: json['remainTime'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'priceStart': priceStart,
      'priceCur': priceCur,
      'remainTime': remainTime,
      'username': username,
    };
  }
}

Future<Product> fetchRandomProduct() async {
  final response = await http.get(Uri.parse('http://192.168.15.167:3000/random-product'));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Product.fromJson(json);
  } else {
    throw Exception('Failed to load random product');
  }
}

Future<void> createProduct(Product product) async {
  const String url = 'http://192.168.15.167:3000/random-product';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) { // 에러 감지
      print('Product added successfully: ${response.body}');
    } else {
      print('Failed to add product: ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

