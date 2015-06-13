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
          item.slug = @generateSlug item.category
          if item.children
            addSlugs item.children
    addSlugs @props.materials

    # selectedSlugs[X] returns a slug that is selected in column X (or falsy value if nothing is selected).
    # E.g. selectedSlugs = ['category-a', 'subcategory-b', 'category-c'] means that:
    # - 'category-a' is selected in the first column,
    # - 'category-b' is selected in the second column,
    # - 'category-c' is selected in the third column.
    selectedSlugs: @selectFirstSlugs()

  componentWillMount: ->
    # check the hash at startup and for each change
    (jQuery window).on 'hashchange', @checkHash
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

  generateSlug: (name) ->
    @_isSlugTaken = {} unless @_isSlugTaken?
    slug = name.toLowerCase().replace /\W/g, '-'
    while @_isSlugTaken[slug]
      slug += '-'
    @_isSlugTaken[slug] = true
    slug

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
        rowIdx = columns[columnIdx].length
        columns[columnIdx].push if cellDef.category
                                  (MBMaterialsCategory {
                                      key: rowIdx
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
                                else if cellDef.collections
                                  (MBCollections
                                    key: rowIdx
                                    visible: visible
                                    collections: cellDef.collections
                                  )
                                else if cellDef.ownMaterials
                                  (MBOwnMaterials key: rowIdx, visible: visible)
                                else if cellDef.materialsByAuthor
                                  (MBMaterialsByAuthor key: rowIdx, visible: visible)
        if cellDef.children
          # Recursively go to children array, add its elements to column + 1
          # and mark them visible only if current cell is selected.
          fillColumns cellDef.children, columnIdx + 1, selected

    fillColumns @props.materials
    columns

  render: ->
    (div {className: 'materials-bin'},
      for column, idx in @_getColumns()
        (div {key: idx, className: 'mb-column'}, column)
    )

window.MaterialsBin = React.createFactory MaterialsBinClass

Portal.renderMaterialsBin = (definition, selectorOrElement) ->
  React.render MaterialsBin(materials: definition), jQuery(selectorOrElement)[0]
