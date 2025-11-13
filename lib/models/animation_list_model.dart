import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/crm_automation/components/add_applet/add_applet_controller.dart';

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    AddAppletController controller = Get.put(AddAppletController());
    controller.addOneAction(index);
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  void pathInsert(int index, E item) {
    PathController controller = Get.put(PathController());
    controller.addOneAction(index);
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    AddAppletController controller = Get.put(AddAppletController());
    final E removedItem = _items.removeAt(index);
    controller.deleteOneAction(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  E pathRemoveAt(int index) {
    PathController controller = Get.put(PathController());
    final E removedItem = _items.removeAt(index);
    controller.deleteOneAction(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
