{div, table, thead, tbody, tr, th, td, button} = React.DOM

window.StandardsTableClass = React.createClass

  displayName: "StandardsTableClass"

  render: ->

    (table {className: 'asn_results_table'},

      (tbody {},

        (tr {},
          (th {className: 'asn_results_th'}, "Type")
          (th {className: 'asn_results_th'}, "Description")
          (th {className: 'asn_results_th'}, "Label")
          (th {className: 'asn_results_th'}, "Notation")
          (th {className: 'asn_results_th'}, "Action")
        )

        for statement in @props.statements
          (StandardsRow {statement: statement, key: statement.uri, material: @props.material} )
      )
    )


window.StandardsTable = React.createFactory StandardsTableClass

