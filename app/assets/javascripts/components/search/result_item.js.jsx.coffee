SearchResultItem = React.createClass
  render: ->
    material = @props.material
    return `(
      <div className='material_list_item' data-material_id={material.id} data-material_name={material.name} id={'search_' + material.class_name_underscored + '_' + material.id }>
        <div className='main-part'>
          <MaterialIcon material={material} />
          <MaterialInfo material={material} />
          <MaterialBody material={material} />
        </div>
        <MaterialDetails material={material} />
      </div>
    )`

window.SearchResultItem = SearchResultItem
