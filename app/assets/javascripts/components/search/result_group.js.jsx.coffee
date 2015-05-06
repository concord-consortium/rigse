SearchResultGroup = React.createClass
  render: ->
    group = @props.group
    result_items = group.materials.map (material)-> `<SearchResultItem material={material} key={material.id} />`
    bookmark_id = group.type + '_bookmark'
    return `(
      <div id={bookmark_id} className={'materials_container' + group.type}>
        <div className={'material_list_header'}>
          {group.header}
        </div>
        <p className={'border_top'}>
          <PaginationInfo info={group.pagination} />
        </p>
        <Pagination info={group.pagination} />

        <table className={'result_material'} cellPadding='0' cellSpacing='0'>
          <tr>
            <td className={'material_list'}>
              {result_items}
            </td>
          </tr>
        </table>
        <br />
        <Pagination info={group.pagination} />
      </div>
    )`

window.SearchResultGroup = SearchResultGroup
