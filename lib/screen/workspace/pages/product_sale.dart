import 'package:flutter/material.dart';

class ProductSalePage extends StatelessWidget {
  const ProductSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Bán hàng",
          style: TextStyle(
              color: Color(0xFF1F2329),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Image.asset(
              "assets/images/comming_soon.png",
            ),
            const Text(
              "Tính năng đang được phát triển\nHãy quay lại sau bạn nhé!",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
