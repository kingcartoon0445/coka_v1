import 'package:coka/components/elevated_btn.dart';
import 'package:flutter/material.dart';

class IncrementDecrementWidget extends StatefulWidget {
  final Function onChange;
  final int? initValue;

  const IncrementDecrementWidget(
      {super.key, required this.onChange, this.initValue});

  @override
  State<IncrementDecrementWidget> createState() =>
      _IncrementDecrementWidgetState();
}

class _IncrementDecrementWidgetState extends State<IncrementDecrementWidget> {
  int _count = 1; // Số lượng ban đầu

  void _increment() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_count < 100) {
      _count++;
      _controller.text = "$_count";
    }
  }

  void _decrement() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_count > 0) {
      _count--;
      _controller.text = "$_count";
    }
  }

  final TextEditingController _controller = TextEditingController();

  void _onTextChanged(String value) {
    int? parsedValue = int.tryParse(value);
    if (parsedValue != null) {
      if (parsedValue < 0) {
        parsedValue = 0;
        _controller.text = "0";
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (parsedValue > 100) {
        parsedValue = 100;
        _controller.text = "100";
        FocusScope.of(context).requestFocus(FocusNode());
      }
      _count = parsedValue;
      widget.onChange(_count);
    }
  }

  void updateValue(String newValue) {
    _controller.text = newValue;
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initValue != null
        ? widget.initValue.toString()
        : _count.toString();
    _count = widget.initValue ?? 1;
    _controller.addListener(() {
      _onTextChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant IncrementDecrementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initValue != _count) {
      _count = widget.initValue ?? 1;
      _controller.text = _count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
          color: const Color(0xFFE3DFFF),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedBtn(
              paddingAllValue: 6,
              circular: 50,
              onPressed: () {
                _decrement();
              },
              child: const Text("-", style: TextStyle(fontSize: 20))),
          Container(
            width: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedBtn(
              paddingAllValue: 6,
              circular: 50,
              onPressed: () {
                _increment();
              },
              child: const Text("+", style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }
}
