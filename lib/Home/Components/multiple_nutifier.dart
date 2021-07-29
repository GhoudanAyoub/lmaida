import 'package:flutter/material.dart';

class MultipleNotifier extends ChangeNotifier {
  List<String> _selecteItems;
  MultipleNotifier(this._selecteItems);
  List<String> get selectedItems => _selecteItems;

  bool isHaveItem(String value) => _selecteItems.contains(value);

  addItem(String value) {
    if (!isHaveItem(value)) {
      _selecteItems.add(value);
      notifyListeners();
    }
  }

  removeItem(String value) {
    if (isHaveItem(value)) {
      _selecteItems.remove(value);
      notifyListeners();
    }
  }
}

class MultipleCityNotifier extends ChangeNotifier {
  List<String> _selecteItems;
  MultipleCityNotifier(this._selecteItems);
  List<String> get selectedItems => _selecteItems;

  bool isHaveItem(String value) => _selecteItems.contains(value);

  addItem(String value) {
    if (!isHaveItem(value)) {
      _selecteItems.add(value);
      notifyListeners();
    }
  }

  removeItem(String value) {
    if (isHaveItem(value)) {
      _selecteItems.remove(value);
      notifyListeners();
    }
  }
}

class MultipleSpectsNotifier extends ChangeNotifier {
  List<String> _selecteItems;
  MultipleSpectsNotifier(this._selecteItems);
  List<String> get selectedItems => _selecteItems;

  bool isHaveItem(String value) => _selecteItems.contains(value);

  addItem(String value) {
    if (!isHaveItem(value)) {
      _selecteItems.add(value);
      notifyListeners();
    }
  }

  removeItem(String value) {
    if (isHaveItem(value)) {
      _selecteItems.remove(value);
      notifyListeners();
    }
  }
}
