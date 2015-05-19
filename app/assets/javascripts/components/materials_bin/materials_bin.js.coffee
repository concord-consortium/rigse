{div} = React.DOM

window.MaterialsBinClass = React.createClass
  propTypes:
    materials: React.PropTypes.array.isRequired

  getInitialState: ->
    # it is usually very bad form in React to modify props but we will look the other way this time
    # otherwise we need to clone the array just to add the slug
    addSlugs = (list) =>
      for item in list
        if item.category
          item.slug = item.category.toLowerCase().replace /\W/g, '-'
          if item.children
            addSlugs item.children
    addSlugs @props.materials

    # selectedSlugs[2] returns value of row that is selected in column 2 (or falsy value if nothing is selected).
    # E.g. selectedSlugs = [1, 3, 2] means that:
    # - the second row is selected (idx = 1) in the first column,
    # - the fourth row is selected (idx = 3) in the second column,
    # - the third row is selected (idx = 2) in the third column.
    selectedSlugs: @selectFirstSlugs()

  componentWillMount: ->
    # check the hash at startup and for each change
    (jQuery window).on 'hashchange', @checkHash.bind @
    @checkHash()

  componentWillUnmount: ->
    (jQuery window).off 'hashchange', @checkHash

  selectFirstSlugs: ->
    selectedSlugs =  []
    list = @props.materials
    while list?[0]?.slug?
      selectedSlugs.push list[0].slug
      list = list[0].children
    selectedSlugs

  checkHash: ->
    hash = jQuery.trim window.location.hash.substr 1
    selectedSlugs = if hash.length > 0 then (hash.split '|') else @selectFirstSlugs()
    @setState selectedSlugs: selectedSlugs

  handleCellClick: (column, slug) ->
    # Unselect all the cells that are to the right of modified column.
    newSlugs = @state.selectedSlugs.slice 0, column + 1
    # Select clicked slug
    newSlugs[column] = slug
    window.location.hash = newSlugs.join '|'

  isSlugSelected: (column, slug) ->
    @state.selectedSlugs[column] is slug

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
        selected = @isSlugSelected columnIdx, cellDef.slug
        columns[columnIdx].push if cellDef.category
                                  (MBMaterialsCategory {
                                      visible: visible
                                      selected: selected
                                      column: columnIdx
                                      slug: cellDef.slug
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
