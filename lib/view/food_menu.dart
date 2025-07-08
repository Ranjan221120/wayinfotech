import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodel/food_menu_viewmodel.dart';

class FoodMenu extends StatefulWidget {
  const FoodMenu({super.key});

  @override
  State<FoodMenu> createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  final FoodMenuViewModel controller = Get.put(FoodMenuViewModel());


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Food Menu",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Responsive font size
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: showFoodMenu(width, height)),
        ],
      ),
      bottomNavigationBar: Obx(() {
        bool hasFoodItems = controller.foodItems.any((item) => item.quantity > 0);
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: hasFoodItems
                  ? () async {
                      bool? confirmed = await confirmOrderPlace();
                      if (confirmed == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Your order has been placed successfully!')),
                        );
                        controller.resetQuantities();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasFoodItems ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              child: Text('Place Order'),
            ),
          ),
        );
      }),
    );
  }

  showFoodMenu(double width, double height) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.foodItems.isEmpty) {
        return Center(
            child: Text(
          "No Menu List",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
        ));
      }
      return ListView.builder(
        itemCount: controller.foodItems.length,
        itemBuilder: (context, index) {
          final item = controller.foodItems[index];
          return ListTile(
            leading: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          size: 50,
                        );
                      },
                    ),
                  )
                : Icon(Icons.fastfood, size: 50),
            title: Text(item.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text('₹${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            trailing: cartWidget(width, index, item.quantity),
          );
        },
      );
    });
  }

  cartWidget(double width, int index, int quantity) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * 0.2,
            maxHeight: constraints.maxHeight*0.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: quantity == 0
              ? InkWell(
                  onTap: () {
                    controller.incrementQuantity(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.015),
                    child: Center(
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    decrementItem(width, index, quantity),
                    Text(
                      quantity.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    incrementItem(width, index),
                  ],
                ),
        );
      },
    );
  }

  decrementItem(double width, int index, int quantity) {
    return InkWell(
      onTap: () {
        if (quantity > 0) controller.decrementQuantity(index);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.01,vertical: width * 0.015),
        child: Icon(
          Icons.remove,
          color: quantity > 0 ? Colors.blue : Colors.grey,
          size: width * 0.05,
        ),
      ),
    );
  }

  incrementItem(double width, int index) {
    return InkWell(
      onTap: () {
        controller.incrementQuantity(index);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.01,vertical: width * 0.015),
        child: Icon(
          Icons.add,
          color: Colors.blue,
          size: width * 0.05,
        ),
      ),
    );
  }

  confirmOrderPlace() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Confirm Order'),
        content: Text('Are you sure you want to place the order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
