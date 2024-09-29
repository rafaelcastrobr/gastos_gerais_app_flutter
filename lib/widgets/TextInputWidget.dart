import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos_gerais_app_flutter/utils/formtaterTexts.dart';
import 'package:intl/intl.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String titulo;
  final TextInputType typeInput;
  final bool isValor;
  const TextInputWidget({super.key, required this.controller, required this.titulo, required this.typeInput, required this.isValor});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 20),
      controller: widget.controller,
      keyboardType: widget.typeInput,
      inputFormatters: widget.isValor ? [CurrencyInputFormatter()] : [],
      decoration: InputDecoration(
        label: Text(widget.titulo),
      ),
    );
  }
}
