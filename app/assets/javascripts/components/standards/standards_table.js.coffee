{div, table, thead, tbody, tr, th, td} = React.DOM

window.StandardsTableClass = React.createClass

  displayName: "StandardsTableClass"

  render: ->

    console.log("Rendering component.", @props);

    (table {className: 'asn_results_table'},

      (tbody {},

        (tr {},
          (th {className: 'asn_results_th'}, "Applied")
          (th {className: 'asn_results_th'}, "Description")
          (th {className: 'asn_results_th'}, "Label")
          (th {className: 'asn_results_th'}, "Notation")
        )

        for statement in @props.statements
          (tr {},
            (td {}, statement.is_applied)
            (td {}, statement.description)
            (td {}, statement.statement_label)
            (td {}, statement.statement_notation)
          )
      )
    )

window.StandardsTable = React.createFactory StandardsTableClass

