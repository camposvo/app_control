class _gqlAlmacenamiento {
  _gqlAlmacenamiento() {}

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

  String almacenBacha() {
    return r"""
        query Almacenamientos($filter: filter, $paginacion: paginacion) {
          almacenamientos(filter: $filter, paginacion: $paginacion) {
            ... on almacenamientos {      
              data {
                alma_id      
                alma_bach_id             
                bach_lote
                bach_fecha_elab
                bach_fecha_venc      
                sabo_codigo
                estr_fila
                estr_columna
                esta_abreviatura
                esta_nombre
              }
            }
          }
        }
        """;
  }

  String updateAlmacenamiento() {
    return r"""
        mutation UpdateAlmacenamiento($filter: filter, $fields: fieldAlmacenamiento) {
          updateAlmacenamiento(filter: $filter, fields: $fields) {
            ... on almacenamientos {
              data {
                alma_id
              }
              totalCount
            }
            ... on msg {
              tipo
              mensaje
            }
          }
        }
        """;
  }

  String retirarItem() {
    return r"""
        mutation RetirarItem($fields: fieldRetirarItem) {
          retirarItem(fields: $fields) {
            ... on retirarItem {
              alma_id
              succsess
            }
            ... on msg {
              tipo
              mensaje
            }
          }
        }
        """;
  }


  String cancelRetirarItem() {
    return r"""
       mutation CancelRetirarItem($fields: fieldCancelRetirarItem) {
              cancelRetirarItem(fields: $fields) {
                ... on retirarItem {
                  alma_id
                  succsess
                }
                ... on msg {
                  tipo
                  mensaje
                }
              }
            }
        """;
  }






}

final gqlAlmacenamiento = _gqlAlmacenamiento();
