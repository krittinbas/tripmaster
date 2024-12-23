import 'package:flutter/material.dart';
import '../filter_chip.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final String selectedRating;
  final Function(List<String>, String) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.selectedCategories,
    required this.selectedRating,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _categories;
  late String _rating;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.selectedCategories);
    _rating = widget.selectedRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0)), // Add rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000D34),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000D34),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomFilterChip(
                  label: 'Restaurants',
                  selected: _categories.contains('Restaurants'),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _categories.add('Restaurants')
                          : _categories.remove('Restaurants');
                    });
                  },
                ),
                CustomFilterChip(
                  label: 'Hotels',
                  selected: _categories.contains('Hotels'),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _categories.add('Hotels')
                          : _categories.remove('Hotels');
                    });
                  },
                ),
                CustomFilterChip(
                  label: 'Tourist spot',
                  selected: _categories.contains('Tourist spot'),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _categories.add('Tourist spot')
                          : _categories.remove('Tourist spot');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000D34),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RatingChip(
                  label: '2.0+',
                  selected: _rating == '2.0+',
                  onSelected: (selected) {
                    setState(() {
                      _rating = selected ? '2.0+' : '';
                    });
                  },
                ),
                RatingChip(
                  label: '3.0+',
                  selected: _rating == '3.0+',
                  onSelected: (selected) {
                    setState(() {
                      _rating = selected ? '3.0+' : '';
                    });
                  },
                ),
                RatingChip(
                  label: '4.0+',
                  selected: _rating == '4.0+',
                  onSelected: (selected) {
                    setState(() {
                      _rating = selected ? '4.0+' : '';
                    });
                  },
                ),
                RatingChip(
                  label: '5.0',
                  selected: _rating == '5.0',
                  onSelected: (selected) {
                    setState(() {
                      _rating = selected ? '5.0' : '';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 168,
                  height: 47,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _categories = ['Restaurants', 'Hotels', 'Tourist spot'];
                        _rating = '4.0+';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFF000D34), fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 168,
                  height: 47,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(_categories, _rating);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000D34),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
