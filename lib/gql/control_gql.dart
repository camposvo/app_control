class _gqlControl {
  _gqlControl() {}

  String gqlOrgaInstrument() {
    return r"""
        query LoadDataRevisiones($orgaId: String!) {
          loadDataRevisiones(orga_id: $orgaId) {
            ... on Configuracion {
              data
            }
          }
        }
        """;
  }

  String gqlOrganizations() {
    return r"""
       query Organizaciones($filter: filter) {
            organizaciones(filter: $filter) {
              ... on organizaciones {      
                data {
                  orga_id
                  orga_nombre
                  orga_activo
                  orga_prefijo
                }
              }
             
            }
          }
        """;
  }


  String gqlSaveComment() {
    return r"""
     mutation GuardarDataInstrumentosFinalizados($orgaId: String!, $finalizados: JSONObject) {
        guardarDataInstrumentosFinalizados(orga_id: $orgaId, finalizados: $finalizados)
      }
        """;
  }


  String gqlUpdateInstrument() {
    return r"""
   mutation UpdateInstrumento($orgaId: String!, $filter: filter, $fields: fieldInstrumento) {
          updateInstrumento(orga_id: $orgaId, filter: $filter, fields: $fields) {
            ... on instrumentos {
              data {
                inst_id
              }
            }
          }
        }
        """;
  }

  String gqlSaveTest() {
    return r"""
     mutation GuardarDataPruebasRevisiones($orgaId: String!, $prueba: JSONObject) {
        guardarDataPruebasRevisiones(orga_id: $orgaId, prueba: $prueba)
      }
        """;
  }

  String gqlSaveComments() {
    return r"""
        mutation GuardarDataComentariosRevisiones($orgaId: String!, $comentarios: JSONObject) {
          guardarDataComentariosRevisiones(orga_id: $orgaId, comentarios: $comentarios)
        }
        """;
  }



}

final gqlControl = _gqlControl();
