{div, tr, td, button} = React.DOM

window.StandardsRowClass = React.createClass

  displayName: "StandardsRowClass"

  addStandardStatement: (e) -> 

    console.log("addStandardStatement", @props.statement.uri, @props.material.material_type, @props.material.material_id);

    statement   = @props.statement
    material    = @props.material
    apiUrl      = null

    params      = { identifier:     statement.uri,          \
                    material_type:  material.material_type, \
                    material_id:    material.material_id }

    if !statement.is_applied
      apiUrl = "/api/v1/materials/add_materials_standard"
    else
      apiUrl = "/api/v1/materials/remove_materials_standard"

    jQuery.ajax
      url: apiUrl
      data: params
      dataType: 'json'
      success: (data) =>
        console.log("INFO", data.message)
        statement.is_applied = !statement.is_applied
        @setState { statement: statement }
      error: (jqXHR, textStatus, errorThrown) =>
        console.error("ERROR", jqXHR.responseText, jqXHR)

    e.preventDefault()

  render: ->
    statement   = @props.statement

    console.log("Rendering statement.", statement);

    if !statement.is_applied
      buttonText = "Add"
    else 
      buttonText = "Remove"

    (tr {className: 'asn_results_tr'},
      (td {className: 'asn_results_td'}, statement.doc)
      (td {className: 'asn_results_td'}, statement.description)
      (td {className: 'asn_results_td'}, statement.statement_label)
      (td {className: 'asn_results_td'}, statement.statement_notation)
      (td {className: 'asn_results_td'}, 
        (button {onClick: @addStandardStatement }, 
          buttonText
        )
      )
    )


window.StandardsRow = React.createFactory StandardsRowClass

