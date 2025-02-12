
import 'package:graphql_flutter/graphql_flutter.dart';

class Validate {
  Validate() {}

  static String? rules(String rule, String value) {
    String? result = null;
    bool sw = false;
    List<String> rules = rule.split("|");

    sw = rules.indexWhere((val) => val == 'required') == -1 ? false : true;
    if (sw && (result = isEmpty(value)) != null) return result;

    sw = rules.indexWhere((val) => val == 'text') == -1 ? false : true;
    if (sw && (result = isText(value)) != null) return result;

    sw = rules.indexWhere((val) => val == 'not_null') == -1 ? false : true;
    if (sw && (result = isNull(value)) != null) return result;

    sw = rules.indexWhere((val) => val == 'username') == -1 ? false : true;
    if (sw && (result = isUserName(value)) != null) return result;

    sw = rules.indexWhere((val) => val == 'greaterThanZero') == -1 ? false : true;
    if (sw && (result = greaterThanZero(value)) != null) return result;

    sw = rules.indexWhere((val) => val == 'isDouble') == -1 ? false : true;
    if (sw && (result = isDouble(value)) != null) return result;

    return result;
  }

  static String? isEmpty(String value) {
    if (value.isEmpty) return "Este campo es requerido";
    return null;
  }

  static String? isUserName(String value) {
    if (!RegExp(r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$').hasMatch(value))
      return 'Este nombre es invalido';

    if (RegExp(r'\s+').hasMatch(value))
      return 'El  nombre de usuario no debe contener espacio';

    if (value.length < 4)
      return 'El  nombre debe tener al menos 4 Caracteres';

    return null;
  }

  static String? isNull(String value) {
    if (value == null) {
      return "Este campo es requerido";
    }
    return null;
  }

  static String? isText(String value) {
    if (!RegExp(r'^[a-zA-Z\s]{1,100}$').hasMatch(value)) {
      return 'Este Campos sólo acepta Letras';
    }
    return null;
  }

  static String? isEmail(String value) {
    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
      return 'Este Email no es valido';
    }
    return null;
  }

  static String? greaterThanZero(String a ) {
    final numA = int.parse(a);
    if(numA <= 0 ) return "Debe indicar un valor mayor que cero (0)";
    return null;
  }

  static String? isDouble(String a ) {
    final num = double.tryParse(a) ?? null;

    if(num == null) return "Debe ser un valor válido";
    if(num <= 0 ) return "Debe indicar un valor mayor que cero (0)";

    return null;
  }

  static String? lessThan(String a, String b ) {
    final numA = double.parse(a);
    final numB = double.parse(b);

    if(numA == null || numB == null) return "Este campo es requerido";

    if(numA <= 0 ) return "Debe indicar un valor mayor que cero (0)";

    if(numA > numB ) return "El valor debe ser menor o igual a $numB";

    return null;
  }

  static String? smallerThanNow(DateTime a) {

    final current = DateTime.now();
    if(a == null) return "Este campo es requerido";

    if( current.compareTo(a) <= 0 ) return "La fecha debe ser menor o igual a la actual";

    return null;
  }

  static String? higherThanNow(DateTime a) {
    final current = DateTime.now();
    if(a == null) return "Este campo es requerido";

    if( current.compareTo(a) > 0 ) return "La fecha debe ser mayor a la actual";

    return null;
  }

  static String? smallerThanOther(DateTime a, DateTime other) {
    if(a == null) return "Este campo es requerido";

    if(other == null) return "Ingrese primero la fecha inicial";

    if( a.compareTo(other) < 0 ) return "La fecha final debe ser mayor a la inicial";

    return null;
  }

  static String? isPasswd(String value) {
    if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[.+!-_@=#$%^&*])(?=.{8,})')
        .hasMatch(value)) {
      return 'La Contraseña no cumple con el nivel mínimo de seguridad';
    }
    return null;
  }

  static String? containSpace(String value) {
    if (RegExp(r'\s+').hasMatch(value)) {
      return 'La Contraseña no debe contener espacio';
    }
    return null;
  }

  static String? isEqual(String a, String b) {
    if (a != b) {
      return 'La Contraseña no coincide';
    }
    return null;
  }



}
