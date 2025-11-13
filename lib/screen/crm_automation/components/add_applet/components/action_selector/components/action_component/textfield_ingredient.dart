import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/action_selector_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/ingredient_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldIngredient extends StatefulWidget {
  final String label;
  final int maxLine;

  final TextEditingController controller;

  const TextFieldIngredient({
    super.key,
    required this.controller,
    required this.label,
    required this.maxLine,
  });

  @override
  State<TextFieldIngredient> createState() => _TextFieldIngredientState();
}

class _TextFieldIngredientState extends State<TextFieldIngredient> {
  bool isFocused = false;
  final buttonKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActionSelectorController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
                fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: Get.width - 40,
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  isFocused = hasFocus;
                });
              },
              child: TextFormField(
                maxLines: widget.maxLine,
                controller: widget.controller,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(top: 10, left: 20, right: 10),
                    filled: true,
                    fillColor: const Color(0xFFf3f4f6),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    suffixIcon: isFocused
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => IngredientDialog(
                                  onIngTap: (data) {
                                    setState(() {
                                      widget.controller.text +=
                                          "{{${data["data"]}}}";
                                    });
                                  },
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.add_circle,
                              color: Colors.black,
                              size: 25,
                            ))
                        : null),
              ),
            ),
          ),
        ],
      );
    });
  }
}
