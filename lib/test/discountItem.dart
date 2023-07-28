
import 'package:flutter/material.dart';

class TrialSelectItemForDiscount extends StatefulWidget {
  const TrialSelectItemForDiscount({
    Key? key,
    required this.otems,
    required this.skus,
    required this.onSkusSelected,
  });
  final List<dynamic> otems;
  final List<dynamic> skus;

  final Function(Map<String, String>) onSkusSelected;

  @override
  State<TrialSelectItemForDiscount> createState() =>
      _TrialSelectItemForDiscountState();
}

class _TrialSelectItemForDiscountState
    extends State<TrialSelectItemForDiscount> {
  Map<String, String> selectedSkus = {};

  bool okTapped = false;
  bool showRefresh = false;
  bool isAllItemsSelected = false;

  int? selectedStaffIndex;
  Set<int> selectedItems = {};
  int selectedItemCount = 0;

  void updateSelectedItems(Set<int> updatedSelectedItems) {
    setState(() {
      selectedItems = updatedSelectedItems;
      selectedItemCount = selectedItems.length;

      // Update selectedSkus map
      selectedSkus.clear();
      for (int index in selectedItems) {
        final sku = widget.otems[index];
        selectedSkus['otemID'] = sku['otemID'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          title: const Text(
            "Select Items",
            //  "Select Items ${selectedItems.length}",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Image.asset(
              "lib/assets/Artboard 40.png",
              height: 30,
              width: 20,
            ),
            onPressed: () => Navigator.pop(context),
            iconSize: 24,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 2. Implement the logic to select/deselect all items here.
                setState(() {
                  if (isAllItemsSelected) {
                    // If all items are already selected, then deselect all items.
                    selectedItems.clear();
                    selectedSkus.clear();
                  } else {
                    // If not all items are selected, then select all items.
                    for (int index = 0; index < widget.otems.length; index++) {
                      selectedItems.add(index);
                      final sku = widget.otems[index];
                      selectedSkus[index.toString()] = sku['otemID'].toString();
                    }
                  }
                  // 3. Update the isAllItemsSelected variable.
                  isAllItemsSelected = !isAllItemsSelected;
                });
              },
              child: Text(
                isAllItemsSelected ? "Deselect all" : "Select all",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(color: Colors.grey[200]),
            Column(
              children: [hi()],
            ),
          ],
        ),
        bottomNavigationBar: addButton());
  }

  Widget hi() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.otems.length,
              itemBuilder: (context, index) {
                final sku = widget.otems[index];
                print("lepas final: ${widget.otems}");
                print("sku: $sku");
                dynamic ssku = widget.skus
                    .firstWhere((ssku) => ssku['skuID'] == sku['skuID']);
                final item2 = ssku;
                final isSelected = selectedItems.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedItems.contains(index)) {
                        selectedItems.remove(index);
                        selectedSkus.remove(index.toString());
                      } else {
                        selectedItems.add(index);

                        selectedSkus[index.toString()] =
                            sku['otemID'].toString();
                        print("ssku : $ssku");
                      }
                      print(selectedSkus);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item2['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item2['selling'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget addButton() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0,
          bottom: 30.0,
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {});
            widget.onSkusSelected(selectedSkus);
            final int totalSelected = selectedItems.length;
            final int totalItems = widget.otems.length;
            final String selectedItemText =
                totalSelected == totalItems ? "All" : "$totalSelected";

            // print("hhhh: $selectedItemText");

            Navigator.pop(context, selectedItemText);
            //   Navigator.pop(context, selectedItems.length);
            // print('Pass total selected container: $selectedItems');
          },
          style: ElevatedButton.styleFrom(
          // Set the desired height and width here
          fixedSize: Size(340, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ), // Change the values according to your needs
        ),
          
          child: const Text('OK', style: TextStyle(
            fontSize: 18,
            fontFamily: 'SFProDisplay', // Use the specified font family
            fontWeight: FontWeight.normal, // You can also adjust the font weight
          ),),
        ),
      ),
    );
  }
}
