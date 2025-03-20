import 'package:flutter/material.dart';
import 'package:my_finance/api/category_service.dart';
import 'package:my_finance/models/category_model.dart';
import 'package:my_finance/helper/icons.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryDropdown({Key? key, required this.onCategorySelected})
      : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final CategoryService _categoryService = CategoryService();
  List<ExpenseCategoryModel> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true; // ✅ Added isLoading

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    List<ExpenseCategoryModel> firestoreCategories =
        await _categoryService.fetchCategories();

    // Avoid duplicates
    Set<String> existingNames =
        firestoreCategories.map((c) => c.name.toLowerCase()).toSet();
    List<ExpenseCategoryModel> allCategories = [
      ...firestoreCategories,
      ..._categoryService.defaultCategories
          .where((c) => !existingNames.contains(c.name.toLowerCase())),
    ];

    setState(() {
      _categories = allCategories; // ✅ Fixed variable name
      _isLoading = false; // ✅ Fixed isLoading
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: "Category",
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category.name,
          child: Row(
            children: [
              Icon(
                AppIcons.icons[category.iconName] ??
                    Icons.category, // ✅ Fixed icon fetching
                color: Color(int.parse(category.color
                    .replaceFirst('#', '0xff'))), // ✅ Convert hex to Color
              ),
              const SizedBox(width: 10),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
        widget.onCategorySelected(value!);
      },
    );
  }
}
