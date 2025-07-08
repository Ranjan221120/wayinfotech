import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../model/food_menu_model.dart';

class FoodMenuViewModel extends GetxController {
  var foodItems = <FoodItem>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchMenu();
    super.onInit();
  }

// Fetch the menu from the API
  Future<void> fetchMenu() async {
    isLoading.value = true;
    final url =
        'https://restromagic.wspl.co/api/MenuDetails/GetMenu?RestaurantId=4';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
      //heavy data is loading so using isolate
        final items = await compute(parseFoodItems, response.body);
        foodItems.value = items;
      } else {
        foodItems.value = [];
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


// Increment the quantity of an Food item
  void incrementQuantity(int index) {
    var item = foodItems[index];
    foodItems[index] = FoodItem(
      imageUrl: item.imageUrl,
      name: item.name,
      totalPrice: item.totalPrice,
      quantity: item.quantity + 1,
    );
  }


// Decrement the quantity of an Food item
  void decrementQuantity(int index) {
    var item = foodItems[index];
    if (item.quantity > 0) {
      foodItems[index] = FoodItem(
        imageUrl: item.imageUrl,
        name: item.name,
        totalPrice: item.totalPrice,
        quantity: item.quantity - 1,
      );
    }
  }


// Reset the quantities of all Food items after order are replaced
  void resetQuantities() {
    for (int i = 0; i < foodItems.length; i++) {
      var item = foodItems[i];
      if (item.quantity != 0) {
        foodItems[i] = FoodItem(
          imageUrl: item.imageUrl,
          name: item.name,
          totalPrice: item.totalPrice,
          quantity: 0,
        );
      }
    }
  }
}


Future<List<FoodItem>> parseFoodItems(String responseBody) async {
  List<dynamic> data = json.decode(responseBody);
  List<FoodItem> items = [];
  for (var group in data) {
    for (var item in group) {
      items.add(FoodItem.fromJson(item));
    }
  }
  return items;
}
