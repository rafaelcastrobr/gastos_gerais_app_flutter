import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/utils/formtaterTexts.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String titulo;
  final TextInputType typeInput;
  final bool isValor;
  final double largura;
  const TextInputWidget({super.key, required this.controller, required this.titulo, required this.typeInput, required this.isValor, required this.largura, required this.focusNode});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.largura,
      child: TextField(
        focusNode: widget.focusNode,
        style: const TextStyle(fontSize: 20),
        controller: widget.controller,
        keyboardType: widget.typeInput,
        inputFormatters: widget.isValor ? [CurrencyInputFormatter()] : [],
        decoration: InputDecoration(
          label: Text(widget.titulo),
        ),
      ),
    );
  }
}
