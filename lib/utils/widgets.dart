import 'package:flutter/material.dart';

Widget buildTextField({
  required String hintText,
  required IconData prefixIcon,
  required TextEditingController controller,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: hintText,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
  );
}


Widget buildNavigationButton({
  required BuildContext context,
  required String buttonText,
  required Widget destinationPage,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destinationPage),
        );
      },
      child: Text(buttonText),
    ),
  );
}
