import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_finance/api/category_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/helper/icons.dart';
import 'package:my_finance/models/category_model.dart';
import 'package:my_finance/widgets/pop_up.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String selectedIcon = "misc"; // Default icon name
  late TapDownDetails tapPosition;
  List<ExpenseCategoryModel> categories = [];
  final CategoryService _categoryService = CategoryService();
  bool isLoading = true;

  final List<ExpenseCategoryModel> defaultCategories = [
    ExpenseCategoryModel(
        id: '1', name: 'Food', color: '#FF5733', iconName: 'food'),
    ExpenseCategoryModel(
        id: '2', name: 'Rent', color: '#4285F4', iconName: 'rent'),
    ExpenseCategoryModel(
        id: '3',
        name: 'Entertainment',
        color: '#FFEB3B',
        iconName: 'entertainment'),
    ExpenseCategoryModel(
        id: '4', name: 'Transport', color: '#4CAF50', iconName: 'transport'),
    ExpenseCategoryModel(
        id: '5', name: 'Shopping', color: '#9C27B0', iconName: 'shopping'),
    ExpenseCategoryModel(
        id: '6', name: 'Health', color: '#E91E63', iconName: 'health'),
    ExpenseCategoryModel(
        id: '7', name: 'Salary', color: '#009688', iconName: 'salary'),
    ExpenseCategoryModel(
        id: '8', name: 'Investment', color: '#FF9800', iconName: 'investment'),
    ExpenseCategoryModel(
        id: '9', name: 'Bills', color: '#795548', iconName: 'bills'),
    ExpenseCategoryModel(
        id: '10', name: 'Savings', color: '#607D8B', iconName: 'savings'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    List<ExpenseCategoryModel> userCategories =
        await _categoryService.fetchCategories();
    setState(() {
      categories = [
        ...defaultCategories,
        ...userCategories
      ]; // Merge default & user categories
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Categories",
          style: TextStyle(color: Colors.white), // Ensures white text
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme:
            IconThemeData(color: Colors.white), // Ensures white back icon
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Default Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevents inner scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3,
                    ),
                    itemCount: defaultCategories.length,
                    itemBuilder: (context, index) {
                      final category = defaultCategories[index];
                      return _buildCategoryCard(category, true);
                    },
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey, thickness: 2),
                  SizedBox(height: 20),
                  Text("Your Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3,
                    ),
                    itemCount: categories.length - defaultCategories.length,
                    itemBuilder: (context, index) {
                      final category =
                          categories[defaultCategories.length + index];
                      return _buildCategoryCard(category, false);
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    String selectedIcon = "misc"; // Ensure this matches a key in AppIcons.icons
    Color selectedColor = Colors.greenAccent;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Category"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Dropdown
                  DropdownButton<String>(
                    value: selectedIcon, // Must match a key in AppIcons.icons
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => selectedIcon = newValue);
                      }
                    },
                    items: AppIcons.icons.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key, // Ensure each key is unique
                        child: Row(
                          children: [
                            Icon(AppIcons.icons[key], color: Colors.white),
                            SizedBox(width: 10),
                            Text(key),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 10),

                  // Color Picker
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor),
                    icon: Icon(Icons.color_lens, color: Colors.white),
                    label: Text("Pick Color",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Pick a Color"),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (color) {
                                  setState(() => selectedColor = color);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String colorHex =
                        '#${selectedColor.value.toRadixString(16).substring(2)}';

                    await _categoryService.addCategory(
                      ExpenseCategoryModel(
                        id: '',
                        name:
                            selectedIcon, // Use the selected icon key as the name
                        color: colorHex,
                        iconName: selectedIcon, // Store icon name
                      ),
                    );

                    _loadCategories();
                    Navigator.pop(context);
                  },
                  child: Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(ExpenseCategoryModel category, bool isDefault) {
    return GestureDetector(
      onTapDown: (details) => tapPosition = details,
      onTap: () {
        print("Selected Category: ${category.name}");
      },
      onLongPress: () {
        if (!isDefault) {
          PopUP().showPopupMenu(context, tapPosition, category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Default categories cannot be deleted!"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        color: Color(int.parse(category.color.replaceFirst('#', '0xff'))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(AppIcons.icons[category.iconName], color: Colors.white),
              Text(category.name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
