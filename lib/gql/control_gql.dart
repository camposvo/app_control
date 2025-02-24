class _gqlControl {
  _gqlControl() {}

  String almacenamiento() {
    return r"""
           mutation InsertAlmacenamiento($fields: fieldAlmacenamiento) {
            insertAlmacenamiento(fields: $fields) {
              ... on msg {
                tipo
                mensaje
              }
              ... on almacenamiento {
                alma_id
                alma_activo
                alma_bach_id
                alma_estr_id
                alma_fecha_entrada
                alma_fecha_salida
              }
            }
          }
        """;
  }


}

final gqlAlmacenamiento = _gqlControl();
