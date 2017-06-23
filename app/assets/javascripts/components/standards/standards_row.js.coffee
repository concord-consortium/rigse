{div, tr, td, button} = React.DOM

window.StandardsRowClass = React.createClass

  displayName: "StandardsRowClass"

  addStandardStatement: (e) -> 
    console.log("addStandardStatement", e)
    alert("Add statement")
    e.preventDefault()

  render: ->
    statement = @props.statement

    console.log("Rendering statement.", statement);

    (tr {},
      (td {}, statement.doc)
      (td {}, statement.description)
      (td {}, statement.statement_label)
      (td {}, statement.statement_notation)
      (td {}, 
        (button {onClick: @addStandardStatement }, "Add")
      )
    )


window.StandardsRow = React.createFactory StandardsRowClass

