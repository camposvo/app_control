import 'package:flutter/services.dart';


class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1. Limpiar la entrada: Permitir solo dígitos.
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 2. Si el texto está vacío después de limpiar, restaurar el valor por defecto.
    if (digitsOnly.isEmpty) {
      return TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: '0,00'.length),
      );
    }

    // 3. Asegurar que tenemos al menos 3 dígitos rellenando con ceros a la izquierda
    // para manejar los casos 0,01, 0,12, etc.
    String paddedDigits = digitsOnly.padLeft(3, '0');

    // 4. Extraer la parte entera y la parte decimal
    String integerPart = paddedDigits.substring(0, paddedDigits.length - 2);
    String decimalPart = paddedDigits.substring(paddedDigits.length - 2);

    // 5. Eliminar ceros a la izquierda de la parte entera si no es el único dígito "0"
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
      if (integerPart.isEmpty) {
        integerPart = '0'; // En caso de que se eliminen todos los ceros (ej. "00" -> ""), dejar "0"
      }
    }

    String finalFormattedText = '$integerPart,$decimalPart';

    // 6. Posicionar el cursor siempre al final del texto formateado.
    return TextEditingValue(
      text: finalFormattedText,
      selection: TextSelection.collapsed(offset: finalFormattedText.length),
    );
  }
}