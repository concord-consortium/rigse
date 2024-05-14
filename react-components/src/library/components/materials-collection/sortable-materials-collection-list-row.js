import React from 'react'
// import { SortableElement } from 'react-sortable-hoc'
import css from './style.scss'

const SortableElement = (Element) => Element

class MaterialsCollectionListRow extends React.Component {
  render () {
    const { item } = this.props

    const handleDelete = (e) => {
      e.preventDefault()
      this.props.handleDelete(item)
    }

    return (
      <div className={css.editMaterialsCollectionsListRow}>
        <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span>
        <span className={css.editMaterialsCollectionsListRowName}>
          <a href={item.url}>{item.name}</a>
          {item.is_archived
            ? <div className={css.archived}><i className='fa fa-archive' /> (archived)</div>
            : undefined
          }
        </span>
        <span className={css.editMaterialsCollectionsListRowButtons}>
          <button onClick={handleDelete}>Delete</button>
        </span>
      </div>
    )
  }
}

const SortableMaterialsCollectionListRow = SortableElement(MaterialsCollectionListRow)

export default SortableMaterialsCollectionListRow
