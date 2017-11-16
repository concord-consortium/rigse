{div, tr, td, button} = React.DOM

window.StandardsRowClass = React.createClass

  displayName: "StandardsRowClass"

  handleButton: (e) -> 

    statement   = @props.statement
    material    = @props.material
    apiUrl      = null
    add         = false

    params      = { identifier:     statement.uri,          \
                    material_type:  material.material_type, \
                    material_id:    material.material_id }

    if !statement.is_applied
      apiUrl = "/api/v1/materials/add_materials_standard"
      add = true
      Portal.showModal("#asn_search_modal", "Processing...", true)
    else
      apiUrl = "/api/v1/materials/remove_materials_standard"

    jQuery.ajax
      type:     "POST",
      url:      apiUrl
      data:     params
      dataType: 'json'

      success:  (data) =>
        statement.is_applied = !statement.is_applied
        @setState { statement: statement }
        window.loadAppliedStandards()

        if add
          Portal.hideModal()

      error: (jqXHR, textStatus, errorThrown) =>
        console.error("ERROR", jqXHR.responseText, jqXHR)

    e.preventDefault()

  render: ->
    statement   = @props.statement

    if !statement.is_applied
      buttonText = "Add"
    else 
      buttonText = "Remove"

    leaf = ""
    if statement.is_leaf
      leaf = "&#10004;"

    # console.log("[DEBUG] Adding statement", statement);

    (tr {className: 'asn_results_tr'},
      (td {className: 'asn_results_td'}, statement.doc)
      (td {className: 'asn_results_td asn_results_td_fixed'}, 
        (TextPreview { config: { text: statement.description, preview: true} } )
      )
      (td {className: 'asn_results_td asn_results_td_fixed'}, 
        (TextPreview { config: { text: statement.statement_label, preview: true} } )
      )
      (td {className: 'asn_results_td'}, statement.statement_notation)
      (td {className: 'asn_results_td'},
        (div { dangerouslySetInnerHTML: { __html: leaf } } )
      )
      (td {className: 'asn_results_td_right'}, 
        (button {onClick: @handleButton}, 
          buttonText
        )
      )
    )


window.StandardsRow = React.createFactory StandardsRowClass

