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
    # Unselect all the cells that are to the right of modified column.
    newCat = @state.selectedCategories.slice 0, column + 1
    # Select clicked category
    newCat[column] = row
    @setState selectedCategories: newCat

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
      array.forEach (cellDef) =>
        rowIdx = columns[columnIdx].length
        selected = @isCategorySelected columnIdx, rowIdx
        columns[columnIdx].push if cellDef.category
                                  (MBMaterialsCategory {
                                      visible: visible
                                      selected: selected
                                      column: columnIdx
                                      row: rowIdx
                                      customClass: cellDef.className
                                      loginRequired: cellDef.loginRequired
                                      handleClick: @handleCellClick
                                    },
                                    cellDef.category
                                  )
                                 else
                                  (MBMaterialsContainer
                                    visible: visible
                                    collections: cellDef.collections
                                    ownMaterials: cellDef.ownMaterials
                                  )
        if cellDef.children
          # Recursively go to children array, add its elements to column + 1
          # and mark them visible only if current cell is selected.
          fillColumns cellDef.children, columnIdx + 1, selected

    fillColumns @props.materials
    columns

  render: ->
    (div {className: 'materials-bin'},
      for column in @_getColumns()
        (div {className: 'mb-column'}, column)
    )

window.MaterialsBin = React.createFactory MaterialsBinClass

Portal.renderMaterialsBin = (definition, selectorOrElement) ->
  React.render MaterialsBin(materials: definition), jQuery(selectorOrElement)[0]
