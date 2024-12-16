import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';

class RandomProductScreen extends StatefulWidget {

  @override
  _RandomProductScreenState createState() => _RandomProductScreenState();
}

class _RandomProductScreenState extends State<RandomProductScreen> {
  double _sliderValue = 0.05; // 슬라이더 초기값 (5%)

  int _calculateBid(int _basePrice) {
    return _basePrice + (_basePrice * _sliderValue).toInt();
  }

  late Future<Product> _randomProduct;

  @override
  void initState() {
    super.initState();
    _randomProduct = fetchRandomProduct(); // 랜덤 상품 가져오기
  }
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width; // 화면의 가로 크기

    return Scaffold(
      appBar: AppBar(title: Text('탐색')),
      body: FutureBuilder<Product>(
        future: _randomProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!; // product 정보 불러오기
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 상단 + 버튼
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    // 상품 이미지
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      height: 400,
                      child: Image.network(
                        product.image, // image 정보
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 상품명 텍스트
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // 입찰가 및 남은 시간
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '최고 입찰가 : ${product.priceCur}',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                        Text(
                          '남은 시간 : ${product.remainTime}',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 16,),
                    // 슬라이더와 입찰 금액
                    Text(
                      '+${_calculateBid(int.parse(product.priceCur)) - int.parse(product.priceCur)}₩', // 증가량
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // 입찰 금액 텍스트
                    Row(
                      children: [
                        Text('+1%', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: _sliderValue,
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                            },
                            min: 0.01,
                            max: 0.5,
                            divisions: 49, // 1% 단위로 나눔
                            label: '${(_sliderValue * 100).toInt()}%', // 슬라이더 값 표시
                          ),
                        ),
                        Text('+50%', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // 입찰하기 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 버튼 클릭 이벤트 처리
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      ),
                      child: Text(
                        '입찰하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No product found'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _randomProduct = fetchRandomProduct(); // 새로운 상품 가져오기
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
