import 'package:flutter/material.dart';

class RouteSearchBar extends StatefulWidget {
  const RouteSearchBar({super.key});

  @override
  RouteSearchBarState createState() => RouteSearchBarState();
}

class RouteSearchBarState extends State<RouteSearchBar> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField('Starting point', _startController),
        const SizedBox(height: 8.0),
        _buildSearchField('Destination', _destinationController),
      ],
    );
  }

  Widget _buildSearchField(String hintText, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          //? Implement the route search functionality here
          print('$hintText submitted: $value');
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
