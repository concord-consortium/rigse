{div} = React.DOM

window.MaterialsBinClass = React.createClass
  propTypes:
    materials: React.PropTypes.array.isRequired

  getInitialState: ->
    state = {
      # selectedCategories[2] returns value of row that is selected in column 2 (or falsy value if nothing is selected).
      # E.g. selectedCategories = [1, 3, 2] means that:
      # - the second row is selected (idx = 1) in the first column,
      # - the fourth row is selected (idx = 3) in the second column,
      # - the third row is selected (idx = 2) in the third column.
      selectedCategories: []
    }
    # Initially select first category in every column.
    column = 0
    array = @props.materials
    while array[0].children
      state.selectedCategories[column] = 0
      array = array[0].children
      column++

    state

  handleCellClick: (column, row) ->
    @state.selectedCategories[column] = row
    # Unselect all the cells that are to the right of modified column.
    @state.selectedCategories.length = column + 1
    @setState @state

#    # Another approach (requires React.addons):
#    # TODO: is it better? What's the difference?
#    action = {}
#    if @isCategorySelected column, row
#      action[column] = $set: null # unselect
#    else
#      action[column] = $set: row # select
#
#    # Unselect all the cells that are to the right of modified column.
#    Object.keys(@state.selectedCategories).forEach (c) ->
#      action[c] = $set: null if c > column
#
#    newState = React.addons.update @state, selectedCategories: action
#    @setState newState

  isCategorySelected: (column, row) ->
    @state.selectedCategories[column] == row

  # Transforms @props.materials hash into array of arrays representing columns and their rows.
  # Raw form of @props.materials doesn't work well with table view.
  # Also, apply current state (selected cells and visibility).
  _getColumns: ->
    columns = []
    # Adds all elements of `array` to column `columnIdx` and marks them as `visible`.
    # Note that the array is @params.materials at the beginning and then its child elements recursively.
    fillColumns = (array, columnIdx, visible) =>
      columnIdx = 0 unless columnIdx?
      visible = true unless visible?
      columns[columnIdx] = [] unless columns[columnIdx]?
      array.forEach (cell) =>
        rowIdx = columns[columnIdx].length
        selected = @isCategorySelected columnIdx, rowIdx
        cellData = if cell.category
                     category: cell.category
                     column: columnIdx
                     row: rowIdx
                     visible: visible
                     selected: selected
                   else
                     collections: cell.collections
                     visible: visible
                     
        columns[columnIdx].push cellData
        if cell.children
          # Recursively go to children array, add its elements to column + 1
          # and mark them visible only if current cell is selected.
          fillColumns cell.children, columnIdx + 1, selected

    fillColumns @props.materials
    columns

  render: ->
    (div {className: 'materials-bin'},
      for column in @_getColumns()
        (div {className: 'mb-column'},
          for cell in column
            if cell.category
              (MaterialsCategory {
                  visible: cell.visible
                  selected: cell.selected
                  column: cell.column
                  row: cell.row
                  handleClick: @handleCellClick
                },
                cell.category
              )
            else
              (MaterialsContainer
                visible: cell.visible
                collections: cell.collections
              )
        )
    )

window.MaterialsBin = React.createFactory MaterialsBinClass

# Helper components:

MaterialsCategory = React.createFactory React.createClass
  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  getSelectionClass: ->
    if @props.selected then 'mb-selected' else ''

  handleClick: ->
    @props.handleClick @props.column, @props.row

  render: ->
    className = "mb-cell mb-clickable #{@getVisibilityClass()} #{@getSelectionClass()}"
    (div {className: className, onClick: @handleClick},
      @props.children
    )
