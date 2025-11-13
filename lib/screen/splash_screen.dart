
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/default_button.dart';
import '../constants.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _BodyState();
}

class _BodyState extends State<SplashScreen> {
  final PageController _controller = PageController(initialPage: 0);
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "title": "XIN CHÀO!",
      "text":
      "Mời bạn khám phá ứng dụng COKA\nỨng dụng đa chứng năng dành cho sales.",
      "image": "assets/images/welcome_4.png"
    },
    {
      "title": "ĐA CHỨC NĂNG",
      "text":
      "Khai thác data, quản lý khách hàng, bán hàng,\nkết nối cộng đồng trong cùng một ứng dụng.",
      "image": "assets/images/welcome_5.png"
    },
    {
      "title": "ĐỔI MỚI",
      "text": "Chốt khách dễ dàng hơn cùng COKA\nKhám phá ngay!",
      "image": "assets/images/welcome_6.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Image.asset(
                        splashData[index]["image"]!,
                        height: 265,
                        width: 235,
                      ),
                      const Spacer(),
                      Container(
                        height: size.height * 0.5,
                        width: size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 80,
                            ),
                            Text(
                              splashData[index]['title']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              splashData[index]['text']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    splashData.length,
                        (index) => buildDot(index: index),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const Spacer(),
                if (currentPage == 0 || currentPage == 1)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 40, left: 27, right: 27),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.offNamed('/login');
                          },
                          child: const Text(
                            'Bỏ qua',
                            textAlign: TextAlign.left,
                            style:
                            TextStyle(color: Color(0x993f3849)),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                            onTap: (){
                              _controller.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                            },
                            child: Image.asset(
                              "assets/images/shape.png",width: 60, height: 60,
                            )),
                      ],
                    ),
                  ),
                if (currentPage == 2)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: DefaultButton(isLoading: false,
                          text: 'Tiếp tục', press: () {
                            Get.offNamed('/login');
                          }),
                    ),
                  ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: currentPage == index ? 22 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
