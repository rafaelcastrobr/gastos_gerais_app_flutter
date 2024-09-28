import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String titulo;
  final TextInputType typeInput;
  const TextInputWidget({super.key, required this.controller, required this.titulo, required this.typeInput});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.typeInput,
      decoration: InputDecoration(
      
        label: Text(widget.titulo),
      ),
    );
  }
}
