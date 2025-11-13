import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ingredient_dialog.dart';

class TextFieldIngredient extends StatefulWidget {
  final TextEditingController controller;

  const TextFieldIngredient({super.key, required this.controller});

  @override
  State<TextFieldIngredient> createState() => _TextFieldIngredientState();
}

class _TextFieldIngredientState extends State<TextFieldIngredient> {
  final buttonKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Get.width - 40,
          height: 50,
          child: Focus(
            child: TextFormField(
              maxLines: 1,
              controller: widget.controller,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 8, left: 25, right: 10),
                  hintText: "Nhập nội dung so sánh",
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => IngredientDialog(
                            onIngTap: (data) {
                              setState(() {
                                widget.controller.text += "{{${data["data"]}}}";
                              });
                            },
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.add_circle,
                        color: Colors.black,
                        size: 25,
                      ))),
            ),
          ),
        ),
      ],
    );
  }
}
