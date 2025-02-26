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


}

final gqlControl = _gqlControl();
